open Base

module Writer : sig
  val append_all : Byte_output.t -> (string * Types.wire_value) list -> unit
end

module Reader : sig
  type error =
    [ `Unexpected_character of char
    | `Invalid_number_string of string
    | `Identifier_expected
    | Byte_input.error ]

  val read_all : Byte_input.t -> ((string * Types.wire_value) list, [> error]) Result.t
end
