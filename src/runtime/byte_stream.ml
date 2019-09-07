open Base

type t = {
  bytes : string;
  byte_count : int;
  position : int ref;
}

type error = [`No_more_bytes]

let create bytes = {bytes; byte_count = String.length bytes; position = ref 0}

let has_more_bytes {byte_count; position; _} = !position < byte_count

let peek_byte {bytes; byte_count; position} =
  match !position < byte_count with
  | true -> Ok bytes.[!position]
  | false -> Error `No_more_bytes

let read_byte {bytes; byte_count; position} =
  match !position < byte_count with
  | true ->
      let result = bytes.[!position] in
      Int.incr position; Ok result
  | false -> Error `No_more_bytes

let read_bytes {bytes; byte_count; position} count =
  match !position + count <= byte_count with
  | true ->
      let result = String.sub bytes ~pos:!position ~len:count in
      position := !position + count;
      Ok result
  | false -> Error `No_more_bytes

let read_if reader condition =
  match peek_byte reader with
  | Ok character when condition character -> (
    match read_byte reader with
    | Ok character -> Ok (Some character)
    | Error _ as error -> error)
  | Ok _ -> Ok None
  | Error _ as error -> error

let read_while reader condition =
  let rec collect accumulator =
    match read_if reader condition with
    | Ok (Some character) -> collect (character :: accumulator)
    | Ok None | Error `No_more_bytes -> accumulator |> List.rev |> String.of_char_list
  in
  collect []
