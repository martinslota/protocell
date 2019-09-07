open Base

type t = Byte_stream.t

type error = Byte_stream.error

let create = Byte_stream.create

let has_more_bytes = Byte_stream.has_more_bytes

(* FIXME how about bit overflow? *)
let read_varint reader =
  let add c (acc : int) shift =
    let shft = 7 * shift in
    acc + (c lsl shft)
  in
  let rec loop (acc : int) shift =
    let open Result.Let_syntax in
    let c = Byte_stream.read_byte reader in
    c >>= fun c ->
    match Char.to_int c land 0x80 > 0 with
    | true -> loop (add (Char.to_int c land 0x7f) acc shift) (Int.succ shift)
    | false -> return @@ add (Char.to_int c) acc shift
  in
  loop 0 0

let read_string reader =
  let open Result.Let_syntax in
  read_varint reader >>= fun string_length -> Byte_stream.read_bytes reader string_length
