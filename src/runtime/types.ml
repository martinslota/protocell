type wire_value =
  | Varint of int
  | Length_delimited of string
