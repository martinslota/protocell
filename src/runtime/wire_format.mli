open Base

module Writer : sig
  val write_values : Byte_output.t -> (int * Types.wire_value) list -> unit
end

module Reader : sig
  type error =
    [ `Unknown_wire_type of int
    | `Varint_out_of_bounds of int64
    | `Varint_too_long
    | `Invalid_string_length of int
    | Byte_input.error ]

  val read_values : Byte_input.t -> ((int * Types.wire_value) list, [> error]) Result.t
end
