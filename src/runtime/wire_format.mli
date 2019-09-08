open Base

module Writer : sig
  val append_varint : Byte_output.t -> int -> unit

  val append_field
    :  Byte_output.t ->
    field_number:int ->
    wire_value:Types.wire_value ->
    unit

  val append_all : Byte_output.t -> (int * Types.wire_value) list -> unit
end

module Reader : sig
  type error =
    [ `Unknown_wire_type of int
    | `Varint_out_of_bounds of int64
    | `Varint_too_long
    | `Invalid_string_length of int
    | Byte_input.error ]

  val read_varint : Byte_input.t -> (int, [> error]) Result.t

  val read_string : Byte_input.t -> (string, [> error]) Result.t

  val read_all : Byte_input.t -> ((int * Types.wire_value) list, [> error]) Result.t
end
