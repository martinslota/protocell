open Base

let append_varint : Buffer.t -> int -> unit =
 fun f i ->
  let rec loop b =
    if b > 0x7f
    then (
      let byte = b land 0x7f in
      Buffer.add_char f (byte lor 128 |> Char.of_int_exn);
      loop (b lsr 7))
    else Buffer.add_char f (b |> Char.of_int_exn)
  in
  loop i

module Input = struct
  type t = {
    bytes : string;
    position : int ref;
  }

  let get {bytes; position} =
    let result = bytes.[!position] in
    Int.incr position; result
end

let read_varint : Input.t -> int =
 fun input ->
  let add c (acc : int) shift =
    let shft = 7 * shift in
    acc + (c lsl shft)
  in
  let rec loop (acc : int) shift =
    let c = Input.get input in
    if Char.to_int c land 0x80 > 0
    then loop (add (Char.to_int c land 0x7f) acc shift) (Int.succ shift)
    else add (Char.to_int c) acc shift
  in
  loop 0 0
