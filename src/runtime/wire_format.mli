open Base

type t

type sort

type id = int

type records = (id * t) list

val write_records : Byte_output.t -> records -> unit

type read_error =
  [ `Unknown_wire_type of int
  | `Varint_out_of_bounds of int64
  | `Varint_too_long
  | `Invalid_string_length of int
  | Byte_input.error ]

val read_records : Byte_input.t -> (records, [> read_error]) Result.t

val encode : 'a Field_value.t -> t

val decode_all
  :  (id * t) list ->
  (id * Field_variable.cloaked) list ->
  (unit, [> sort Types.decoding_error | Field_value.validation_error]) Result.t

type serialization_error = Field_value.validation_error

val serialize
  :  (id * t, Field_value.validation_error) Result.t list ->
  (string, [> serialization_error]) Result.t

type deserialization_error =
  [ read_error
  | sort Types.decoding_error
  | Field_value.validation_error ]

val deserialize
  :  string ->
  (int * Field_variable.cloaked) list ->
  (unit, [> deserialization_error]) Result.t
