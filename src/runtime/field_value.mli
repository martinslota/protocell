open Base

type 'v t

type _ int32_typ =
  | As_int32 : int32 int32_typ
  | As_int : int int32_typ

type _ int64_typ =
  | As_int64 : int64 int64_typ
  | As_int : int int64_typ

type _ typ =
  | String_t : string typ
  | Bytes_t : string typ
  | Int32_t : 'a int32_typ -> 'a typ
  | Int64_t : 'a int64_typ -> 'a typ
  | Sint32_t : 'a int32_typ -> 'a typ
  | Sint64_t : 'a int64_typ -> 'a typ
  | Uint32_t : 'a int32_typ -> 'a typ
  | Uint64_t : 'a int64_typ -> 'a typ
  | Fixed32_t : 'a int32_typ -> 'a typ
  | Fixed64_t : 'a int64_typ -> 'a typ
  | Sfixed32_t : 'a int32_typ -> 'a typ
  | Sfixed64_t : 'a int64_typ -> 'a typ
  | Float_t : float typ
  | Double_t : float typ
  | Bool_t : bool typ

val show_typ : 'v typ -> string

type validation_error =
  [ `Int_outside_field_type_range of int typ * int
  | `Int32_outside_field_type_range of int32 typ * int32
  | `Int64_outside_field_type_range of int64 typ * int64 ]

val show_validation_error : validation_error -> string

val default : 'v typ -> 'v

val is_default : 'v typ -> 'v -> bool

val create : 'v typ -> 'v -> ('v t, [> validation_error]) Result.t

val typ : 'v t -> 'v typ

val unpack : 'v t -> 'v
