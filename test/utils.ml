open Core

let execute_process_with_input ~prog ~args ~input =
  let process = Unix.create_process ~prog ~args in
  let standard_out = Unix.in_channel_of_descr process.stdout in
  let standard_in = Unix.out_channel_of_descr process.stdin in
  let () = Stdio.Out_channel.output_string standard_in input in
  let () = Stdio.Out_channel.close standard_in in
  let output = Stdio.In_channel.input_all standard_out in
  let code_or_signal = Unix.waitpid process.pid in
  match Unix.Exit_or_signal.or_error code_or_signal with
  | Ok () -> Ok output
  | Error error -> Error (`Process_execution_error (Error.to_string_hum error))

module type Serdes_testable = sig
  type t [@@deriving eq, show]

  val serialize : t -> (string, [> Runtime.Wire_format.serialization_error]) result

  val deserialize : string -> (t, [> Runtime.Wire_format.deserialization_error]) result

  val stringify : t -> (string, [> Runtime.Text_format.serialization_error]) result

  val unstringify : string -> (t, [> Runtime.Text_format.deserialization_error]) result
end

let suite (type t) (module T : Serdes_testable with type t = t) name protobuf_type_name
    values_to_test
  =
  let t_testable : T.t Alcotest.testable = Alcotest.testable T.pp T.equal in
  let protobuf_file_name = name |> String.lowercase |> Printf.sprintf "%s.proto" in
  let wire_format_roundtrip value () =
    let open Result.Let_syntax in
    match value |> T.serialize >>= T.deserialize with
    | Ok actual ->
        Alcotest.(check t_testable "serialize |> deserialize mismatch" value actual)
    | Error _ -> Alcotest.fail "serialize |> deserialize failure"
  in
  let text_format_roundtrip value () =
    let open Result.Let_syntax in
    match value |> T.stringify >>= T.unstringify with
    | Ok actual ->
        Alcotest.(check t_testable "stringify |> unstringify mismatch" value actual)
    | Error _ -> Alcotest.fail "stringify |> unstringify failure"
  in
  let deserialize_protoc_wire_output value () =
    let open Result.Let_syntax in
    match
      T.stringify value
      >>= (fun input ->
            execute_process_with_input
              ~prog:"protoc"
              ~args:[Printf.sprintf "--encode=%s" protobuf_type_name; protobuf_file_name]
              ~input)
      >>= T.deserialize
    with
    | Ok actual ->
        Alcotest.(
          check t_testable "stringify |> protoc |> deserialize mismatch" value actual)
    | Error _ -> Alcotest.fail "stringify |> protoc |> deserialize failure"
  in
  let serialize_protoc_wire_input value () =
    let open Result.Let_syntax in
    match
      T.serialize value
      >>= (fun input ->
            execute_process_with_input
              ~prog:"protoc"
              ~args:[Printf.sprintf "--decode=%s" protobuf_type_name; protobuf_file_name]
              ~input)
      >>= T.unstringify
    with
    | Ok actual ->
        Alcotest.(
          check t_testable "serialize |> protoc |> unstringify mismatch" value actual)
    | Error _ -> Alcotest.fail "serialize |> protoc |> unstringify failure"
  in
  let value_count = List.length values_to_test in
  let make_tests title test_fn =
    List.mapi values_to_test ~f:(fun index value ->
        let test_name = Printf.sprintf "%s (%d/%d)" title (index + 1) value_count in
        Alcotest.test_case test_name `Quick @@ test_fn value)
  in
  ( protobuf_type_name,
    [
      make_tests "Serialize and deserialize using generated code" wire_format_roundtrip;
      make_tests "Stringify and unstringify using generated code" text_format_roundtrip;
      make_tests
        "Serialize using protoc, deserialize using generated code"
        deserialize_protoc_wire_output;
      make_tests
        "Serialize using generated code, deserialize using protoc"
        serialize_protoc_wire_input;
    ]
    |> List.concat )
