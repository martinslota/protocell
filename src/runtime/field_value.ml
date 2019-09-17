open Base

type _ typ =
  | I32 : int typ
  | I64 : int typ
  | S32 : int typ
  | S64 : int typ
  | U32 : int typ
  | U64 : int typ
  | String : string typ

type 'v t = 'v typ * 'v

type validation_error = [`Integer_outside_field_type_range of int typ * int]

let max_uint_32_value =
  match Int32.(to_int max_value) with
  | None -> Int.max_value
  | Some n -> (2 * n) + 1

let create : type v. v typ -> v -> (v t, [> validation_error]) Result.t =
 fun typ value ->
  let validate_i32 : int typ -> int -> (int t, [> validation_error]) Result.t =
   fun typ value ->
    match Int.to_int32 value with
    | None -> Error (`Integer_outside_field_type_range (typ, value))
    | Some _ -> Ok (typ, value)
  in
  match typ with
  | I32 -> validate_i32 I32 value
  | S32 -> validate_i32 S32 value
  | I64 -> Ok (typ, value)
  | S64 -> Ok (typ, value)
  | U32 -> (
    match value < 0 || value > max_uint_32_value with
    | true -> Error (`Integer_outside_field_type_range (typ, value))
    | false -> Ok (typ, value))
  | U64 -> (
    match value < 0 with
    | true -> Error (`Integer_outside_field_type_range (typ, value))
    | false -> Ok (typ, value))
  | String -> Ok (typ, value)

let create_and_transform tag typ value transform =
  create typ value |> Result.map ~f:(fun value -> tag, transform value)

let typ (typ, _) = typ

let unpack (_, value) = value

let relax_error = function
  | `Integer_outside_field_type_range _ as e -> e
