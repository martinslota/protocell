open Base

type 'a t

type cloaked = Cloak : 'a t -> cloaked

val allocate : 'a Field_value.typ -> 'a t

val typ : 'a t -> 'a Field_value.typ

val unpack : 'a t -> 'a

val set : 'a t -> 'a -> (unit, [> Field_value.validation_error]) Result.t

val cloak : 'a t -> cloaked
