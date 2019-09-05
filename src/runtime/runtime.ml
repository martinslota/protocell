open Base

let append_varint : Buffer.t -> int -> unit =
 fun f i ->
  let rec loop b =
    if b > 0x7f || b < 0
    then (
      let byte = b land 0x7f in
      Buffer.add_char f (byte lor 128 |> Char.of_int_exn);
      loop (b lsr 7))
    else Buffer.add_char f (b |> Char.of_int_exn)
  in
  loop i

type wire_value =
  | Varint of int
  | Length_delimited of string

module Field = struct
  type wire_type =
    | Varint_type
    | Length_delimited_type

  type field_type =
    | Int32
    | String

  let field_type_to_wire_type = function
    | Int32 -> Varint_type
    | String -> Length_delimited_type

  let wire_type_to_id = function
    | Varint_type -> 0
    | Length_delimited_type -> 2

  let encode_int_32 : int -> Buffer.t -> unit = Fn.flip append_varint

  let encode_string : string -> Buffer.t -> unit =
   fun value buffer ->
    let length = String.length value in
    append_varint buffer length;
    Buffer.add_string buffer value

  let stringify_int_32 : int -> Buffer.t -> unit =
   fun value buffer -> Int.to_string value |> Buffer.add_string buffer

  let stringify_string : string -> Buffer.t -> unit =
   fun value buffer ->
    Buffer.add_char buffer '"';
    Buffer.add_string buffer value;
    Buffer.add_char buffer '"'

  type decoding_error =
    [ `Wrong_wire_type
    | `Unknown_wire_type of int
    | Reader.error ]

  type 'a decoding_result = ('a, decoding_error) Result.t

  type 'a decoder = {
    value : 'a ref;
    read : wire_value -> 'a decoding_result;
  }

  let int_32_decoder () =
    let read = function
      | Varint value -> Ok value
      | Length_delimited _ -> Error `Wrong_wire_type
    in
    {value = ref 0; read}

  let string_decoder () =
    let read = function
      | Varint _ -> Error `Wrong_wire_type
      | Length_delimited value -> Ok value
    in
    {value = ref ""; read}

  let consume {value; read} input =
    match read input with
    | Ok v ->
        value := v;
        Ok ()
    | Error _ as error -> error

  let value {value; _} = !value
end

module Message = struct
  let serialize : (int * Field.field_type * (Buffer.t -> unit)) list -> string =
   fun fields ->
    let buffer = Buffer.create 1024 in
    List.iter fields ~f:(fun (field_number, field_type, encoder) ->
        let wire_type_number =
          field_type |> Field.field_type_to_wire_type |> Field.wire_type_to_id
        in
        let wire_descriptor = (field_number lsl 3) lor wire_type_number in
        append_varint buffer wire_descriptor;
        encoder buffer);
    Buffer.contents buffer

  let deserialize
      :  string -> (int * (wire_value -> unit Field.decoding_result)) list ->
      (unit, Field.decoding_error) Result.t
    =
   fun bytes field_deserializers ->
    let open Result.Let_syntax in
    let reader = Reader.create bytes in
    let rec read_all () =
      match Reader.has_more_bytes reader with
      | false -> []
      | true ->
          let wire_record =
            Reader.read_varint reader >>= fun wire_descriptor ->
            let wire_type = wire_descriptor land 0x7 in
            let field_number = wire_descriptor lsr 3 in
            (match wire_type with
            | 0 -> Reader.read_varint reader >>| fun int -> Varint int
            | 2 -> Reader.read_string reader >>| fun bytes -> Length_delimited bytes
            | _ -> Error (`Unknown_wire_type wire_type))
            >>| fun wire_value -> field_number, wire_value
          in
          wire_record :: read_all ()
    in
    read_all () |> Result.all >>= fun wire_records ->
    let wire_records =
      Hashtbl.of_alist_multi ~growth_allowed:false (module Int) wire_records
    in
    List.map field_deserializers ~f:(fun (expected_field_number, deserializer) ->
        match Hashtbl.find wire_records expected_field_number with
        | None -> Ok ()
        | Some [] -> Ok ()
        | Some (value :: _) -> deserializer value)
    |> Result.all_unit

  let stringify : (string * (Buffer.t -> unit)) list -> string =
   fun fields ->
    let buffer = Buffer.create 1024 in
    List.iter fields ~f:(fun (field_name, encoder) ->
        Buffer.add_string buffer field_name;
        Buffer.add_string buffer ": ";
        encoder buffer;
        Buffer.add_string buffer ";\n");
    Buffer.contents buffer
end
