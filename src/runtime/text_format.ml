open Base

type t =
  | String of string
  | Integer of int64
  | Float of float
  | Bool of bool
  | Message of string
  | Enum of string

type sort =
  | String_sort
  | Integer_sort
  | Float_sort
  | Bool_sort
  | Message_sort
  | Enum_sort

let show_sort = function
  | String_sort -> "String"
  | Integer_sort -> "Integer"
  | Float_sort -> "Float"
  | Bool_sort -> "Boolean"
  | Message_sort -> "Message"
  | Enum_sort -> "Enum"

type id = string

module Id = String

type 'v typ = 'v Field_value.typ

type 'v value = 'v Field_value.t

type parsed_message = (id, t list) Hashtbl.t

type serialization_error = Field_value.validation_error

let show_serialization_error = Field_value.show_validation_error

type parse_error =
  [ `Unexpected_character of char
  | `Invalid_number_string of string
  | `Identifier_expected
  | `Nested_message_unfinished
  | Byte_input.error ]

let show_parse_error = function
  | `Unexpected_character char -> Printf.sprintf "Unexpected character: %c" char
  | `Invalid_number_string string -> Printf.sprintf "Invalid number string: %s" string
  | `Identifier_expected -> "Identifier expected"
  | `Nested_message_unfinished -> "Nested message unfinished"
  | #Byte_input.error as e -> Byte_input.show_error e

type decoding_error =
  [ `Wrong_text_value_for_string_field of sort * string typ
  | `Wrong_text_value_for_int_field of sort * int typ
  | `Wrong_text_value_for_int32_field of sort * int32 typ
  | `Wrong_text_value_for_int64_field of sort * int64 typ
  | `Wrong_text_value_for_float_field of sort * float typ
  | `Wrong_text_value_for_bool_field of sort * bool typ
  | `Wrong_text_value_for_message_field of sort
  | `Wrong_text_value_for_enum_field of sort
  | `Unrecognized_enum_value of string
  | `Multiple_oneof_fields_set of id list
  | `Integer_outside_int_type_range of int64 ]

let show_decoding_error error =
  let wrong_sort_msg field_type_name sort typ =
    Printf.sprintf
      "%s field type %s cannot accept value type %s"
      field_type_name
      (Field_value.show_typ typ)
      (show_sort sort)
  in
  match error with
  | `Wrong_text_value_for_string_field (sort, typ) -> wrong_sort_msg "String" sort typ
  | `Wrong_text_value_for_int_field (sort, typ) -> wrong_sort_msg "Int" sort typ
  | `Wrong_text_value_for_int32_field (sort, typ) -> wrong_sort_msg "Int32" sort typ
  | `Wrong_text_value_for_int64_field (sort, typ) -> wrong_sort_msg "Int64" sort typ
  | `Wrong_text_value_for_float_field (sort, typ) -> wrong_sort_msg "Float" sort typ
  | `Wrong_text_value_for_bool_field (sort, typ) -> wrong_sort_msg "Boolean" sort typ
  | `Wrong_text_value_for_message_field sort ->
      Printf.sprintf "Message field type cannot accept value type %s" (show_sort sort)
  | `Wrong_text_value_for_enum_field sort ->
      Printf.sprintf "Enum field type cannot accept value type %s" (show_sort sort)
  | `Integer_outside_int_type_range int64 ->
      Printf.sprintf "Varint value %s outside OCaml int type range"
      @@ Int64.to_string int64
  | `Unrecognized_enum_value enum_value ->
      Printf.sprintf "Unrecognized enum value %s" enum_value
  | `Multiple_oneof_fields_set ids ->
      ids |> String.concat ~sep:", " |> Printf.sprintf "Multiple oneof fields set: %s"

let show_deserialization_error = function
  | #parse_error as e -> show_parse_error e
  | #decoding_error as e -> show_decoding_error e
  | #Field_value.validation_error as e -> Field_value.show_validation_error e

type deserialization_error =
  [ parse_error
  | decoding_error
  | Field_value.validation_error ]

let to_sort = function
  | String _ -> String_sort
  | Integer _ -> Integer_sort
  | Float _ -> Float_sort
  | Bool _ -> Bool_sort
  | Message _ -> Message_sort
  | Enum _ -> Enum_sort

module Encoding : sig
  val encode_string : string value -> t

  val decode_string : string typ -> t -> (string, [> decoding_error]) Result.t

  val encode_int : int value -> t

  val encode_int32 : int32 value -> t

  val encode_int64 : int64 value -> t

  val decode_int : int typ -> t -> (int, [> decoding_error]) Result.t

  val decode_int32 : int32 typ -> t -> (int32, [> decoding_error]) Result.t

  val decode_int64 : int64 typ -> t -> (int64, [> decoding_error]) Result.t

  val encode_float : float value -> t

  val decode_float : float typ -> t -> (float, [> decoding_error]) Result.t

  val encode_bool : bool value -> t

  val decode_bool : bool typ -> t -> (bool, [> decoding_error]) Result.t
end = struct
  let encode_string value = String (Field_value.unpack value)

  let decode_string typ value =
    match value with
    | String string -> Ok string
    | _ -> Error (`Wrong_text_value_for_string_field (to_sort value, typ))

  let encode_int value = Integer (value |> Field_value.unpack |> Int64.of_int)

  let encode_int32 value = Integer (value |> Field_value.unpack |> Int64.of_int32)

  let encode_int64 value = Integer (value |> Field_value.unpack)

  let decode_int typ value =
    match value with
    | Integer int64 -> (
      match Int64.to_int int64 with
      | None -> Error (`Integer_outside_int_type_range int64)
      | Some i -> Ok i)
    | _ -> Error (`Wrong_text_value_for_int_field (to_sort value, typ))

  let decode_int32 typ value =
    match value with
    | Integer int64 -> (
      match Int64.to_int32 int64 with
      | None -> Error (`Integer_outside_int_type_range int64)
      | Some i -> Ok i)
    | _ -> Error (`Wrong_text_value_for_int32_field (to_sort value, typ))

  let decode_int64 typ value =
    match value with
    | Integer int64 -> Ok int64
    | _ -> Error (`Wrong_text_value_for_int64_field (to_sort value, typ))

  let encode_float value = Float (value |> Field_value.unpack)

  let decode_float typ value =
    match value with
    | Float float -> (
      match typ with
      | Field_value.Float_t -> Ok (float |> Int32.bits_of_float |> Int32.float_of_bits)
      | Field_value.Double_t -> Ok float
      | _ -> .)
    | Integer int -> (
        let float = Float.of_int64 int in
        match typ with
        | Field_value.Float_t -> Ok (float |> Int32.bits_of_float |> Int32.float_of_bits)
        | Field_value.Double_t -> Ok float
        | _ -> .)
    | _ -> Error (`Wrong_text_value_for_float_field (to_sort value, typ))

  let encode_bool value = Bool (value |> Field_value.unpack)

  let decode_bool typ value =
    match value with
    | Bool bool -> Ok bool
    | _ -> Error (`Wrong_text_value_for_bool_field (to_sort value, typ))
end

module Writer = struct
  let write_value output value =
    match value with
    | String string ->
        Byte_output.write_byte output '"';
        Byte_output.write_bytes output (String.escaped string);
        Byte_output.write_byte output '"'
    | Integer int -> Int64.to_string int |> Byte_output.write_bytes output
    | Float float -> Float.to_string float |> Byte_output.write_bytes output
    | Bool bool -> Bool.to_string bool |> Byte_output.write_bytes output
    | Message encoding ->
        Byte_output.write_bytes output "{ ";
        Byte_output.write_bytes output encoding;
        Byte_output.write_byte output '}'
    | Enum name -> Byte_output.write_bytes output name

  let write_field output (id, value) =
    Byte_output.write_bytes output id;
    (match value with
    | Message _ -> Byte_output.write_bytes output " "
    | _ -> Byte_output.write_bytes output ": ");
    write_value output value;
    Byte_output.write_byte output ' '
end

module Reader = struct
  type token =
    | Whitespace of string
    | Identifier of string
    | String of string
    | Key_value_separator
    | Open_message
    | Close_message

  let token_to_string = function
    | Whitespace s -> s
    | Identifier s -> s
    | String s -> Printf.sprintf "\"%s\"" s
    | Key_value_separator -> ":"
    | Open_message -> "{"
    | Close_message -> "}"

  let is_whitespace character =
    List.exists [' '; '\t'; '\r'; '\n'] ~f:(Char.equal character)

  let is_letter character =
    Char.between ~low:'a' ~high:'z' character
    || Char.between ~low:'A' ~high:'Z' character

  let is_digit character = Char.between ~low:'0' ~high:'9' character

  let is_word_character character =
    is_letter character
    || is_digit character
    || Char.equal character '_'
    || Char.equal character '-'
    || Char.equal character '.'
    || Char.equal character '+'

  let tokenize input =
    let read_rest input character condition =
      Char.to_string character ^ Byte_input.read_while input condition
    in
    let rec collect accumulator =
      match Byte_input.read_byte input with
      | Ok character -> (
          let token =
            match character with
            | '"' -> (
                let contents =
                  let is_escaped = ref false in
                  Byte_input.read_while input (fun c ->
                      match c, !is_escaped with
                      | '"', false -> false
                      | '\\', old_is_escaped ->
                          is_escaped := not old_is_escaped;
                          true
                      | _, _ ->
                          is_escaped := false;
                          true)
                in
                match Byte_input.read_byte input with
                | Ok '"' -> Ok (String (Caml.Scanf.unescaped contents))
                | Ok character -> Error (`Unexpected_character character)
                | Error `Not_enough_bytes as error -> error)
            | '{' -> Ok Open_message
            | '}' -> Ok Close_message
            | ':' -> Ok Key_value_separator
            | _ when is_whitespace character ->
                Ok (Whitespace (read_rest input character is_whitespace))
            | _ when is_word_character character ->
                Ok (Identifier (read_rest input character is_word_character))
            | _ -> Error (`Unexpected_character character)
          in
          match token with
          | Ok t -> collect (t :: accumulator)
          | Error _ as error -> error)
      | Error `Not_enough_bytes -> Ok (List.rev accumulator)
    in
    collect []

  let rec read_key_value_pair tokens =
    match tokens with
    | Identifier key :: Key_value_separator :: Identifier literal :: rest -> (
      match literal with
      | "true" -> Ok (key, Bool true, rest)
      | "false" -> Ok (key, Bool false, rest)
      | _ -> (
        match Int64.of_string literal with
        | int -> Ok (key, Integer int, rest)
        | exception _ -> (
          match Float.of_string literal with
          | float -> Ok (key, Float float, rest)
          | exception _ -> Ok (key, Enum literal, rest))))
    | Identifier key :: Key_value_separator :: String string :: rest ->
        Ok (key, String string, rest)
    | Identifier key :: Open_message :: rest ->
        let rec consume_message acc inner_open_count tokens =
          match tokens, inner_open_count with
          | Open_message :: rest, _ ->
              consume_message (Open_message :: acc) (Int.succ inner_open_count) rest
          | Close_message :: rest, 0 ->
              Ok
                ( key,
                  Message
                    (List.rev acc |> List.map ~f:token_to_string |> String.concat ~sep:""),
                  rest )
          | Close_message :: rest, _ ->
              consume_message (Close_message :: acc) (Int.pred inner_open_count) rest
          | [], _ -> Error `Nested_message_unfinished
          | token :: rest, _ -> consume_message (token :: acc) inner_open_count rest
        in
        consume_message [] 0 rest
    | _ -> Error `Identifier_expected

  and read_key_value_pairs tokens =
    let rec collect accumulator tokens =
      match tokens with
      | [] -> Ok accumulator
      | _ -> (
        match read_key_value_pair tokens with
        | Ok (key, value, tokens) -> collect ((key, value) :: accumulator) tokens
        | Error _ as error -> error)
    in
    let tokens =
      List.filter tokens ~f:(function
          | Whitespace _ -> false
          | _ -> true)
    in
    collect [] tokens

  let read input =
    let open Result.Let_syntax in
    tokenize input >>= read_key_value_pairs
end

let encode : type v. v value -> t =
 fun value ->
  let module F = Field_value in
  let typ = F.typ value in
  match typ with
  | F.String_t -> Encoding.encode_string value
  | F.Bytes_t -> Encoding.encode_string value
  | F.Int32_t As_int -> Encoding.encode_int value
  | F.Int32_t As_int32 -> Encoding.encode_int32 value
  | F.Int64_t As_int -> Encoding.encode_int value
  | F.Int64_t As_int64 -> Encoding.encode_int64 value
  | F.Sint32_t As_int -> Encoding.encode_int value
  | F.Sint32_t As_int32 -> Encoding.encode_int32 value
  | F.Sint64_t As_int -> Encoding.encode_int value
  | F.Sint64_t As_int64 -> Encoding.encode_int64 value
  | F.Uint32_t As_int -> Encoding.encode_int value
  | F.Uint32_t As_int32 -> Encoding.encode_int32 value
  | F.Uint64_t As_int -> Encoding.encode_int value
  | F.Uint64_t As_int64 -> Encoding.encode_int64 value
  | F.Fixed32_t As_int -> Encoding.encode_int value
  | F.Fixed32_t As_int32 -> Encoding.encode_int32 value
  | F.Fixed64_t As_int -> Encoding.encode_int value
  | F.Fixed64_t As_int64 -> Encoding.encode_int64 value
  | F.Sfixed32_t As_int -> Encoding.encode_int value
  | F.Sfixed32_t As_int32 -> Encoding.encode_int32 value
  | F.Sfixed64_t As_int -> Encoding.encode_int value
  | F.Sfixed64_t As_int64 -> Encoding.encode_int64 value
  | F.Float_t -> Encoding.encode_float value
  | F.Double_t -> Encoding.encode_float value
  | F.Bool_t -> Encoding.encode_bool value

let serialize_field id typ value output =
  let open Result.Let_syntax in
  Field_value.create typ value >>| encode >>| fun value ->
  Writer.write_field output (id, value)

let serialize_optional_field id typ value output =
  match value with
  | None -> Ok ()
  | Some value -> serialize_field id typ value output

let serialize_repeated_field id typ values output =
  List.map values ~f:(fun value -> serialize_field id typ value output)
  |> Result.all_unit

let serialize_message_value id serializer value output =
  let open Result.Let_syntax in
  serializer value >>| fun encoding -> Writer.write_field output (id, Message encoding)

let serialize_message_field id serializer value output =
  match value with
  | None -> Ok ()
  | Some value -> serialize_message_value id serializer value output

let serialize_oneof_message_field = serialize_message_value

let serialize_repeated_message_field id serializer values output =
  List.map values ~f:(fun value -> serialize_message_value id serializer value output)
  |> Result.all_unit

let serialize_enum_field id to_string value output =
  let open Result.Let_syntax in
  return @@ Writer.write_field output (id, Enum (to_string value))

let serialize_repeated_enum_field id to_string values output =
  List.map values ~f:(fun value -> serialize_enum_field id to_string value output)
  |> Result.all_unit

let deserialize_message input =
  let open Result.Let_syntax in
  Reader.read input >>| fun records ->
  Hashtbl.of_alist_multi ~growth_allowed:false (module Id) records

let decode_value : type v. t -> v typ -> (v, _) Result.t =
 fun value typ ->
  let module F = Field_value in
  match typ with
  | F.String_t -> Encoding.decode_string typ value
  | F.Bytes_t -> Encoding.decode_string typ value
  | F.Int32_t As_int -> Encoding.decode_int typ value
  | F.Int32_t As_int32 -> Encoding.decode_int32 typ value
  | F.Int64_t As_int -> Encoding.decode_int typ value
  | F.Int64_t As_int64 -> Encoding.decode_int64 typ value
  | F.Sint32_t As_int -> Encoding.decode_int typ value
  | F.Sint32_t As_int32 -> Encoding.decode_int32 typ value
  | F.Sint64_t As_int -> Encoding.decode_int typ value
  | F.Sint64_t As_int64 -> Encoding.decode_int64 typ value
  | F.Uint32_t As_int -> Encoding.decode_int typ value
  | F.Uint32_t As_int32 -> Encoding.decode_int32 typ value
  | F.Uint64_t As_int -> Encoding.decode_int typ value
  | F.Uint64_t As_int64 -> Encoding.decode_int64 typ value
  | F.Fixed32_t As_int -> Encoding.decode_int typ value
  | F.Fixed32_t As_int32 -> Encoding.decode_int32 typ value
  | F.Fixed64_t As_int -> Encoding.decode_int typ value
  | F.Fixed64_t As_int64 -> Encoding.decode_int64 typ value
  | F.Sfixed32_t As_int -> Encoding.decode_int typ value
  | F.Sfixed32_t As_int32 -> Encoding.decode_int32 typ value
  | F.Sfixed64_t As_int -> Encoding.decode_int typ value
  | F.Sfixed64_t As_int64 -> Encoding.decode_int64 typ value
  | F.Float_t -> Encoding.decode_float typ value
  | F.Double_t -> Encoding.decode_float typ value
  | F.Bool_t -> Encoding.decode_bool typ value

let decode_field_value typ value =
  let open Result.Let_syntax in
  decode_value value typ >>= Field_value.create typ >>| Field_value.unpack

let decode_field id typ records =
  match Hashtbl.find records id with
  | None -> Ok (Field_value.default typ)
  | Some values -> (
    match List.last values with
    | None -> Ok (Field_value.default typ)
    | Some value -> decode_field_value typ value)

let decode_optional_field id typ records =
  let open Result.Let_syntax in
  match Hashtbl.find records id with
  | None -> Ok None
  | Some values -> (
    match List.last values with
    | None -> Ok None
    | Some value -> decode_field_value typ value >>| Option.some)

let decode_repeated_field id typ records =
  match Hashtbl.find records id with
  | None -> Ok []
  | Some values -> List.map values ~f:(decode_field_value typ) |> Result.all

let decode_message_value deserializer value =
  match value with
  | Message encoding -> deserializer encoding
  | _ as value -> Error (`Wrong_text_value_for_message_field (to_sort value))

let decode_message_field id deserializer records =
  let open Result.Let_syntax in
  match Hashtbl.find records id with
  | None -> Ok None
  | Some values -> (
    match List.last values with
    | None -> Ok None
    | Some value -> decode_message_value deserializer value >>| Option.some)

let decode_oneof_message_field id deserializer records =
  let values = Hashtbl.find_exn records id in
  decode_message_value deserializer (List.last_exn values)

let decode_repeated_message_field id deserializer records =
  match Hashtbl.find records id with
  | None -> Ok []
  | Some values -> List.map values ~f:(decode_message_value deserializer) |> Result.all

let decode_enum_value of_string = function
  | Enum name ->
      of_string name |> Result.of_option ~error:(`Unrecognized_enum_value name)
  | _ as value -> Error (`Wrong_text_value_for_enum_field (to_sort value))

let decode_enum_field id of_string default records =
  match Hashtbl.find records id with
  | None -> Ok (default ())
  | Some values -> (
    match List.last values with
    | None -> Ok (default ())
    | Some value -> decode_enum_value of_string value)

let decode_repeated_enum_field id of_string _default records =
  match Hashtbl.find records id with
  | None -> Ok []
  | Some values -> List.map values ~f:(decode_enum_value of_string) |> Result.all

let decode_oneof_field deserializers records =
  let open Result.Let_syntax in
  let applicable =
    List.filter deserializers ~f:(fun (id, _) -> Hashtbl.mem records id)
  in
  match List.length applicable with
  | 0 -> Ok None
  | 1 ->
      applicable |> List.hd_exn |> snd |> fun deserializer ->
      deserializer records >>| Option.some
  | _ -> Error (`Multiple_oneof_fields_set (List.map applicable ~f:fst))
