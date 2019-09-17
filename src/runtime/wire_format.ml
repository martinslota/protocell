open Base

type t =
  | Varint of int64
  | Length_delimited of string

type sort =
  | Varint_type
  | Length_delimited_type

type id = int

type records = (id * t) list

module Id = Int

let to_sort = function
  | Varint _ -> Varint_type
  | Length_delimited _ -> Length_delimited_type

let to_id = function
  | Varint_type -> 0
  | Length_delimited_type -> 2

module Encoding : Types.Encoding with type t := t with type sort := sort = struct
  let zigzag_encode i = Int64.((i asr 63) lxor (i lsl 1))

  let zigzag_decode i = Int64.((i lsr 1) lxor -(i land one))

  let encode_int value =
    let typ = Field_value.typ value in
    let int = Field_value.unpack value in
    Varint
      (match typ with
      | I32 | I64 | U32 | U64 -> int |> Int64.of_int
      | S32 | S64 -> int |> Int64.of_int |> zigzag_encode)

  let decode_int typ value =
    match value with
    | Varint int64 -> (
        let int64 =
          match typ with
          | Field_value.I32 | I64 | U32 | U64 -> int64
          | S32 | S64 -> zigzag_decode int64
        in
        match Int64.to_int int64 with
        | None -> Error (`Integer_outside_int_type_range int64)
        | Some i -> Ok i)
    | Length_delimited _ -> Error (`Wrong_value_sort_for_int_field (to_sort value, typ))

  let encode_string value =
    let value = Field_value.unpack value in
    Length_delimited value

  let decode_string typ value =
    match value with
    | Length_delimited string -> Ok string
    | Varint _ -> Error (`Wrong_value_sort_for_string_field (to_sort value, typ))
end

module Writer = struct
  let seven_bit_mask = Int64.of_int 0b0111_1111

  let eighth_bit = Int64.of_int 0b1000_0000

  let write_varint_64 output value =
    let open Int64 in
    let write_byte byte =
      byte |> to_int_exn |> Char.of_int_exn |> Byte_output.write_byte output
    in
    let rec append_rest value =
      let lower_seven_bits = value land seven_bit_mask in
      match value = lower_seven_bits with
      | true -> write_byte lower_seven_bits
      | false ->
          write_byte (lower_seven_bits lor eighth_bit);
          append_rest (value lsr 7)
    in
    append_rest value

  let write_varint output value = value |> Int64.of_int |> write_varint_64 output

  let write_value buffer field_number wire_value =
    let sort = to_sort wire_value in
    let id = to_id sort in
    let wire_descriptor = (field_number lsl 3) lor id in
    write_varint buffer wire_descriptor;
    match wire_value with
    | Varint int -> write_varint_64 buffer int
    | Length_delimited bytes ->
        let length = String.length bytes in
        write_varint buffer length;
        Byte_output.write_bytes buffer bytes

  let write output records =
    List.iter records ~f:(fun (field_number, wire_value) ->
        write_value output field_number wire_value)
end

let write_records = Writer.write

module Reader = struct
  type error =
    [ `Unknown_wire_type of int
    | `Varint_out_of_bounds of int64
    | `Varint_too_long
    | `Invalid_string_length of int
    | Byte_input.error ]

  let read_varint_64 input =
    let add_7_bits : bits:int64 -> offset:int -> value:int64 -> int64 =
     fun ~bits ~offset ~value ->
      let shift = 7 * offset in
      Int64.((bits lsl shift) lor value)
    in
    let rec add_varint_bits ~value ~offset =
      Byte_input.read_byte input
      |> Result.bind ~f:(fun character ->
             let byte = Char.to_int character in
             match offset = 9 && byte > 1 with
             | true -> Error `Varint_too_long
             | false -> (
               match byte land 0x80 > 0 with
               | true ->
                   let bits = byte land 0x7f |> Int64.of_int in
                   let value = add_7_bits ~bits ~offset ~value in
                   let offset = Int.succ offset in
                   add_varint_bits ~value ~offset
               | false -> Ok (add_7_bits ~bits:(Int64.of_int byte) ~offset ~value)))
    in
    add_varint_bits ~value:Int64.zero ~offset:0

  let read_varint input =
    match read_varint_64 input with
    | Ok value -> (
      match Int64.to_int value with
      | None -> Error (`Varint_out_of_bounds value)
      | Some value -> Ok value)
    | Error _ as error -> error

  let read_string input =
    let open Result.Let_syntax in
    read_varint input >>= function
    | string_length when string_length < 0 ->
        Error (`Invalid_string_length string_length)
    | string_length -> Byte_input.read_bytes input string_length

  let read input =
    let rec collect_all () =
      let open Result.Let_syntax in
      match Byte_input.has_more_bytes input with
      | false -> []
      | true ->
          let wire_record =
            read_varint input >>= fun wire_descriptor ->
            let wire_type = wire_descriptor land 0x7 in
            let field_number = wire_descriptor lsr 3 in
            (match wire_type with
            | 0 -> read_varint_64 input >>| fun int -> Varint int
            | 2 -> read_string input >>| fun bytes -> Length_delimited bytes
            | _ -> Error (`Unknown_wire_type wire_type))
            >>| fun wire_value -> field_number, wire_value
          in
          wire_record :: collect_all ()
    in
    collect_all () |> Result.all
end

type read_error_t = Reader.error

type read_error = read_error_t

let read_records = Reader.read

let encode : type v. v Field_value.t -> t =
 fun value ->
  let typ = Field_value.typ value in
  match typ with
  | I32 -> Encoding.encode_int value
  | I64 -> Encoding.encode_int value
  | S32 -> Encoding.encode_int value
  | S64 -> Encoding.encode_int value
  | U32 -> Encoding.encode_int value
  | U64 -> Encoding.encode_int value
  | String -> Encoding.encode_string value

let decode_one : t -> Field_variable.cloaked -> (unit, _) Result.t =
 fun value (Field_variable.Cloak spot) ->
  let open Result.Let_syntax in
  let typ = Field_variable.typ spot in
  let set_spot value = Field_variable.set spot value in
  match typ with
  | I32 -> Encoding.decode_int typ value >>= set_spot
  | I64 -> Encoding.decode_int typ value >>= set_spot
  | S32 -> Encoding.decode_int typ value >>= set_spot
  | S64 -> Encoding.decode_int typ value >>= set_spot
  | U32 -> Encoding.decode_int typ value >>= set_spot
  | U64 -> Encoding.decode_int typ value >>= set_spot
  | String -> Encoding.decode_string typ value >>= set_spot

let decode_all values spots =
  let wire_records = Hashtbl.of_alist_multi ~growth_allowed:false (module Id) values in
  List.map spots ~f:(fun (id, cloaked_spot) ->
      match Hashtbl.find wire_records id with
      | None -> Ok ()
      | Some [] -> Ok ()
      | Some (value :: _) -> decode_one value cloaked_spot)
  |> Result.all_unit

type serialization_error = Field_value.validation_error

let serialize fields =
  Result.all fields
  |> Result.map_error ~f:Field_value.relax_error
  |> Result.map ~f:(fun values ->
         let output = Byte_output.create () in
         write_records output values; Byte_output.contents output)

type deserialization_error =
  [ read_error
  | sort Types.decoding_error
  | Field_value.validation_error ]

let deserialize bytes decoders =
  Byte_input.create bytes |> read_records |> Result.bind ~f:(Fn.flip decode_all decoders)
