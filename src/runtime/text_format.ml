open Base

type wire_value = Types.wire_value =
  | Varint of int
  | Length_delimited of string

module Writer = struct
  let stringify : wire_value -> Byte_output.t -> unit =
   fun value buffer ->
    match value with
    | Varint int -> Int.to_string int |> Byte_output.write_bytes buffer
    | Length_delimited string ->
        Byte_output.write_byte buffer '"';
        Byte_output.write_bytes buffer (Caml.String.escaped string);
        Byte_output.write_byte buffer '"'

  let append_all buffer values =
    List.iter values ~f:(fun (field_name, value) ->
        Byte_output.write_bytes buffer field_name;
        Byte_output.write_bytes buffer ": ";
        stringify value buffer;
        Byte_output.write_byte buffer '\n')
end

module Reader = struct
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

  type token =
    | Whitespace of string
    | Identifier of string
    | String of string
    | Key_value_separator
    | Open_message
    | Close_message

  let tokenize stream =
    let read_rest stream character condition =
      Char.to_string character ^ Byte_input.read_while stream condition
    in
    let rec collect accumulator =
      match Byte_input.read_byte stream with
      | Ok character -> (
          let token =
            match character with
            | '"' -> (
                let contents =
                  Byte_input.read_while stream (fun c -> not (Char.equal c '"'))
                in
                match Byte_input.read_byte stream with
                | Ok '"' -> Ok (String (Caml.Scanf.unescaped contents))
                | Ok character -> Error (`Unexpected_character character)
                | Error `Not_enough_bytes as error -> error)
            | '{' -> Ok Open_message
            | '}' -> Ok Close_message
            | ':' -> Ok Key_value_separator
            | _ when is_whitespace character ->
                Ok (Whitespace (read_rest stream character is_whitespace))
            | _ when is_word_character character ->
                Ok (Identifier (read_rest stream character is_word_character))
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
      match Int.of_string number_string with
      | exception _ -> Error (`Invalid_number_string number_string)
      | int -> Ok (key, Varint int, rest))
    | Identifier key :: Key_value_separator :: String string :: rest ->
        Ok (key, Length_delimited string, rest)
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

  let read_all stream =
    let open Result.Let_syntax in
    tokenize stream >>= read_key_value_pairs
end
