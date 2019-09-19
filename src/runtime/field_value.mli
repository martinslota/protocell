open Base

type 'v t

type _ typ =
  | I32 : int typ
  | I64 : int typ
  | S32 : int typ
  | S64 : int typ
  | U32 : int typ
  | U64 : int typ
  | String : string typ

type validation_error = [`Integer_outside_field_type_range of int typ * int]

val default : 'v typ -> 'v

val create : 'v typ -> 'v -> ('v t, [> validation_error]) Result.t

val typ : 'v t -> 'v typ

val unpack : 'v t -> 'v

val relax_error : [< validation_error] -> [> validation_error]
