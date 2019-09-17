open Base

type t =
  | Integer of int64
  | String of string

type sort =
  | Integer_sort
  | String_sort

type id = string

type records = (id * t) list

module Id = String

let to_sort = function
  | Integer _ -> Integer_sort
  | String _ -> String_sort

module Encoding : Types.Encoding with type t := t with type sort := sort = struct
  let encode_int value = Integer (value |> Field_value.unpack |> Int64.of_int)

  let decode_int typ value =
    match value with
    | Integer int64 -> (
      match Int64.to_int int64 with
      | None -> Error (`Integer_outside_int_type_range int64)
      | Some i -> Ok i)
    | String _ -> Error (`Wrong_value_sort_for_int_field (to_sort value, typ))

  let encode_string value = String (Field_value.unpack value)

  let decode_string typ value =
    match value with
    | String string -> Ok string
    | Integer _ -> Error (`Wrong_value_sort_for_string_field (to_sort value, typ))
end

module Writer = struct
  let write_value output value =
    match value with
    | Integer int -> Int64.to_string int |> Byte_output.write_bytes output
    | String string ->
        Byte_output.write_byte output '"';
        Byte_output.write_bytes output (String.escaped string);
        Byte_output.write_byte output '"'

  let write output records =
    List.iter records ~f:(fun (field_name, value) ->
        Byte_output.write_bytes output field_name;
        Byte_output.write_bytes output ": ";
        write_value output value;
        Byte_output.write_byte output '\n')
end

let write_records = Writer.write

module Reader = struct
  type token =
    | Whitespace of string
    | Identifier of string
    | String of string
    | Key_value_separator
    | Open_message
    | Close_message

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

  type error =
    [ `Unexpected_character of char
    | `Invalid_number_string of string
    | `Identifier_expected
    | Byte_input.error ]

  let read_key_value_pair tokens =
    match tokens with
    | Identifier key :: Key_value_separator :: Identifier number_string :: rest -> (
      match Int64.of_string number_string with
      | exception _ -> Error (`Invalid_number_string number_string)
      | int -> Ok (key, Integer int, rest))
    | Identifier key :: Key_value_separator :: String string :: rest ->
        Ok (key, String string, rest)
    | _ -> Error `Identifier_expected

  let read_key_value_pairs tokens =
    let rec collect accumulator tokens =
      match tokens with
      | [] -> Ok (List.rev accumulator)
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

type read_error = Reader.error

let read_records = Reader.read

let encode : type v. v Field_value.t -> t =
 fun value ->
  let typ = Field_value.typ value in
  match typ with
  | I32 -> Encoding.encode_int value
  | I64 -> Encoding.encode_int value
  | S32 -> Encoding.encode_int value
  | S64 -> Encoding.encode_int value
  | U32 -> Encoding.encode_int value
  | U64 -> Encoding.encode_int value
  | String -> Encoding.encode_string value

let decode_one : t -> Field_variable.cloaked -> (unit, _) Result.t =
 fun value (Cloak spot) ->
  let typ = Field_variable.typ spot in
  let set_spot = Result.bind ~f:(fun value -> Field_variable.set spot value) in
  match typ with
  | I32 -> Encoding.decode_int typ value |> set_spot
  | I64 -> Encoding.decode_int typ value |> set_spot
  | S32 -> Encoding.decode_int typ value |> set_spot
  | S64 -> Encoding.decode_int typ value |> set_spot
  | U32 -> Encoding.decode_int typ value |> set_spot
  | U64 -> Encoding.decode_int typ value |> set_spot
  | String -> Encoding.decode_string typ value |> set_spot

let decode_all values variables =
  let wire_records = Hashtbl.of_alist_multi ~growth_allowed:false (module Id) values in
  List.map variables ~f:(fun (id, cloaked_spot) ->
      match Hashtbl.find wire_records id with
      | None -> Ok ()
      | Some [] -> Ok ()
      | Some (value :: _) -> decode_one value cloaked_spot)
  |> Result.all_unit

type serialization_error = Field_value.validation_error

let serialize fields =
  Result.all fields
  |> Result.map_error ~f:Field_value.relax_error
  |> Result.map ~f:(fun values ->
         let output = Byte_output.create () in
         write_records output values; Byte_output.contents output)

type deserialization_error =
  [ read_error
  | sort Types.decoding_error
  | Field_value.validation_error ]

let deserialize bytes decoders =
  Byte_input.create bytes |> read_records |> Result.bind ~f:(Fn.flip decode_all decoders)
