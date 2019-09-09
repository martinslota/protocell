open Base

type wire_value =
  | Varint of int64
  | Length_delimited of string
