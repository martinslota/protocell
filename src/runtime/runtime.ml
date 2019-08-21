open Base

let append_varint : Buffer.t -> int -> unit =
 fun f i ->
  let rec loop b =
    if b > 0x7f
    then (
      let byte = b land 0x7f in
      Buffer.add_char f (byte lor 128 |> Char.of_int_exn);
      loop (b lsr 7))
    else Buffer.add_char f (b |> Char.of_int_exn)
  in
  loop i

module Input = struct
  type t = {
    bytes : string;
    position : int ref;
  }

  let get {bytes; position} =
    let result = bytes.[!position] in
    Int.incr position; result
end

let read_varint : Input.t -> int =
 fun input ->
  let add c (acc : int) shift =
    let shft = 7 * shift in
    acc + (c lsl shft)
  in
  let rec loop (acc : int) shift =
    let c = Input.get input in
    if Char.to_int c land 0x80 > 0
    then loop (add (Char.to_int c land 0x7f) acc shift) (Int.succ shift)
    else add (Char.to_int c) acc shift
  in
  loop 0 0

let read_string : Input.t -> string =
 fun ({bytes; position} as input) ->
  let length = read_varint input in
  String.sub bytes ~pos:!position ~len:length

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

  let wire_type_to_int = function
    | Varint_type -> 0
    | Length_delimited_type -> 2

  let encode_int_32 : int -> Buffer.t -> unit = Fn.flip append_varint

  let encode_string : string -> Buffer.t -> unit =
   fun value buffer ->
    let length = String.length value in
    append_varint buffer length;
    Buffer.add_string buffer value

  type decoding_error = [`Wrong_wire_type]

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
          field_type |> Field.field_type_to_wire_type |> Field.wire_type_to_int
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
    let input = Input.{bytes; position = ref 0} in
    (* FIXME *)
    List.map field_deserializers ~f:(fun (_expected_field_number, deserializer) ->
        let wire_descriptor = read_varint input in
        let wire_type = wire_descriptor land 0x7 in
        (* FIXME *)
        let _field_number = wire_descriptor lsr 3 in
        let wire_value =
          match wire_type with
          | 0 -> Varint (read_varint input)
          | 2 -> Length_delimited (read_string input)
          (* FIXME *)
          | _ -> failwith "What?"
        in
        deserializer wire_value)
    |> Result.all_unit
end
