open Base
module Byte_input = Byte_input
module Wire_format = Wire_format

type wire_value = Types.wire_value =
  | Varint of int64
  | Length_delimited of string

module Field = struct
  type value =
    | Int32 of int
    | Int64 of int
    | String of string

  let field_value_to_wire_value = function
    | Int32 value | Int64 value -> Varint (Int64.of_int value)
    | String value -> Length_delimited value

  let to_wire_values field_values =
    List.map field_values ~f:(fun (field_number, field_value) ->
        field_number, field_value_to_wire_value field_value)

  type decoding_error = [`Wrong_wire_type]

  type decoding_result = (unit, decoding_error) Result.t

  type decoder = wire_value -> decoding_result

  type 'a cell = {
    value : 'a ref;
    decode : decoder;
  }

  let int_32_cell () =
    let value = ref 0 in
    let decode = function
      | Varint i ->
          value := Int64.to_int_exn i;
          Ok ()
      (* FIXME out of range problems caught here *)
      | Length_delimited _ -> Error `Wrong_wire_type
    in
    {value; decode}

  let int_64_cell () =
    let value = ref 0 in
    let decode = function
      | Varint i ->
          value := Int64.to_int_exn i;
          Ok ()
      | Length_delimited _ -> Error `Wrong_wire_type
    in
    {value; decode}

  let string_cell () =
    let value = ref "" in
    let decode = function
      | Varint _ -> Error `Wrong_wire_type
      | Length_delimited s ->
          value := s;
          Ok ()
    in
    {value; decode}

  let relax_error = function
    | `Wrong_wire_type as v -> v

  let deserialize field_deserializers key_module wire_records =
    let wire_records =
      Hashtbl.of_alist_multi ~growth_allowed:false key_module wire_records
    in
    match
      List.map field_deserializers ~f:(fun (expected_field_number, deserializer) ->
          match Hashtbl.find wire_records expected_field_number with
          | None -> Ok ()
          | Some [] -> Ok ()
          | Some (value :: _) -> deserializer value)
      |> Result.all_unit
    with
    | Error e -> Error (relax_error e)
    | Ok () -> Ok ()
end

module Message = struct
  let serialize : (int * Field.value) list -> string =
   fun fields ->
    let wire_values = Field.to_wire_values fields in
    let output = Byte_output.create () in
    Wire_format.Writer.write_values output wire_values;
    Byte_output.contents output

  type deserialization_error =
    [ Wire_format.Reader.error
    | Field.decoding_error ]

  let deserialize
      : string -> (int * Field.decoder) list -> (unit, deserialization_error) Result.t
    =
   fun bytes field_deserializers ->
    let open Result.Let_syntax in
    let input = Byte_input.create bytes in
    Wire_format.Reader.read_values input
    >>= Field.deserialize field_deserializers (module Int)

  let stringify : (string * Field.value) list -> string =
   fun fields ->
    let wire_values = Field.to_wire_values fields in
    let output = Byte_output.create () in
    Text_format.Writer.write_values output wire_values;
    Byte_output.contents output

  type unstringification_error =
    [ Text_format.Reader.error
    | Field.decoding_error ]

  let unstringify
      :  string -> (string * Field.decoder) list ->
      (unit, unstringification_error) Result.t
    =
   fun bytes field_deserializers ->
    let open Result.Let_syntax in
    let input = Byte_input.create bytes in
    Text_format.Reader.read_values input
    >>= Field.deserialize field_deserializers (module String)
end
