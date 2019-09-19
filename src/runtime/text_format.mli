open Base

type t

type sort

type id = string

type serialization_error = Field_value.validation_error

type parse_error =
  [ `Unexpected_character of char
  | `Invalid_number_string of string
  | `Identifier_expected
  | Byte_input.error ]

type deserialization_error =
  [ parse_error
  | sort Types.decoding_error
  | Field_value.validation_error ]

type parsed_message

val serialize_field
  :  id ->
  'v Field_value.typ ->
  'v ->
  Byte_output.t ->
  (unit, [> serialization_error]) Result.t

val deserialize_message : Byte_input.t -> (parsed_message, [> parse_error]) Result.t

val decode_field
  :  id ->
  'v Field_value.typ ->
  parsed_message ->
  ('v, [> sort Types.decoding_error | Field_value.validation_error]) Result.t
