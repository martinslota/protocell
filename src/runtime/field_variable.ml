open Base

type 'a t = 'a Field_value.typ * 'a ref

type cloaked = Cloak : 'a t -> cloaked

let allocate : type v. v Field_value.typ -> v t =
 fun typ ->
  ( typ,
    match typ with
    | I32 -> Ref.create 0
    | I64 -> Ref.create 0
    | S32 -> Ref.create 0
    | S64 -> Ref.create 0
    | U32 -> Ref.create 0
    | U64 -> Ref.create 0
    | String -> Ref.create "" )

let typ (typ, _) = typ

let unpack (_, ref) = !ref

let set (typ, ref) value =
  let open Result.Let_syntax in
  Field_value.create typ value >>| fun value -> ref := Field_value.unpack value

let cloak spot = Cloak spot
