open Base
module Byte_input = Byte_input
module Wire_format = Wire_format

type wire_value = Text_format.wire_value =
  | Varint of int
  | Length_delimited of string

module Field = struct
  type field_value =
    | Int32 of int
    | Int64 of int
    | String of string

  let field_value_to_wire_value = function
    | Int32 value | Int64 value -> Varint value
    | String value -> Length_delimited value

  let to_wire_values field_values =
    List.map field_values ~f:(fun (field_number, field_value) ->
        field_number, field_value_to_wire_value field_value)

  type decoding_error = [`Wrong_wire_type]

  type 'a decoding_result = ('a, decoding_error) Result.t

  type 'a decoder = {
    value : 'a ref;
    read : wire_value -> 'a decoding_result;
  }

  let int_32_decoder () =
    let read = function
      | Varint value -> Ok value
      (* FIXME out of range problems caught here *)
      | Length_delimited _ -> Error `Wrong_wire_type
    in
    {value = ref 0; read}

  let int_64_decoder () =
    let read = function
      | Varint value -> Ok value
      | Length_delimited _ -> Error `Wrong_wire_type
    in
    {value = ref 0; read}

  let string_decoder () =
    let read = function
      | Varint _ -> Error `Wrong_wire_type
      | Length_delimited value -> Ok value
    in
    {value = ref ""; read}

  let consume : 'a decoder -> wire_value -> (unit, _) Result.t =
   fun {value; read} input ->
    match read input with
    | Ok v ->
        value := v;
        Ok ()
    | Error _ as error -> error

  let value {value; _} = !value
end

module Message = struct
  let serialize : (int * Field.field_value) list -> string =
   fun fields ->
    let wire_values = Field.to_wire_values fields in
    let output = Byte_output.create () in
    Wire_format.Writer.append_all output wire_values;
    Byte_output.contents output

  type e1 =
    [ Field.decoding_error
    | Wire_format.Reader.error ]

  let mape = function
    | `Wrong_wire_type as v -> v

  let deserialize
      :  string -> (int * (wire_value -> (unit, Field.decoding_error) Result.t)) list ->
      (unit, e1) Result.t
    =
   fun bytes field_deserializers ->
    let input = Byte_input.create bytes in
    match Wire_format.Reader.read_all input with
    | Error _ as error -> error
    | Ok wire_records -> (
        let wire_records =
          Hashtbl.of_alist_multi ~growth_allowed:false (module Int) wire_records
        in
        match
          List.map field_deserializers ~f:(fun (expected_field_number, deserializer) ->
              match Hashtbl.find wire_records expected_field_number with
              | None -> Ok ()
              | Some [] -> Ok ()
              | Some (value :: _) -> deserializer value)
          |> Result.all_unit
        with
        | Error e -> Error (mape e)
        | Ok () -> Ok ())

  let stringify : (string * Field.field_value) list -> string =
   fun fields ->
    let wire_values = Field.to_wire_values fields in
    let output = Byte_output.create () in
    Text_format.Writer.append_all output wire_values;
    Byte_output.contents output

  type e2 =
    [ Field.decoding_error
    | Text_format.Reader.error ]

  let unstringify
      :  string ->
      (string * (wire_value -> (unit, Field.decoding_error) Result.t)) list ->
      (unit, e2) Result.t
    =
   fun bytes field_deserializers ->
    let stream = Byte_input.create bytes in
    match Text_format.Reader.read_all stream with
    | Error _ as error -> error
    | Ok records -> (
        let records =
          Hashtbl.of_alist_multi ~growth_allowed:false (module String) records
        in
        match
          List.map field_deserializers ~f:(fun (expected_field_name, deserializer) ->
              match Hashtbl.find records expected_field_name with
              | None -> Ok ()
              | Some [] -> Ok ()
              | Some (value :: _) -> deserializer value)
          |> Result.all_unit
        with
        | Error e -> Error (mape e)
        | Ok () -> Ok ())
end
