open Base
module Byte_input = Byte_input
module Protoc_dump_reader = Protoc_dump_reader
module Wire_format = Wire_format

type wire_value = Protoc_dump_reader.value =
  | Varint of int
  | Length_delimited of string

module Field = struct
  type field_value =
    | Int32 of int
    | Int64 of int
    | String of string

  let field_value_to_wire_value = function
    | Int32 value | Int64 value -> Varint value
    | String value -> Length_delimited value

  let stringify_int_32 : int -> Buffer.t -> unit =
   fun value buffer -> Int.to_string value |> Buffer.add_string buffer

  let stringify_int_64 : int -> Buffer.t -> unit =
   fun value buffer -> Int.to_string value |> Buffer.add_string buffer

  let stringify_string : string -> Buffer.t -> unit =
   fun value buffer ->
    Buffer.add_char buffer '"';
    Buffer.add_string buffer (Caml.String.escaped value);
    Buffer.add_char buffer '"'

  type decoding_error = [`Wrong_wire_type]

  type 'a decoding_result = ('a, decoding_error) Result.t

  type 'a decoder = {
    value : 'a ref;
    read : wire_value -> 'a decoding_result;
  }

  let int_32_decoder () =
    let read = function
      | Varint value -> Ok value
      (* FIXME out of range problems caught here *)
      | Length_delimited _ -> Error `Wrong_wire_type
    in
    {value = ref 0; read}

  let int_64_decoder () =
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

  let consume : 'a decoder -> wire_value -> (unit, _) Result.t =
   fun {value; read} input ->
    match read input with
    | Ok v ->
        value := v;
        Ok ()
    | Error _ as error -> error

  let value {value; _} = !value
end

module Message = struct
  let serialize : (int * Field.field_value) list -> string =
   fun fields ->
    let output = Byte_output.create () in
    List.iter fields ~f:(fun (field_number, field_value) ->
        let wire_value = Field.field_value_to_wire_value field_value in
        Wire_format.Writer.append_field output ~field_number ~wire_value);
    Byte_output.contents output

  type e1 =
    [ Field.decoding_error
    | Reader.error
    | `Unknown_wire_type of int ]

  let mape = function
    | `Wrong_wire_type as v -> v

  let deserialize
      :  string -> (int * (wire_value -> (unit, Field.decoding_error) Result.t)) list ->
      (unit, e1) Result.t
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
    match read_all () |> Result.all with
    | Error _ as error -> error
    | Ok wire_records -> (
        let wire_records =
          Hashtbl.of_alist_multi ~growth_allowed:false (module Int) wire_records
        in
        match
          List.map field_deserializers ~f:(fun (expected_field_number, deserializer) ->
              match Hashtbl.find wire_records expected_field_number with
              | None -> Ok ()
              | Some [] -> Ok ()
              | Some (value :: _) -> deserializer value)
          |> Result.all_unit
        with
        | Error e -> Error (mape e)
        | Ok () -> Ok ())

  let stringify : (string * (Buffer.t -> unit)) list -> string =
   fun fields ->
    let buffer = Buffer.create 1024 in
    List.iter fields ~f:(fun (field_name, encoder) ->
        Buffer.add_string buffer field_name;
        Buffer.add_string buffer ": ";
        encoder buffer;
        Buffer.add_string buffer "\n");
    Buffer.contents buffer

  type e2 =
    [ Field.decoding_error
    | Protoc_dump_reader.error ]

  let unstringify
      :  string ->
      (string * (wire_value -> (unit, Field.decoding_error) Result.t)) list ->
      (unit, e2) Result.t
    =
   fun bytes field_deserializers ->
    let open Result.Let_syntax in
    let stream = Byte_input.create bytes in
    match
      Protoc_dump_reader.tokenize stream >>= Protoc_dump_reader.read_key_value_pairs
    with
    | Error _ as error -> error
    | Ok records -> (
        let records =
          Hashtbl.of_alist_multi ~growth_allowed:false (module String) records
        in
        match
          List.map field_deserializers ~f:(fun (expected_field_name, deserializer) ->
              match Hashtbl.find records expected_field_name with
              | None -> Ok ()
              | Some [] -> Ok ()
              | Some (value :: _) -> deserializer value)
          |> Result.all_unit
        with
        | Error e -> Error (mape e)
        | Ok () -> Ok ())
end
