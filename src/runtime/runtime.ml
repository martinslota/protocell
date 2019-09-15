open Base
module Byte_input = Byte_input
module Wire_format = Wire_format

type wire_value = Types.wire_value =
  | Varint of int64
  | Length_delimited of string

type wire_type = Types.wire_type =
  | Varint_type
  | Length_delimited_type

module Field = struct
  type _ typ =
    | I32 : int typ
    | I64 : int typ
    | S32 : int typ
    | S64 : int typ
    | U32 : int typ
    | U64 : int typ
    | String : string typ

  type 'a value = 'a typ * 'a

  type validation_error = [`Integer_outside_field_type_range of int typ * int]

  let max_uint_32_value =
    match Int32.(to_int max_value) with
    | None -> Int.max_value
    | Some n -> (2 * n) + 1

  let validate : type v. v typ -> v -> (unit, [> validation_error]) Result.t =
   fun typ value ->
    let validate_i32 : int typ -> int -> (unit, [> validation_error]) Result.t =
     fun typ value ->
      match Int.to_int32 value with
      | None -> Error (`Integer_outside_field_type_range (typ, value))
      | Some _ -> Ok ()
    in
    match typ with
    | I32 -> validate_i32 I32 value
    | S32 -> validate_i32 S32 value
    | I64 -> Ok ()
    | S64 -> Ok ()
    | U32 -> (
      match value < 0 || value > max_uint_32_value with
      | true -> Error (`Integer_outside_field_type_range (typ, value))
      | false -> Ok ())
    | U64 -> (
      match value < 0 with
      | true -> Error (`Integer_outside_field_type_range (typ, value))
      | false -> Ok ())
    | String -> Ok ()
end

type 'sort decoding_error =
  [ `Wrong_value_sort_for_int_field of 'sort * int Field.typ
  | `Wrong_value_sort_for_string_field of 'sort * string Field.typ
  | `Integer_outside_int_type_range of int64 ]

module type Serialization = sig
  type t

  type sort

  type id

  module Id : Base.Hashtbl.Key with type t = id

  val to_sort : t -> sort

  val encode_int : int Field.value -> t

  val decode_int : int Field.typ -> t -> (int, [> sort decoding_error]) Result.t

  val encode_string : string Field.value -> t

  val decode_string : string Field.typ -> t -> (string, [> sort decoding_error]) Result.t
end

module Wire : Serialization with type t = wire_value with type id = int = struct
  type t = Types.wire_value

  type sort = Types.wire_type

  type id = int

  module Id = Int

  let to_sort = Types.wire_value_to_type

  let zigzag_encode i = Int64.((i asr 63) lxor (i lsl 1))

  let zigzag_decode i = Int64.((i lsr 1) lxor -(i land one))

  let encode_int (typ, int) =
    Varint
      (match typ with
      | Field.I32 | I64 | U32 | U64 -> Int64.of_int int
      | S32 | S64 -> int |> Int64.of_int |> zigzag_encode)

  let decode_int typ wire_value =
    match wire_value with
    | Varint int64 -> (
        let int64 =
          match typ with
          | Field.S32 | S64 -> zigzag_decode int64
          | _ -> int64
        in
        match Int64.to_int int64 with
        | None -> Error (`Integer_outside_int_type_range int64)
        | Some i -> Ok i)
    | Length_delimited _ ->
        Error (`Wrong_value_sort_for_int_field (to_sort wire_value, typ))

  let encode_string (_, string) = Length_delimited string

  let decode_string typ wire_value =
    match wire_value with
    | Length_delimited string -> Ok string
    | Varint _ -> Error (`Wrong_value_sort_for_string_field (to_sort wire_value, typ))
end

module Text : Serialization with type t = Text_format.value with type id = string =
struct
  type t = Text_format.value

  type sort =
    | Integer_sort
    | String_sort

  type id = string

  module Id = String

  let to_sort = function
    | Text_format.Integer _ -> Integer_sort
    | String _ -> String_sort

  let encode_int (_, int) = Text_format.Integer (Int64.of_int int)

  let decode_int typ wire_value =
    match wire_value with
    | Text_format.Integer int64 -> (
      match Int64.to_int int64 with
      | None -> Error (`Integer_outside_int_type_range int64)
      | Some i -> Ok i)
    | String _ -> Error (`Wrong_value_sort_for_int_field (to_sort wire_value, typ))

  let encode_string (_, string) = Text_format.String string

  let decode_string typ wire_value =
    match wire_value with
    | Text_format.String string -> Ok string
    | Integer _ -> Error (`Wrong_value_sort_for_string_field (to_sort wire_value, typ))
end

module type FormatImpl = sig
  type t

  type sort

  type id

  type 'a spot

  type cloaked_spot

  val encode : 'a Field.value -> t

  val validate_and_encode
    :  id ->
    'a Field.typ ->
    'a ->
    (id * t, [> Field.validation_error]) Result.t

  val allocate : 'a Field.typ -> 'a spot

  val read : 'a spot -> 'a

  val cloak : 'a spot -> cloaked_spot

  val decode_all
    :  (id * t) list ->
    (id * cloaked_spot) list ->
    (unit, [> sort decoding_error]) Result.t
end

module Impl (F : Serialization) :
  FormatImpl with type t = F.t with type sort = F.sort with type id = F.id = struct
  type t = F.t

  type sort = F.sort

  type id = F.id

  type 'a spot = 'a Field.typ * 'a ref

  type cloaked_spot = Cloak : 'a spot -> cloaked_spot

  let encode : type v. v Field.value -> t =
   fun ((typ, _) as value) ->
    match typ with
    | I32 -> F.encode_int value
    | I64 -> F.encode_int value
    | S32 -> F.encode_int value
    | S64 -> F.encode_int value
    | U32 -> F.encode_int value
    | U64 -> F.encode_int value
    | String -> F.encode_string value

  let validate_and_encode name typ value =
    let open Result.Let_syntax in
    Field.validate typ value >>| fun () -> name, encode (typ, value)

  let allocate : type t. t Field.typ -> t spot =
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

  let read (_, value) = !value

  let cloak spot = Cloak spot

  let decode_one : t -> cloaked_spot -> (unit, [> sort decoding_error]) Result.t =
   fun value (Cloak (typ, spot)) ->
    let set_spot = Result.map ~f:(fun value -> spot := value) in
    match typ with
    | I32 -> F.decode_int typ value |> set_spot
    | I64 -> F.decode_int typ value |> set_spot
    | S32 -> F.decode_int typ value |> set_spot
    | S64 -> F.decode_int typ value |> set_spot
    | U32 -> F.decode_int typ value |> set_spot
    | U64 -> F.decode_int typ value |> set_spot
    | String -> F.decode_string typ value |> set_spot

  let decode_all values spots =
    let wire_records =
      Hashtbl.of_alist_multi ~growth_allowed:false (module F.Id) values
    in
    match
      List.map spots ~f:(fun (id, cloaked_spot) ->
          match Hashtbl.find wire_records id with
          | None -> Ok ()
          | Some [] -> Ok ()
          | Some (value :: _) -> decode_one value cloaked_spot)
      |> Result.all_unit
    with
    | Error e -> Error e
    | Ok () -> Ok ()
end

module Text_impl = Impl (Text)
module Wire_impl = Impl (Wire)

module Message = struct
  type serialization_error = Field.validation_error

  let serialize
      :  (int * wire_value, [> serialization_error]) Result.t list ->
      (string, [> serialization_error]) Result.t
    =
   fun fields ->
    let open Result.Let_syntax in
    Result.all fields >>| fun values ->
    let output = Byte_output.create () in
    Wire_format.Writer.write_values output values;
    Byte_output.contents output

  type deserialization_error =
    [ Wire_format.Reader.error
    | Wire_impl.sort decoding_error ]

  let deserialize
      :  string -> (int * Wire_impl.cloaked_spot) list ->
      (unit, [> deserialization_error]) Result.t
    =
   fun bytes decoders ->
    let open Result.Let_syntax in
    let input = Byte_input.create bytes in
    Wire_format.Reader.read_values input >>= (Fn.flip Wire_impl.decode_all) decoders

  type stringification_error = Field.validation_error

  let stringify
      :  (string * Text_format.value, [> stringification_error]) Result.t list ->
      (string, [> stringification_error]) Result.t
    =
   fun fields ->
    let open Result.Let_syntax in
    Result.all fields >>| fun text_format ->
    let output = Byte_output.create () in
    Text_format.Writer.write_values output text_format;
    Byte_output.contents output

  type unstringification_error =
    [ Text_format.Reader.error
    | Text_impl.sort decoding_error ]

  let unstringify
      :  string -> (string * Text_impl.cloaked_spot) list ->
      (unit, [> unstringification_error]) Result.t
    =
   fun bytes decoders ->
    let open Result.Let_syntax in
    let input = Byte_input.create bytes in
    Text_format.Reader.read_values input >>= Fn.flip Text_impl.decode_all decoders
end
