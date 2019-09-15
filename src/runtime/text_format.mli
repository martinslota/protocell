open Base

type value =
  | Integer of int64
  | String of string

type t = (string * value) list

module Writer : sig
  val write_values : Byte_output.t -> t -> unit
end

module Reader : sig
  type error =
    [ `Unexpected_character of char
    | `Invalid_number_string of string
    | `Identifier_expected
    | Byte_input.error ]

  val read_values : Byte_input.t -> (t, [> error]) Result.t
end
