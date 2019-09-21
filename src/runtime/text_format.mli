open Base

type t

type sort

type id = string

type serialization_error = Field_value.validation_error

type parse_error =
  [ `Unexpected_character of char
  | `Invalid_number_string of string
  | `Identifier_expected
  | `Nested_message_unfinished
  | Byte_input.error ]

type deserialization_error =
  [ parse_error
  | sort Types.decoding_error
  | Field_value.validation_error ]

type parsed_message

val sort_to_string : sort -> string

val serialize_field
  :  id ->
  'v Field_value.typ ->
  'v ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val serialize_user_field
  :  id ->
  ('v -> (string, ([> serialization_error] as 'e)) Result.t) ->
  'v option ->
  Byte_output.t ->
  (unit, 'e) Result.t

val serialize_enum_field
  :  id ->
  ('v -> string) ->
  'v ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val deserialize_message : Byte_input.t -> (parsed_message, [> parse_error]) Result.t

val decode_field
  :  id ->
  'v Field_value.typ ->
  parsed_message ->
  ('v, [> sort Types.decoding_error | Field_value.validation_error]) Result.t

val decode_user_field
  :  id ->
  (string -> ('v, ([> deserialization_error] as 'b)) Result.t) ->
  parsed_message ->
  ('v option, 'b) Result.t

val decode_enum_field
  :  id ->
  (string -> 'v option) ->
  (unit -> 'v) ->
  parsed_message ->
  ('v, [> deserialization_error]) Result.t
