open Base

type wire_type =
  | Varint_type
  | Length_delimited_type

type wire_value = Protoc_dump_reader.value =
  | Varint of int
  | Length_delimited of string

let wire_value_to_type = function
  | Varint _ -> Varint_type
  | Length_delimited _ -> Length_delimited_type

let wire_type_to_id = function
  | Varint_type -> 0
  | Length_delimited_type -> 2

module Writer = struct
  type t = Byte_output.t

  let create = Buffer.create

  let append_varint : t -> int -> unit =
   fun f i ->
    let open Int64 in
    let i = of_int i in
    let rec loop b =
      if b > of_int 0x7f || b < zero
      then (
        let byte = b land of_int 0x7f in
        Byte_output.write_byte f (byte lor of_int 128 |> to_int_exn |> Char.of_int_exn);
        loop (b lsr 7))
      else Byte_output.write_byte f (b |> to_int_exn |> Char.of_int_exn)
    in
    loop i

  let append_field : t -> field_number:int -> wire_value:wire_value -> unit =
   fun buffer ~field_number ~wire_value ->
    let wire_type = wire_value_to_type wire_value in
    let wire_type_id = wire_type_to_id wire_type in
    let wire_descriptor = (field_number lsl 3) lor wire_type_id in
    append_varint buffer wire_descriptor;
    match wire_value with
    | Varint int -> append_varint buffer int
    | Length_delimited bytes ->
        let length = String.length bytes in
        append_varint buffer length;
        Byte_output.write_bytes buffer bytes
end
