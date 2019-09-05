open Base

type t = {
  bytes : string;
  byte_count : int;
  position : int ref;
}

type error = [`No_more_bytes]

let create bytes = {bytes; byte_count = String.length bytes; position = ref 0}

let has_more_bytes {byte_count; position; _} = !position < byte_count

let read_byte {bytes; byte_count; position} =
  match !position < byte_count with
  | true ->
      let result = bytes.[!position] in
      Int.incr position; Ok result
  | false -> Error `No_more_bytes

(* FIXME how about bit overflow? *)
let read_varint input =
  let add c (acc : int) shift =
    let shft = 7 * shift in
    acc + (c lsl shft)
  in
  let rec loop (acc : int) shift =
    let open Result.Let_syntax in
    let c = read_byte input in
    c >>= fun c ->
    match Char.to_int c land 0x80 > 0 with
    | true -> loop (add (Char.to_int c land 0x7f) acc shift) (Int.succ shift)
    | false -> return @@ add (Char.to_int c) acc shift
  in
  loop 0 0

let read_string ({bytes; byte_count; position} as input) =
  let open Result.Let_syntax in
  let string_length = read_varint input in
  string_length >>= fun string_length ->
  match !position + string_length <= byte_count with
  | true ->
      let result = String.sub bytes ~pos:!position ~len:string_length in
      position := !position + string_length;
      Ok result
  | false -> Error `No_more_bytes
