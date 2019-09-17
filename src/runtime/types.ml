open Base

type 'sort decoding_error =
  [ `Wrong_value_sort_for_int_field of 'sort * int Field_value.typ
  | `Wrong_value_sort_for_string_field of 'sort * string Field_value.typ
  | `Integer_outside_int_type_range of int64 ]

type 'v value = 'v Field_value.t

type 'v typ = 'v Field_value.typ

module type Encoding = sig
  type t

  type sort

  val encode_int : int value -> t

  val decode_int : int typ -> t -> (int, [> sort decoding_error]) Result.t

  val encode_string : string value -> t

  val decode_string : string typ -> t -> (string, [> sort decoding_error]) Result.t
end
