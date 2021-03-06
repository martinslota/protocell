open Base

type t =
  | Varint of int64
  | Fixed_64_bits of int64
  | Length_delimited of string
  | Fixed_32_bits of int32

type sort =
  | Varint_type
  | Fixed_64_bits_type
  | Length_delimited_type
  | Fixed_32_bits_type

let show_sort = function
  | Varint_type -> "Varint"
  | Fixed_64_bits_type -> "64-bit"
  | Length_delimited_type -> "Length-delimited"
  | Fixed_32_bits_type -> "32-bit"

type id = int

module Id = Int

type 'v value = 'v Field_value.t

type 'v typ = 'v Field_value.typ

type parsed_message = (id, t list) Hashtbl.t

type serialization_error = Field_value.validation_error

let show_serialization_error = Field_value.show_validation_error

type parse_error =
  [ `Unknown_wire_type of int
  | `Integer_outside_int_type_range of int64
  | `Varint_too_long
  | `Invalid_string_length of int
  | Byte_input.error ]

let show_parse_error = function
  | `Unknown_wire_type int -> Printf.sprintf "Unknown wire type ID %d" int
  | `Varint_too_long -> "Varint value was longer than 64 bits"
  | `Invalid_string_length int -> Printf.sprintf "Invalid string length: %d" int
  | `Integer_outside_int_type_range int64 ->
      Printf.sprintf "Varint value %s outside OCaml int type range"
      @@ Int64.to_string int64
  | #Byte_input.error as e -> Byte_input.show_error e

type decoding_error =
  [ `Wrong_binary_value_for_string_field of sort * string typ
  | `Wrong_binary_value_for_int_field of sort * int typ
  | `Wrong_binary_value_for_int32_field of sort * int32 typ
  | `Wrong_binary_value_for_int64_field of sort * int64 typ
  | `Wrong_binary_value_for_float_field of sort * float typ
  | `Wrong_binary_value_for_bool_field of sort * bool typ
  | `Wrong_binary_value_for_message_field of sort
  | `Wrong_binary_value_for_enum_field of sort
  | `Unrecognized_enum_value of int
  | `Multiple_oneof_fields_set of id list
  | `Integer_outside_int_type_range of int64 ]

let show_decoding_error error =
  let wrong_sort_msg field_type_name sort typ =
    Printf.sprintf
      "%s field type %s cannot accept value type %s"
      field_type_name
      (Field_value.show_typ typ)
      (show_sort sort)
  in
  match error with
  | `Wrong_binary_value_for_string_field (sort, typ) -> wrong_sort_msg "String" sort typ
  | `Wrong_binary_value_for_int_field (sort, typ) -> wrong_sort_msg "Int" sort typ
  | `Wrong_binary_value_for_int32_field (sort, typ) -> wrong_sort_msg "Int32" sort typ
  | `Wrong_binary_value_for_int64_field (sort, typ) -> wrong_sort_msg "Int64" sort typ
  | `Wrong_binary_value_for_float_field (sort, typ) -> wrong_sort_msg "Float" sort typ
  | `Wrong_binary_value_for_bool_field (sort, typ) -> wrong_sort_msg "Boolean" sort typ
  | `Wrong_binary_value_for_message_field sort ->
      Printf.sprintf "Message field type cannot accept value type %s" (show_sort sort)
  | `Wrong_binary_value_for_enum_field sort ->
      Printf.sprintf "Enum field type cannot accept value type %s" (show_sort sort)
  | `Unrecognized_enum_value enum_value ->
      Printf.sprintf "Unrecognized enum value %d" enum_value
  | `Multiple_oneof_fields_set ids ->
      ids
      |> List.map ~f:Int.to_string
      |> String.concat ~sep:", "
      |> Printf.sprintf "Multiple oneof fields set: %s"
  | `Integer_outside_int_type_range int64 ->
      Printf.sprintf "Varint value %s outside OCaml int type range"
      @@ Int64.to_string int64

type deserialization_error =
  [ parse_error
  | decoding_error
  | Field_value.validation_error ]

let show_deserialization_error = function
  | #parse_error as e -> show_parse_error e
  | #decoding_error as e -> show_decoding_error e
  | #Field_value.validation_error as e -> Field_value.show_validation_error e

let to_sort = function
  | Varint _ -> Varint_type
  | Fixed_64_bits _ -> Fixed_64_bits_type
  | Length_delimited _ -> Length_delimited_type
  | Fixed_32_bits _ -> Fixed_32_bits_type

let sort_to_id = function
  | Varint_type -> 0
  | Fixed_64_bits_type -> 1
  | Length_delimited_type -> 2
  | Fixed_32_bits_type -> 5

let sort_of_id = function
  | 0 -> Some Varint_type
  | 1 -> Some Fixed_64_bits_type
  | 2 -> Some Length_delimited_type
  | 5 -> Some Fixed_32_bits_type
  | _ -> None

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

  let write_fixed_64_bits output int64 =
    let bytes = Bytes.create 8 in
    EndianBytes.LittleEndian.set_int64 bytes 0 int64;
    Byte_output.write_bytes' output bytes

  let write_fixed_32_bits output int32 =
    let bytes = Bytes.create 4 in
    EndianBytes.LittleEndian.set_int32 bytes 0 int32;
    Byte_output.write_bytes' output bytes

  let write_value output wire_value =
    match wire_value with
    | Varint int -> write_varint_64 output int
    | Fixed_64_bits int64 -> write_fixed_64_bits output int64
    | Length_delimited bytes ->
        let length = String.length bytes in
        write_varint output length;
        Byte_output.write_bytes output bytes
    | Fixed_32_bits int32 -> write_fixed_32_bits output int32

  let write_field output (field_id, value) =
    let sort = to_sort value in
    let id = sort_to_id sort in
    let wire_descriptor = (field_id lsl 3) lor id in
    write_varint output wire_descriptor;
    write_value output value

  let get_packed values =
    let output = Byte_output.create () in
    List.iter values ~f:(fun value -> write_value output value);
    Byte_output.contents output
end

module Reader = struct
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

  let read_fixed_64 input =
    let open Result.Let_syntax in
    Byte_input.read_bytes input 8 >>| fun bytes ->
    EndianString.LittleEndian.get_int64 bytes 0

  let read_varint input =
    match read_varint_64 input with
    | Ok value -> (
      match Int64.to_int value with
      | None -> Error (`Integer_outside_int_type_range value)
      | Some value -> Ok value)
    | Error _ as error -> error

  let read_string input =
    let open Result.Let_syntax in
    read_varint input >>= function
    | string_length when string_length < 0 ->
        Error (`Invalid_string_length string_length)
    | string_length -> Byte_input.read_bytes input string_length

  let read_fixed_32 input =
    let open Result.Let_syntax in
    Byte_input.read_bytes input 4 >>| fun bytes ->
    EndianString.LittleEndian.get_int32 bytes 0

  let read input =
    let rec collect_all acc =
      let open Result.Let_syntax in
      match Byte_input.has_more_bytes input with
      | false -> acc
      | true ->
          let wire_record =
            read_varint input >>= fun wire_descriptor ->
            let wire_type = wire_descriptor land 0x7 in
            let field_number = wire_descriptor lsr 3 in
            (match sort_of_id wire_type with
            | Some Varint_type -> read_varint_64 input >>| fun int -> Varint int
            | Some Fixed_64_bits_type ->
                read_fixed_64 input >>| fun int -> Fixed_64_bits int
            | Some Length_delimited_type ->
                read_string input >>| fun bytes -> Length_delimited bytes
            | Some Fixed_32_bits_type ->
                read_fixed_32 input >>| fun int -> Fixed_32_bits int
            | None -> Error (`Unknown_wire_type wire_type))
            >>| fun wire_value -> field_number, wire_value
          in
          collect_all (wire_record :: acc)
    in
    collect_all [] |> Result.all

  let read_packed input read_one =
    let rec collect_all acc =
      match Byte_input.has_more_bytes input with
      | false -> List.rev acc
      | true ->
          let value = read_one input in
          collect_all (value :: acc)
    in
    collect_all [] |> Result.all
end

module Encoding : sig
  val encode_string : string value -> t

  val decode_string : string typ -> t -> (string, [> decoding_error]) Result.t

  val encode_int : int value -> t

  val encode_int32 : int32 value -> t

  val encode_int64 : int64 value -> t

  val encode_ints : int Field_value.t list -> t list

  val encode_int32s : int32 Field_value.t list -> t list

  val encode_int64s : int64 Field_value.t list -> t list

  val decode_int : int typ -> t -> (int, [> decoding_error]) Result.t

  val decode_int32 : int32 typ -> t -> (int32, [> decoding_error]) Result.t

  val decode_int64 : int64 typ -> t -> (int64, [> decoding_error]) Result.t

  val decode_ints
    :  int Field_value.typ ->
    t ->
    (int list, [> deserialization_error]) Result.t

  val decode_int32s
    :  int32 Field_value.typ ->
    t ->
    (int32 list, [> deserialization_error]) Result.t

  val decode_int64s
    :  int64 Field_value.typ ->
    t ->
    (int64 list, [> deserialization_error]) Result.t

  val encode_float : float value -> t

  val encode_floats : float Field_value.t list -> t list

  val decode_float : float typ -> t -> (float, [> decoding_error]) Result.t

  val decode_floats
    :  float Field_value.typ ->
    t ->
    (float list, [> deserialization_error]) Result.t

  val encode_bool : bool value -> t

  val encode_bools : bool Field_value.t list -> t list

  val decode_bool : bool typ -> t -> (bool, [> decoding_error]) Result.t

  val decode_bools
    :  bool Field_value.typ ->
    t ->
    (bool list, [> deserialization_error]) Result.t
end = struct
  let encode_string value =
    let value = Field_value.unpack value in
    Length_delimited value

  let decode_string typ value =
    match value with
    | Length_delimited string -> Ok string
    | _ -> Error (`Wrong_binary_value_for_string_field (to_sort value, typ))

  let zigzag_encode_64 i = Int64.((i asr 63) lxor (i lsl 1))

  let zigzag_decode_64 i = Int64.((i lsr 1) lxor -(i land one))

  let max_int32_as_int64 = Int32.(max_value |> to_int64)

  let two_to_the_power_of_32_as_int64 = Int64.(one lsl 32)

  let two_to_the_power_of_32_minus_one_as_int64 =
    Int64.(two_to_the_power_of_32_as_int64 - one)

  let encode_int value =
    let module F = Field_value in
    let typ = F.typ value in
    let int = F.unpack value in
    match typ with
    | F.(Int32_t As_int) | F.(Int64_t As_int) | F.(Uint32_t As_int) | F.(Uint64_t As_int)
      ->
        Varint (int |> Int64.of_int)
    | F.(Sint32_t As_int) | F.(Sint64_t As_int) ->
        Varint (int |> Int64.of_int |> zigzag_encode_64)
    | F.(Fixed32_t As_int) ->
        Fixed_32_bits
          (let int64 = Int64.of_int int in
           let encoded_if_needed =
             match Int64.(int64 > max_int32_as_int64) with
             (* encode as the corresponding int32 value (two's complement) *)
             | true -> Int64.(int64 - two_to_the_power_of_32_as_int64)
             | false -> int64
           in
           Int32.of_int64_exn encoded_if_needed)
    | F.(Fixed64_t As_int) -> Fixed_64_bits (int |> Int64.of_int)
    | F.(Sfixed32_t As_int) -> Fixed_32_bits (int |> Int32.of_int_exn)
    | F.(Sfixed64_t As_int) -> Fixed_64_bits (int |> Int64.of_int)

  let encode_int32 value =
    let module F = Field_value in
    let typ = F.typ value in
    let int = F.unpack value in
    match typ with
    | F.(Int32_t As_int32) | F.(Uint32_t As_int32) -> Varint (int |> Int64.of_int32)
    | F.(Sint32_t As_int32) -> Varint (int |> Int64.of_int32 |> zigzag_encode_64)
    | F.(Fixed32_t As_int32) -> Fixed_32_bits int
    | F.(Sfixed32_t As_int32) -> Fixed_32_bits int
    | _ -> .

  let encode_int64 value =
    let module F = Field_value in
    let typ = F.typ value in
    let int = F.unpack value in
    match typ with
    | F.(Int64_t As_int64) | F.(Uint64_t As_int64) -> Varint int
    | F.(Sint64_t As_int64) -> Varint (int |> zigzag_encode_64)
    | F.(Fixed64_t As_int64) -> Fixed_64_bits int
    | F.(Sfixed64_t As_int64) -> Fixed_64_bits int
    | _ -> .

  let encode_ints values =
    let module F = Field_value in
    match values with
    | [] -> []
    | _ -> [Length_delimited (Writer.get_packed (List.map values ~f:encode_int))]

  let encode_int32s values =
    let module F = Field_value in
    match values with
    | [] -> []
    | _ -> [Length_delimited (Writer.get_packed (List.map values ~f:encode_int32))]

  let encode_int64s values =
    let module F = Field_value in
    match values with
    | [] -> []
    | _ -> [Length_delimited (Writer.get_packed (List.map values ~f:encode_int64))]

  let decode_int typ value =
    let decode_64_bit_int int64 =
      match Int64.to_int int64 with
      | None -> Error (`Integer_outside_int_type_range int64)
      | Some i -> Ok i
    in
    let decode_64_bit_sint = Fn.compose decode_64_bit_int zigzag_decode_64 in
    let decode_32_bit_int int32 =
      match Int32.to_int int32 with
      | None -> Error (`Integer_outside_int_type_range (Int64.of_int32 int32))
      | Some i -> Ok i
    in
    let decode_32_bit_uint int32 =
      let int64 =
        Int64.(of_int32 int32 land two_to_the_power_of_32_minus_one_as_int64)
      in
      decode_64_bit_int int64
    in
    let module F = Field_value in
    match typ with
    | F.(Int32_t As_int) | F.(Int64_t As_int) | F.(Uint32_t As_int) | F.(Uint64_t As_int)
      -> (
      match value with
      | Varint int64 -> decode_64_bit_int int64
      | _ -> Error (`Wrong_binary_value_for_int_field (to_sort value, typ)))
    | F.(Sint32_t As_int) | F.(Sint64_t As_int) -> (
      match value with
      | Varint int64 -> decode_64_bit_sint int64
      | _ -> Error (`Wrong_binary_value_for_int_field (to_sort value, typ)))
    | F.(Fixed32_t As_int) -> (
      match value with
      | Fixed_32_bits int32 -> decode_32_bit_uint int32
      | _ -> Error (`Wrong_binary_value_for_int_field (to_sort value, typ)))
    | F.(Fixed64_t As_int) -> (
      match value with
      | Fixed_64_bits int64 -> decode_64_bit_int int64
      | _ -> Error (`Wrong_binary_value_for_int_field (to_sort value, typ)))
    | F.(Sfixed32_t As_int) -> (
      match value with
      | Fixed_32_bits int32 -> decode_32_bit_int int32
      | _ -> Error (`Wrong_binary_value_for_int_field (to_sort value, typ)))
    | F.(Sfixed64_t As_int) -> (
      match value with
      | Fixed_64_bits int64 -> decode_64_bit_int int64
      | _ -> Error (`Wrong_binary_value_for_int_field (to_sort value, typ)))

  let decode_int32 typ value =
    let decode_64_bit_int32 int64 =
      match Int64.to_int32 int64 with
      | None -> Error (`Integer_outside_int_type_range int64)
      | Some i -> Ok i
    in
    let decode_64_bit_sint = Fn.compose decode_64_bit_int32 zigzag_decode_64 in
    let decode_32_bit_int int32 = Ok int32 in
    let decode_32_bit_uint int32 = Ok int32 in
    let module F = Field_value in
    match typ with
    | F.(Int32_t As_int32) | F.(Uint32_t As_int32) -> (
      match value with
      | Varint int64 -> decode_64_bit_int32 int64
      | _ -> Error (`Wrong_binary_value_for_int32_field (to_sort value, typ)))
    | F.(Sint32_t As_int32) -> (
      match value with
      | Varint int64 -> decode_64_bit_sint int64
      | _ -> Error (`Wrong_binary_value_for_int32_field (to_sort value, typ)))
    | F.(Fixed32_t As_int32) -> (
      match value with
      | Fixed_32_bits int32 -> decode_32_bit_uint int32
      | _ -> Error (`Wrong_binary_value_for_int32_field (to_sort value, typ)))
    | F.(Sfixed32_t As_int32) -> (
      match value with
      | Fixed_32_bits int32 -> decode_32_bit_int int32
      | _ -> Error (`Wrong_binary_value_for_int32_field (to_sort value, typ)))
    | _ -> .

  let decode_int64 typ value =
    let decode_64_bit_int64 int64 = Ok int64 in
    let decode_64_bit_sint = Fn.compose decode_64_bit_int64 zigzag_decode_64 in
    let decode_64_bit_int int64 = Ok int64 in
    let decode_64_bit_uint int64 = Ok int64 in
    let module F = Field_value in
    match typ with
    | F.(Int64_t As_int64) | F.(Uint64_t As_int64) -> (
      match value with
      | Varint int64 -> decode_64_bit_int64 int64
      | _ -> Error (`Wrong_binary_value_for_int64_field (to_sort value, typ)))
    | F.(Sint64_t As_int64) -> (
      match value with
      | Varint int64 -> decode_64_bit_sint int64
      | _ -> Error (`Wrong_binary_value_for_int64_field (to_sort value, typ)))
    | F.(Fixed64_t As_int64) -> (
      match value with
      | Fixed_64_bits int64 -> decode_64_bit_uint int64
      | _ -> Error (`Wrong_binary_value_for_int64_field (to_sort value, typ)))
    | F.(Sfixed64_t As_int64) -> (
      match value with
      | Fixed_64_bits int64 -> decode_64_bit_int int64
      | _ -> Error (`Wrong_binary_value_for_int64_field (to_sort value, typ)))
    | _ -> .

  let decode_ints typ value =
    let open Result.Let_syntax in
    let module F = Field_value in
    match typ with
    | F.(Int32_t As_int)
    | F.(Int64_t As_int)
    | F.(Uint32_t As_int)
    | F.(Uint64_t As_int)
    | F.(Sint32_t As_int)
    | F.(Sint64_t As_int) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_varint_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int typ (Varint int)) |> Result.all
      | _ -> [decode_int typ value] |> Result.all)
    | F.(Fixed32_t As_int) | F.(Sfixed32_t As_int) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_fixed_32
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int typ (Fixed_32_bits int)) |> Result.all
      | _ -> [decode_int typ value] |> Result.all)
    | F.(Fixed64_t As_int) | F.(Sfixed64_t As_int) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_fixed_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int typ (Fixed_64_bits int)) |> Result.all
      | _ -> [decode_int typ value] |> Result.all)

  let decode_int32s typ value =
    let open Result.Let_syntax in
    let module F = Field_value in
    match typ with
    | F.(Int32_t As_int32) | F.(Uint32_t As_int32) | F.(Sint32_t As_int32) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_varint_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int32 typ (Varint int)) |> Result.all
      | _ -> [decode_int32 typ value] |> Result.all)
    | F.(Fixed32_t As_int32) | F.(Sfixed32_t As_int32) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_fixed_32
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int32 typ (Fixed_32_bits int))
          |> Result.all
      | _ -> [decode_int32 typ value] |> Result.all)
    | _ -> .

  let decode_int64s typ value =
    let open Result.Let_syntax in
    let module F = Field_value in
    match typ with
    | F.(Int64_t As_int64) | F.(Uint64_t As_int64) | F.(Sint64_t As_int64) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_varint_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int64 typ (Varint int)) |> Result.all
      | _ -> [decode_int64 typ value] |> Result.all)
    | F.(Fixed64_t As_int64) | F.(Sfixed64_t As_int64) -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_fixed_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_int64 typ (Fixed_64_bits int))
          |> Result.all
      | _ -> [decode_int64 typ value] |> Result.all)
    | _ -> .

  let encode_float value =
    let module F = Field_value in
    let typ = F.typ value in
    let float = F.unpack value in
    match typ with
    | F.Float_t -> Fixed_32_bits (Int32.bits_of_float float)
    | F.Double_t -> Fixed_64_bits (Int64.bits_of_float float)
    | _ -> .

  let encode_floats values =
    let module F = Field_value in
    match values with
    | [] -> []
    | _ -> [Length_delimited (Writer.get_packed (List.map values ~f:encode_float))]

  let decode_float typ value =
    let module F = Field_value in
    match typ with
    | F.Float_t -> (
      match value with
      | Fixed_32_bits int32 -> Ok (Int32.float_of_bits int32)
      | _ -> Error (`Wrong_binary_value_for_float_field (to_sort value, typ)))
    | F.Double_t -> (
      match value with
      | Fixed_64_bits int64 -> Ok (Int64.float_of_bits int64)
      | _ -> Error (`Wrong_binary_value_for_float_field (to_sort value, typ)))
    | _ -> .

  let decode_floats typ value =
    let open Result.Let_syntax in
    let module F = Field_value in
    match typ with
    | F.Float_t -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_fixed_32
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_float typ (Fixed_32_bits int))
          |> Result.all
      | _ -> [decode_float typ value] |> Result.all)
    | F.Double_t -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_fixed_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_float typ (Fixed_64_bits int))
          |> Result.all
      | _ -> [decode_float typ value] |> Result.all)
    | _ -> .

  let encode_bool value =
    let bool = Field_value.unpack value in
    Varint (if bool then Int64.one else Int64.zero)

  let encode_bools values =
    let module F = Field_value in
    match values with
    | [] -> []
    | _ -> [Length_delimited (Writer.get_packed (List.map values ~f:encode_bool))]

  let decode_bool typ value =
    match value with
    | Varint int64 -> Ok Int64.(int64 <> zero)
    | _ -> Error (`Wrong_binary_value_for_bool_field (to_sort value, typ))

  let decode_bools typ value =
    let open Result.Let_syntax in
    let module F = Field_value in
    match typ with
    | F.Bool_t -> (
      match value with
      | Length_delimited bytes ->
          Reader.read_packed (Byte_input.create bytes) Reader.read_varint_64
          >>= fun ints ->
          List.map ints ~f:(fun int -> decode_bool typ (Varint int)) |> Result.all
      | _ -> [decode_bool typ value] |> Result.all)
end

let encode : type v. v Field_value.t -> t option =
 fun value ->
  let module F = Field_value in
  let typ = F.typ value in
  let v = F.unpack value in
  match Field_value.is_default typ v with
  | true -> None
  | false ->
      Some
        (match typ with
        | F.String_t -> Encoding.encode_string value
        | F.Bytes_t -> Encoding.encode_string value
        | F.(Int32_t As_int) -> Encoding.encode_int value
        | F.(Int32_t As_int32) -> Encoding.encode_int32 value
        | F.(Int64_t As_int) -> Encoding.encode_int value
        | F.(Int64_t As_int64) -> Encoding.encode_int64 value
        | F.(Sint32_t As_int) -> Encoding.encode_int value
        | F.(Sint32_t As_int32) -> Encoding.encode_int32 value
        | F.(Sint64_t As_int) -> Encoding.encode_int value
        | F.(Sint64_t As_int64) -> Encoding.encode_int64 value
        | F.(Uint32_t As_int) -> Encoding.encode_int value
        | F.(Uint32_t As_int32) -> Encoding.encode_int32 value
        | F.(Uint64_t As_int) -> Encoding.encode_int value
        | F.(Uint64_t As_int64) -> Encoding.encode_int64 value
        | F.(Fixed32_t As_int) -> Encoding.encode_int value
        | F.(Fixed32_t As_int32) -> Encoding.encode_int32 value
        | F.(Fixed64_t As_int) -> Encoding.encode_int value
        | F.(Fixed64_t As_int64) -> Encoding.encode_int64 value
        | F.(Sfixed32_t As_int) -> Encoding.encode_int value
        | F.(Sfixed32_t As_int32) -> Encoding.encode_int32 value
        | F.(Sfixed64_t As_int) -> Encoding.encode_int value
        | F.(Sfixed64_t As_int64) -> Encoding.encode_int64 value
        | F.Float_t -> Encoding.encode_float value
        | F.Double_t -> Encoding.encode_float value
        | F.Bool_t -> Encoding.encode_bool value)

let encode_repeated : type v. v Field_value.typ -> v Field_value.t list -> t list =
 fun typ values ->
  let module F = Field_value in
  match typ with
  | F.String_t -> List.map values ~f:Encoding.encode_string
  | F.Bytes_t -> List.map values ~f:Encoding.encode_string
  | F.(Int32_t As_int) -> Encoding.encode_ints values
  | F.(Int32_t As_int32) -> Encoding.encode_int32s values
  | F.(Int64_t As_int) -> Encoding.encode_ints values
  | F.(Int64_t As_int64) -> Encoding.encode_int64s values
  | F.(Sint32_t As_int) -> Encoding.encode_ints values
  | F.(Sint32_t As_int32) -> Encoding.encode_int32s values
  | F.(Sint64_t As_int) -> Encoding.encode_ints values
  | F.(Sint64_t As_int64) -> Encoding.encode_int64s values
  | F.(Uint32_t As_int) -> Encoding.encode_ints values
  | F.(Uint32_t As_int32) -> Encoding.encode_int32s values
  | F.(Uint64_t As_int) -> Encoding.encode_ints values
  | F.(Uint64_t As_int64) -> Encoding.encode_int64s values
  | F.(Fixed32_t As_int) -> Encoding.encode_ints values
  | F.(Fixed32_t As_int32) -> Encoding.encode_int32s values
  | F.(Fixed64_t As_int) -> Encoding.encode_ints values
  | F.(Fixed64_t As_int64) -> Encoding.encode_int64s values
  | F.(Sfixed32_t As_int) -> Encoding.encode_ints values
  | F.(Sfixed32_t As_int32) -> Encoding.encode_int32s values
  | F.(Sfixed64_t As_int) -> Encoding.encode_ints values
  | F.(Sfixed64_t As_int64) -> Encoding.encode_int64s values
  | F.Float_t -> Encoding.encode_floats values
  | F.Double_t -> Encoding.encode_floats values
  | F.Bool_t -> Encoding.encode_bools values

let serialize_field id typ value output =
  let open Result.Let_syntax in
  Field_value.create typ value >>| encode >>| function
  | None -> ()
  | Some value -> Writer.write_field output (id, value)

let serialize_optional_field id typ value output =
  match value with
  | None -> Ok ()
  | Some value -> serialize_field id typ value output

let serialize_repeated_field id typ values output =
  let open Result.Let_syntax in
  values
  |> List.map ~f:(Field_value.create typ)
  |> Result.all
  >>| encode_repeated typ
  >>| List.iter ~f:(fun value -> Writer.write_field output (id, value))

let serialize_message_value id serializer value output =
  let open Result.Let_syntax in
  serializer value >>| fun encoding ->
  Writer.write_field output (id, Length_delimited encoding)

let serialize_message_field id serializer value output =
  match value with
  | None -> Ok ()
  | Some value -> serialize_message_value id serializer value output

let serialize_oneof_message_field = serialize_message_value

let serialize_repeated_message_field id serializer values output =
  List.map values ~f:(fun value -> serialize_message_value id serializer value output)
  |> Result.all_unit

let serialize_enum_field id to_int value output =
  let open Result.Let_syntax in
  Field_value.(create (Int64_t As_int) @@ to_int value) >>| encode >>| function
  | None -> ()
  | Some value -> Writer.write_field output (id, value)

let serialize_repeated_enum_field id to_int values output =
  List.map values ~f:(fun value -> serialize_enum_field id to_int value output)
  |> Result.all_unit

let deserialize_message input =
  let open Result.Let_syntax in
  Reader.read input >>| fun records ->
  Hashtbl.of_alist_multi ~growth_allowed:false (module Id) records

let decode_value : type v. t -> v Field_value.typ -> (v, _) Result.t =
 fun value typ ->
  let module F = Field_value in
  match typ with
  | F.String_t -> Encoding.decode_string typ value
  | F.Bytes_t -> Encoding.decode_string typ value
  | F.(Int32_t As_int) -> Encoding.decode_int typ value
  | F.(Int32_t As_int32) -> Encoding.decode_int32 typ value
  | F.(Int64_t As_int) -> Encoding.decode_int typ value
  | F.(Int64_t As_int64) -> Encoding.decode_int64 typ value
  | F.(Sint32_t As_int) -> Encoding.decode_int typ value
  | F.(Sint32_t As_int32) -> Encoding.decode_int32 typ value
  | F.(Sint64_t As_int) -> Encoding.decode_int typ value
  | F.(Sint64_t As_int64) -> Encoding.decode_int64 typ value
  | F.(Uint32_t As_int) -> Encoding.decode_int typ value
  | F.(Uint32_t As_int32) -> Encoding.decode_int32 typ value
  | F.(Uint64_t As_int) -> Encoding.decode_int typ value
  | F.(Uint64_t As_int64) -> Encoding.decode_int64 typ value
  | F.(Fixed32_t As_int) -> Encoding.decode_int typ value
  | F.(Fixed32_t As_int32) -> Encoding.decode_int32 typ value
  | F.(Fixed64_t As_int) -> Encoding.decode_int typ value
  | F.(Fixed64_t As_int64) -> Encoding.decode_int64 typ value
  | F.(Sfixed32_t As_int) -> Encoding.decode_int typ value
  | F.(Sfixed32_t As_int32) -> Encoding.decode_int32 typ value
  | F.(Sfixed64_t As_int) -> Encoding.decode_int typ value
  | F.(Sfixed64_t As_int64) -> Encoding.decode_int64 typ value
  | F.Float_t -> Encoding.decode_float typ value
  | F.Double_t -> Encoding.decode_float typ value
  | F.Bool_t -> Encoding.decode_bool typ value

let decode_values : type v. t -> v Field_value.typ -> (v list, _) Result.t =
 fun value typ ->
  let open Result.Let_syntax in
  let module F = Field_value in
  match typ with
  | F.String_t -> Encoding.decode_string typ value >>| fun value -> [value]
  | F.Bytes_t -> Encoding.decode_string typ value >>| fun value -> [value]
  | F.(Int32_t As_int) -> Encoding.decode_ints typ value
  | F.(Int32_t As_int32) -> Encoding.decode_int32s typ value
  | F.(Int64_t As_int) -> Encoding.decode_ints typ value
  | F.(Int64_t As_int64) -> Encoding.decode_int64s typ value
  | F.(Sint32_t As_int) -> Encoding.decode_ints typ value
  | F.(Sint32_t As_int32) -> Encoding.decode_int32s typ value
  | F.(Sint64_t As_int) -> Encoding.decode_ints typ value
  | F.(Sint64_t As_int64) -> Encoding.decode_int64s typ value
  | F.(Uint32_t As_int) -> Encoding.decode_ints typ value
  | F.(Uint32_t As_int32) -> Encoding.decode_int32s typ value
  | F.(Uint64_t As_int) -> Encoding.decode_ints typ value
  | F.(Uint64_t As_int64) -> Encoding.decode_int64s typ value
  | F.(Fixed32_t As_int) -> Encoding.decode_ints typ value
  | F.(Fixed32_t As_int32) -> Encoding.decode_int32s typ value
  | F.(Fixed64_t As_int) -> Encoding.decode_ints typ value
  | F.(Fixed64_t As_int64) -> Encoding.decode_int64s typ value
  | F.(Sfixed32_t As_int) -> Encoding.decode_ints typ value
  | F.(Sfixed32_t As_int32) -> Encoding.decode_int32s typ value
  | F.(Sfixed64_t As_int) -> Encoding.decode_ints typ value
  | F.(Sfixed64_t As_int64) -> Encoding.decode_int64s typ value
  | F.Float_t -> Encoding.decode_floats typ value
  | F.Double_t -> Encoding.decode_floats typ value
  | F.Bool_t -> Encoding.decode_bools typ value

let decode_field_value typ value =
  let open Result.Let_syntax in
  decode_value value typ >>= Field_value.create typ >>| Field_value.unpack

let decode_field_values : type v. v Field_value.typ -> t -> (v list, _) Result.t =
 fun typ values ->
  let open Result.Let_syntax in
  decode_values values typ
  >>= Fn.compose
        Result.all
        (List.map ~f:(fun field_value ->
             Field_value.create typ field_value >>| Field_value.unpack))

let decode_field id typ records =
  match Hashtbl.find records id with
  | None -> Ok (Field_value.default typ)
  | Some values -> (
    match List.last values with
    | None -> Ok (Field_value.default typ)
    | Some value -> decode_field_value typ value)

let decode_optional_field id typ records =
  let open Result.Let_syntax in
  match Hashtbl.find records id with
  | None -> Ok None
  | Some values -> (
    match List.last values with
    | None -> Ok None
    | Some value -> decode_field_value typ value >>| Option.some)

let decode_repeated_field id typ records =
  let open Result.Let_syntax in
  match Hashtbl.find records id with
  | None -> Ok []
  | Some values ->
      List.map values ~f:(decode_field_values typ) |> Result.all >>| List.concat

let decode_message_value deserializer value =
  match value with
  | Length_delimited encoding -> deserializer encoding
  | _ as value -> Error (`Wrong_binary_value_for_message_field (to_sort value))

let decode_message_field id deserializer records =
  let open Result.Let_syntax in
  match Hashtbl.find records id with
  | None -> Ok None
  | Some values -> (
    match List.last values with
    | None -> Ok None
    | Some value -> decode_message_value deserializer value >>| Option.some)

let decode_oneof_message_field id deserializer records =
  let values = Hashtbl.find_exn records id in
  decode_message_value deserializer (List.last_exn values)

let decode_repeated_message_field id deserializer records =
  match Hashtbl.find records id with
  | None -> Ok []
  | Some values -> List.map values ~f:(decode_message_value deserializer) |> Result.all

let decode_enum_value of_int = function
  | Varint int -> (
    match Int64.to_int int with
    | None -> Error (`Integer_outside_int_type_range int)
    | Some int -> of_int int |> Result.of_option ~error:(`Unrecognized_enum_value int))
  | _ as value -> Error (`Wrong_binary_value_for_enum_field (to_sort value))

let decode_enum_field id of_int default records =
  match Hashtbl.find records id with
  | None -> Ok (default ())
  | Some values -> (
    match List.last values with
    | None -> Ok (default ())
    | Some value -> decode_enum_value of_int value)

let decode_repeated_enum_field id of_int _default records =
  match Hashtbl.find records id with
  | None -> Ok []
  | Some values -> List.map values ~f:(decode_enum_value of_int) |> Result.all

let decode_oneof_field deserializers records =
  let open Result.Let_syntax in
  let applicable =
    List.filter deserializers ~f:(fun (id, _) -> Hashtbl.mem records id)
  in
  match List.length applicable with
  | 0 -> Ok None
  | 1 ->
      applicable |> List.hd_exn |> snd |> fun deserializer ->
      deserializer records >>| Option.some
  | _ -> Error (`Multiple_oneof_fields_set (applicable |> List.map ~f:fst))
