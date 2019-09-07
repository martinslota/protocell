open Base

type t

type error = [`No_more_bytes]

val create : string -> t

val has_more_bytes : t -> bool

val peek_byte : t -> (char, [> error]) Result.t

val read_byte : t -> (char, [> error]) Result.t

val read_bytes : t -> int -> (string, [> error]) Result.t

val read_if : t -> (char -> bool) -> (char option, [> error]) Result.t

val read_while : t -> (char -> bool) -> string
