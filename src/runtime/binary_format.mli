open Base

type t

type sort

val show_sort : sort -> string

type id = int

type serialization_error = Field_value.validation_error

val show_serialization_error : serialization_error -> string

type parse_error =
  [ `Unknown_wire_type of int
  | `Integer_outside_int_type_range of int64
  | `Varint_too_long
  | `Invalid_string_length of int
  | Byte_input.error ]

val show_parse_error : parse_error -> string

type decoding_error =
  [ `Wrong_binary_value_for_string_field of sort * string Field_value.typ
  | `Wrong_binary_value_for_int_field of sort * int Field_value.typ
  | `Wrong_binary_value_for_float_field of sort * float Field_value.typ
  | `Wrong_binary_value_for_bool_field of sort * bool Field_value.typ
  | `Wrong_binary_value_for_message_field of sort
  | `Wrong_binary_value_for_enum_field of sort
  | `Unrecognized_enum_value of int
  | `Multiple_oneof_fields_set of int list
  | `Integer_outside_int_type_range of int64 ]

val show_decoding_error : decoding_error -> string

type deserialization_error =
  [ parse_error
  | decoding_error
  | Field_value.validation_error ]

val show_deserialization_error : deserialization_error -> string

type parsed_message

val serialize_field
  :  id ->
  'v Field_value.typ ->
  'v ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val serialize_optional_field
  :  id ->
  'v Field_value.typ ->
  'v option ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val serialize_repeated_field
  :  id ->
  'v Field_value.typ ->
  'v list ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val serialize_message_field
  :  id ->
  ('v -> (string, ([> serialization_error] as 'e)) Result.t) ->
  'v option ->
  Byte_output.t ->
  (unit, 'e) Result.t

val serialize_oneof_message_field
  :  id ->
  ('v -> (string, ([> serialization_error] as 'e)) Result.t) ->
  'v ->
  Byte_output.t ->
  (unit, 'e) Result.t

val serialize_repeated_message_field
  :  id ->
  ('v -> (string, ([> serialization_error] as 'e)) Result.t) ->
  'v list ->
  Byte_output.t ->
  (unit, 'e) Result.t

val serialize_enum_field
  :  id ->
  ('v -> int) ->
  'v ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val serialize_repeated_enum_field
  :  id ->
  ('v -> int) ->
  'v list ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val deserialize_message : Byte_input.t -> (parsed_message, [> parse_error]) Result.t

val decode_field
  :  id ->
  'v Field_value.typ ->
  parsed_message ->
  ('v, [> deserialization_error]) Result.t

val decode_optional_field
  :  id ->
  'v Field_value.typ ->
  parsed_message ->
  ('v option, [> deserialization_error]) Result.t

val decode_repeated_field
  :  id ->
  'v Field_value.typ ->
  parsed_message ->
  ('v list, [> deserialization_error]) Result.t

val decode_message_field
  :  id ->
  (string -> ('v, ([> deserialization_error] as 'e)) Result.t) ->
  parsed_message ->
  ('v option, 'e) Result.t

val decode_oneof_message_field
  :  id ->
  (string -> ('v, ([> deserialization_error] as 'e)) Result.t) ->
  parsed_message ->
  ('v, 'e) Result.t

val decode_repeated_message_field
  :  id ->
  (string -> ('v, ([> deserialization_error] as 'e)) Result.t) ->
  parsed_message ->
  ('v list, 'e) Result.t

val decode_enum_field
  :  id ->
  (int -> 'v option) ->
  (unit -> 'v) ->
  parsed_message ->
  ('v, [> deserialization_error]) Result.t

val decode_repeated_enum_field
  :  id ->
  (int -> 'v option) ->
  (unit -> 'v) ->
  parsed_message ->
  ('v list, [> deserialization_error]) Result.t

val decode_oneof_field
  :  (id, parsed_message -> ('v, ([> deserialization_error] as 'e)) Result.t) List.Assoc.t ->
  parsed_message ->
  ('v option, 'e) Result.t
