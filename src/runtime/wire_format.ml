open Base

type wire_value = Types.wire_value =
  | Varint of int64
  | Length_delimited of string

type wire_type = Types.wire_type =
  | Varint_type
  | Length_delimited_type

let wire_type_to_id = function
  | Varint_type -> 0
  | Length_delimited_type -> 2

module Writer = struct
  let seven_bit_mask = Int64.of_int 0b0111_1111

  let eighth_bit = Int64.of_int 0b1000_0000

  let write_varint_64 output value =
    let open Int64 in
    let write_byte byte =
      byte |> to_int_exn |> Char.of_int_exn |> Byte_output.write_byte output
    in
    let rec append_rest value =
      let lower_seven_bits = value land seven_bit_mask in
      match value = lower_seven_bits with
      | true -> write_byte lower_seven_bits
      | false ->
          write_byte (lower_seven_bits lor eighth_bit);
          append_rest (value lsr 7)
    in
    append_rest value

  let write_varint output value = value |> Int64.of_int |> write_varint_64 output

  let write_value buffer field_number wire_value =
    let wire_type = Types.wire_value_to_type wire_value in
    let wire_type_id = wire_type_to_id wire_type in
    let wire_descriptor = (field_number lsl 3) lor wire_type_id in
    write_varint buffer wire_descriptor;
    match wire_value with
    | Varint int -> write_varint_64 buffer int
    | Length_delimited bytes ->
        let length = String.length bytes in
        write_varint buffer length;
        Byte_output.write_bytes buffer bytes

  let write_values output values =
    List.iter values ~f:(fun (field_number, wire_value) ->
        write_value output field_number wire_value)
end

module Reader = struct
  type error =
    [ `Unknown_wire_type of int
    | `Varint_out_of_bounds of int64
    | `Varint_too_long
    | `Invalid_string_length of int
    | Byte_input.error ]

  let read_varint_64 input =
    let add_7_bits : bits:int64 -> offset:int -> value:int64 -> int64 =
     fun ~bits ~offset ~value ->
      let shift = 7 * offset in
      Int64.((bits lsl shift) lor value)
    in
    let rec add_varint_bits ~value ~offset =
      Byte_input.read_byte input
      |> Result.bind ~f:(fun character ->
             let byte = Char.to_int character in
             match offset = 9 && byte > 1 with
             | true -> Error `Varint_too_long
             | false -> (
               match byte land 0x80 > 0 with
               | true ->
                   let bits = byte land 0x7f |> Int64.of_int in
                   let value = add_7_bits ~bits ~offset ~value in
                   let offset = Int.succ offset in
                   add_varint_bits ~value ~offset
               | false -> Ok (add_7_bits ~bits:(Int64.of_int byte) ~offset ~value)))
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
    | string_length when string_length < 0 ->
        Error (`Invalid_string_length string_length)
    | string_length -> Byte_input.read_bytes input string_length

  let read_values input =
    let rec collect_all () =
      let open Result.Let_syntax in
      match Byte_input.has_more_bytes input with
      | false -> []
      | true ->
          let wire_record =
            read_varint input >>= fun wire_descriptor ->
            let wire_type = wire_descriptor land 0x7 in
            let field_number = wire_descriptor lsr 3 in
            (match wire_type with
            | 0 -> read_varint_64 input >>| fun int -> Varint int
            | 2 -> read_string input >>| fun bytes -> Length_delimited bytes
            | _ -> Error (`Unknown_wire_type wire_type))
            >>| fun wire_value -> field_number, wire_value
          in
          wire_record :: collect_all ()
    in
    collect_all () |> Result.all
end
