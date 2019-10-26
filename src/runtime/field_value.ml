open Base

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

let show_typ : type v. v typ -> string = function
  | String_t -> "string"
  | Bytes_t -> "bytes"
  | Int32_t As_int32 -> "int32"
  | Int32_t As_int -> "int32_as_int"
  | Int64_t As_int64 -> "int64"
  | Int64_t As_int -> "int64_as_int"
  | Sint32_t As_int32 -> "sint32"
  | Sint32_t As_int -> "sint32_as_int"
  | Sint64_t As_int64 -> "sint64"
  | Sint64_t As_int -> "sint64_as_int"
  | Uint32_t As_int32 -> "uint32"
  | Uint32_t As_int -> "uint32_as_int"
  | Uint64_t As_int64 -> "uint64"
  | Uint64_t As_int -> "uint64_as_int"
  | Fixed32_t As_int32 -> "fixed32"
  | Fixed32_t As_int -> "fixed32_as_int"
  | Fixed64_t As_int64 -> "fixed64"
  | Fixed64_t As_int -> "fixed64_as_int"
  | Sfixed32_t As_int32 -> "sfixed32"
  | Sfixed32_t As_int -> "sfixed32_as_int"
  | Sfixed64_t As_int64 -> "sfixed64"
  | Sfixed64_t As_int -> "sfixed64_as_int"
  | Float_t -> "float"
  | Double_t -> "double"
  | Bool_t -> "bool"

type 'v t = 'v typ * 'v

type validation_error =
  [ `Int_outside_field_type_range of int typ * int
  | `Int32_outside_field_type_range of int32 typ * int32
  | `Int64_outside_field_type_range of int64 typ * int64 ]

let show_validation_error = function
  | `Int_outside_field_type_range (typ, int) ->
      Printf.sprintf
        "Integer %d is outside of the range of field type %s"
        int
        (show_typ typ)
  | `Int32_outside_field_type_range (typ, int) ->
      Printf.sprintf
        "Integer %ld is outside of the range of field type %s"
        int
        (show_typ typ)
  | `Int64_outside_field_type_range (typ, int) ->
      Printf.sprintf
        "Integer %Ld is outside of the range of field type %s"
        int
        (show_typ typ)

let equal : type v. v typ -> v -> v -> bool = function
  | String_t -> String.equal
  | Bytes_t -> String.equal
  | Int32_t As_int32 -> Int32.equal
  | Int32_t As_int -> Int.equal
  | Int64_t As_int64 -> Int64.equal
  | Int64_t As_int -> Int.equal
  | Sint32_t As_int32 -> Int32.equal
  | Sint32_t As_int -> Int.equal
  | Sint64_t As_int64 -> Int64.equal
  | Sint64_t As_int -> Int.equal
  | Uint32_t As_int32 -> Int32.equal
  | Uint32_t As_int -> Int.equal
  | Uint64_t As_int64 -> Int64.equal
  | Uint64_t As_int -> Int.equal
  | Fixed32_t As_int32 -> Int32.equal
  | Fixed32_t As_int -> Int.equal
  | Fixed64_t As_int64 -> Int64.equal
  | Fixed64_t As_int -> Int.equal
  | Sfixed32_t As_int32 -> Int32.equal
  | Sfixed32_t As_int -> Int.equal
  | Sfixed64_t As_int64 -> Int64.equal
  | Sfixed64_t As_int -> Int.equal
  | Float_t -> Float.equal
  | Double_t -> Float.equal
  | Bool_t -> Bool.equal

let default : type v. v typ -> v = function
  | String_t -> ""
  | Bytes_t -> ""
  | Int32_t As_int32 -> 0l
  | Int32_t As_int -> 0
  | Int64_t As_int64 -> 0L
  | Int64_t As_int -> 0
  | Sint32_t As_int32 -> 0l
  | Sint32_t As_int -> 0
  | Sint64_t As_int64 -> 0L
  | Sint64_t As_int -> 0
  | Uint32_t As_int32 -> 0l
  | Uint32_t As_int -> 0
  | Uint64_t As_int64 -> 0L
  | Uint64_t As_int -> 0
  | Fixed32_t As_int32 -> 0l
  | Fixed32_t As_int -> 0
  | Fixed64_t As_int64 -> 0L
  | Fixed64_t As_int -> 0
  | Sfixed32_t As_int32 -> 0l
  | Sfixed32_t As_int -> 0
  | Sfixed64_t As_int64 -> 0L
  | Sfixed64_t As_int -> 0
  | Float_t -> 0.0
  | Double_t -> 0.0
  | Bool_t -> false

let is_default : type v. v typ -> v -> bool =
 fun typ value -> equal typ value (default typ)

let max_uint_32_value =
  match Int32.(to_int max_value) with
  | None -> Int.max_value
  | Some n -> (2 * n) + 1

let create : type v. v typ -> v -> (v t, [> validation_error]) Result.t =
 fun typ value ->
  let validate_i32 : int typ -> int -> (int t, [> validation_error]) Result.t =
   fun typ value ->
    match Int.to_int32 value with
    | None -> Error (`Int_outside_field_type_range (typ, value))
    | Some _ -> Ok (typ, value)
  in
  let validate_u32_int : int typ -> int -> (int t, [> validation_error]) Result.t =
   fun typ value ->
    match value < 0 || value > max_uint_32_value with
    | true -> Error (`Int_outside_field_type_range (typ, value))
    | false -> Ok (typ, value)
  in
  let validate_u32_int32 : int32 typ -> int32 -> (int32 t, [> validation_error]) Result.t
    =
   fun typ value ->
    match Int32.(value < zero) with
    | true -> Error (`Int32_outside_field_type_range (typ, value))
    | false -> Ok (typ, value)
  in
  let validate_u64_int : int typ -> int -> (int t, [> validation_error]) Result.t =
   fun typ value ->
    match value < 0 with
    | true -> Error (`Int_outside_field_type_range (typ, value))
    | false -> Ok (typ, value)
  in
  let validate_u64_int64 : int64 typ -> int64 -> (int64 t, [> validation_error]) Result.t
    =
   fun typ value ->
    match Int64.(value < zero) with
    | true -> Error (`Int64_outside_field_type_range (typ, value))
    | false -> Ok (typ, value)
  in
  match typ with
  | String_t -> Ok (typ, value)
  | Bytes_t -> Ok (typ, value)
  | Int32_t As_int32 -> Ok (typ, value)
  | Int32_t As_int -> validate_i32 typ value
  | Int64_t As_int64 -> Ok (typ, value)
  | Int64_t As_int -> Ok (typ, value)
  | Sint32_t As_int32 -> Ok (typ, value)
  | Sint32_t As_int -> validate_i32 typ value
  | Sint64_t As_int64 -> Ok (typ, value)
  | Sint64_t As_int -> Ok (typ, value)
  | Uint32_t As_int32 -> validate_u32_int32 typ value
  | Uint32_t As_int -> validate_u32_int typ value
  | Uint64_t As_int64 -> validate_u64_int64 typ value
  | Uint64_t As_int -> validate_u64_int typ value
  | Fixed32_t As_int32 -> validate_u32_int32 typ value
  | Fixed32_t As_int -> validate_u32_int typ value
  | Fixed64_t As_int64 -> validate_u64_int64 typ value
  | Fixed64_t As_int -> validate_u64_int typ value
  | Sfixed32_t As_int32 -> Ok (typ, value)
  | Sfixed32_t As_int -> validate_i32 typ value
  | Sfixed64_t As_int64 -> Ok (typ, value)
  | Sfixed64_t As_int -> Ok (typ, value)
  | Float_t -> Ok (typ, value)
  | Double_t -> Ok (typ, value)
  | Bool_t -> Ok (typ, value)

let typ (typ, _) = typ

let unpack (_, value) = value
