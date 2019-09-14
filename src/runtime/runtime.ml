open Base
module Byte_input = Byte_input
module Wire_format = Wire_format

type wire_value = Types.wire_value =
  | Varint of int64
  | Length_delimited of string

type wire_type = Types.wire_type =
  | Varint_type
  | Length_delimited_type

module Field = struct
  type _ typ =
    | I32 : int typ
    | I64 : int typ
    | S32 : int typ
    | S64 : int typ
    | U32 : int typ
    | U64 : int typ
    | String : string typ

  type validation_error = [`Integer_outside_field_type_range of int typ * int]

  type encoding_error = validation_error

  type encoder = unit -> (wire_value, encoding_error) Result.t

  type wire_value_mapping_error =
    [ `Wrong_wire_type_for_int_field of int typ * wire_type
    | `Wrong_wire_type_for_string_field of string typ * wire_type
    | `Integer_outside_int_type_range of int64 ]

  type decoding_error =
    [ wire_value_mapping_error
    | validation_error ]

  type decoding_result = (unit, decoding_error) Result.t

  type decoder = wire_value -> decoding_result

  type 'a cell = {
    value : 'a ref;
    decode : decoder;
  }

  let relax_encoding_error = function
    | `Integer_outside_field_type_range _ as e -> e

  let relax_decoding_error = function
    | `Wrong_wire_type_for_int_field _ as e -> e
    | `Wrong_wire_type_for_string_field _ as e -> e
    | `Integer_outside_int_type_range _ as e -> e
    | `Integer_outside_field_type_range _ as e -> e

  let max_uint_32_value =
    match Int32.(to_int max_value) with
    | None -> Int.max_value
    | Some n -> (2 * n) + 1

  let validate : type v. v typ -> v -> (unit, [> validation_error]) Result.t =
   fun typ value ->
    let validate_i32 : int typ -> int -> (unit, [> validation_error]) Result.t =
     fun typ value ->
      match Int.to_int32 value with
      | None -> Error (`Integer_outside_field_type_range (typ, value))
      | Some _ -> Ok ()
    in
    match typ with
    | I32 -> validate_i32 I32 value
    | S32 -> validate_i32 S32 value
    | I64 | S64 -> Ok ()
    | U32 -> (
      match value < 0 || value > max_uint_32_value with
      | true -> Error (`Integer_outside_field_type_range (typ, value))
      | false -> Ok ())
    | U64 -> (
      match value < 0 with
      | true -> Error (`Integer_outside_field_type_range (typ, value))
      | false -> Ok ())
    | String -> Ok ()

  let zigzag_encode i = Int64.((i asr 63) lxor (i lsl 1))

  let zigzag_decode i = Int64.((i lsr 1) lxor -(i land one))

  let encode_value : type v. v typ -> v -> wire_value =
   fun typ value ->
    match typ with
    | I32 -> Varint (value |> Int64.of_int)
    | I64 -> Varint (value |> Int64.of_int)
    | S32 -> Varint (value |> Int64.of_int |> zigzag_encode)
    | S64 -> Varint (value |> Int64.of_int |> zigzag_encode)
    | U32 -> Varint (value |> Int64.of_int)
    | U64 -> Varint (value |> Int64.of_int)
    | String -> Length_delimited value

  let make_encoder : type v. v typ -> v -> encoder =
   fun typ value () ->
    let open Result.Let_syntax in
    validate typ value >>| fun () -> encode_value typ value

  let decode_value
      : type v. v typ -> wire_value -> (v, [> wire_value_mapping_error]) Result.t
    =
   fun typ wire_value ->
    let decode_int
        : int typ -> wire_value -> (int, [> wire_value_mapping_error]) Result.t
      =
     fun typ wire_value ->
      match wire_value with
      | Varint i -> (
        match Int64.to_int i with
        | None -> Error (`Integer_outside_int_type_range i)
        | Some i -> Ok i)
      | Length_delimited _ ->
          Error
            (`Wrong_wire_type_for_int_field (typ, Types.wire_value_to_type wire_value))
    in
    match typ with
    | I32 -> decode_int typ wire_value
    | I64 -> decode_int typ wire_value
    | S32 -> decode_int typ wire_value
    | S64 -> decode_int typ wire_value
    | U32 -> decode_int typ wire_value
    | U64 -> decode_int typ wire_value
    | String -> (
      match wire_value with
      | Length_delimited string -> Ok string
      | Varint _ ->
          Error
            (`Wrong_wire_type_for_string_field
              (typ, Types.wire_value_to_type wire_value)))

  let to_wire_values
      : ('a * encoder) list -> (('a * wire_value) list, [> encoding_error]) Result.t
    =
   fun field_values ->
    List.map field_values ~f:(fun (field_number, encoder) ->
        match encoder () with
        | Ok wire_value -> Ok (field_number, wire_value)
        | Error e -> Error (relax_encoding_error e))
    |> Result.all

  let make_cell : type v. v typ -> v cell =
    let make_int_cell : int typ -> int cell =
     fun typ ->
      let value = ref 0 in
      let decode wire_value =
        let open Result.Let_syntax in
        decode_value typ wire_value >>= fun v ->
        value := v;
        validate typ v
      in
      {value; decode}
    in
    let make_string_cell : string typ -> string cell =
     fun typ ->
      let value = ref "" in
      let decode wire_value =
        let open Result.Let_syntax in
        decode_value typ wire_value >>= fun v ->
        value := v;
        validate typ v
      in
      {value; decode}
    in
    fun typ ->
      match typ with
      | I32 -> make_int_cell typ
      | I64 -> make_int_cell typ
      | S32 -> make_int_cell typ
      | S64 -> make_int_cell typ
      | U32 -> make_int_cell typ
      | U64 -> make_int_cell typ
      | String -> make_string_cell typ

  let deserialize field_deserializers key_module wire_records =
    let wire_records =
      Hashtbl.of_alist_multi ~growth_allowed:false key_module wire_records
    in
    match
      List.map field_deserializers ~f:(fun (expected_field_number, deserializer) ->
          match Hashtbl.find wire_records expected_field_number with
          | None -> Ok ()
          | Some [] -> Ok ()
          | Some (value :: _) -> deserializer value)
      |> Result.all_unit
    with
    | Error e -> Error (relax_decoding_error e)
    | Ok () -> Ok ()
end

module Message = struct
  type serialization_error = Field.encoding_error

  let serialize
      : (int * Field.encoder) list -> (string, [> serialization_error]) Result.t
    =
   fun fields ->
    let open Result.Let_syntax in
    Field.to_wire_values fields >>| fun wire_values ->
    let output = Byte_output.create () in
    Wire_format.Writer.write_values output wire_values;
    Byte_output.contents output

  type deserialization_error =
    [ Wire_format.Reader.error
    | Field.decoding_error ]

  let deserialize
      :  string -> (int * Field.decoder) list ->
      (unit, [> deserialization_error]) Result.t
    =
   fun bytes field_deserializers ->
    let open Result.Let_syntax in
    let input = Byte_input.create bytes in
    Wire_format.Reader.read_values input
    >>= Field.deserialize field_deserializers (module Int)

  type stringification_error = Field.encoding_error

  let stringify
      : (string * Field.encoder) list -> (string, [> stringification_error]) Result.t
    =
   fun fields ->
    let open Result.Let_syntax in
    Field.to_wire_values fields >>| fun wire_values ->
    let output = Byte_output.create () in
    Text_format.Writer.write_values output wire_values;
    Byte_output.contents output

  type unstringification_error =
    [ Text_format.Reader.error
    | Field.decoding_error ]

  let unstringify
      :  string -> (string * Field.decoder) list ->
      (unit, [> unstringification_error]) Result.t
    =
   fun bytes field_deserializers ->
    let open Result.Let_syntax in
    let input = Byte_input.create bytes in
    Text_format.Reader.read_values input
    >>= Field.deserialize field_deserializers (module String)
end
