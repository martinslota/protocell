open Base

type wire_value =
  | Varint of int64
  | Length_delimited of string

type wire_type =
  | Varint_type
  | Length_delimited_type

let wire_value_to_type = function
  | Varint _ -> Varint_type
  | Length_delimited _ -> Length_delimited_type
