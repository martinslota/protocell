open Base

type t

type error = [`No_more_bytes]

val create : string -> t

val has_more_bytes : t -> bool

val read_varint : t -> (int, [> error]) Result.t

val read_string : t -> (string, [> error]) Result.t
