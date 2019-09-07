open Base

type t = Byte_input.t

type error =
  [ `Varint_too_long
  | `Varint_out_of_bounds of Int64.t
  | `Invalid_string_length of int
  | Byte_input.error ]

let create = Byte_input.create

let has_more_bytes = Byte_input.has_more_bytes

let read_varint_64 input =
  let add_7_bits : bits:Int64.t -> offset:int -> value:Int64.t -> Int64.t =
   fun ~bits ~offset ~value ->
    let shift = 7 * offset in
    Int64.((bits lsl shift) lor value)
  in
  let rec add_varint_bits ~value ~offset =
    Byte_input.read_byte input
    |> Result.bind ~f:(fun character ->
           let byte = Char.to_int character in
           if offset = 9 && byte > 1
           then Error `Varint_too_long
           else
             match byte land 0x80 > 0 with
             | true ->
                 let bits = byte land 0x7f |> Int64.of_int in
                 let value = add_7_bits ~bits ~offset ~value in
                 let offset = Int.succ offset in
                 add_varint_bits ~value ~offset
             | false -> Ok (add_7_bits ~bits:(Int64.of_int byte) ~offset ~value))
  in
  add_varint_bits ~value:Int64.zero ~offset:0

let read_varint input =
  match read_varint_64 input with
  | Ok value -> (
    match Int64.to_int value with
    | None -> Error (`Varint_out_of_bounds value)
    | Some value -> Ok value)
  | Error _ as error -> error

let read_string input =
  let open Result.Let_syntax in
  read_varint input >>= function
  | string_length when string_length < 0 -> Error (`Invalid_string_length string_length)
  | string_length -> Byte_input.read_bytes input string_length
