open Base

type value =
  | Integer of int64
  | String of string

type t = (string * value) list

module Writer = struct
  let write_value output value =
    match value with
    | Integer int -> Int64.to_string int |> Byte_output.write_bytes output
    | String string ->
        Byte_output.write_byte output '"';
        Byte_output.write_bytes output (String.escaped string);
        Byte_output.write_byte output '"'

  let write_values output values =
    List.iter values ~f:(fun (field_name, value) ->
        Byte_output.write_bytes output field_name;
        Byte_output.write_bytes output ": ";
        write_value output value;
        Byte_output.write_byte output '\n')
end

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

  let read_values input =
    let open Result.Let_syntax in
    tokenize input >>= read_key_value_pairs
end
