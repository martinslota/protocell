open Base

type t

type error =
  [ `Varint_too_long
  | `Varint_out_of_bounds of Int64.t
  | `Invalid_string_length of int
  | Byte_input.error ]

val create : string -> t

val has_more_bytes : t -> bool

val read_varint : t -> (int, [> error]) Result.t

val read_string : t -> (string, [> error]) Result.t
