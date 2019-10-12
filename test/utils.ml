open Core

type process_error = [`Process_execution_error of string]

let execute_process_with_input ~prog ~args ~input =
  let process = Unix.create_process ~prog ~args in
  let standard_out = Unix.in_channel_of_descr process.stdout in
  let standard_in = Unix.out_channel_of_descr process.stdin in
  let () = Stdio.Out_channel.output_string standard_in input in
  let () = Stdio.Out_channel.close standard_in in
  let output = Stdio.In_channel.input_all standard_out in
  let code_or_signal = Unix.waitpid process.pid in
  let () = Stdio.In_channel.close standard_out in
  let () = Unix.close process.stderr in
  match Unix.Exit_or_signal.or_error code_or_signal with
  | Ok () -> Ok output
  | Error error -> Error (`Process_execution_error (Error.to_string_hum error))

module type Serdes_testable = sig
  type t [@@deriving eq, show]

  val to_binary : t -> (string, [> Runtime.Binary_format.serialization_error]) result

  val of_binary : string -> (t, [> Runtime.Binary_format.deserialization_error]) result

  val to_text : t -> (string, [> Runtime.Text_format.serialization_error]) result

  val of_text : string -> (t, [> Runtime.Text_format.deserialization_error]) result
end

let process_error_to_string = function
  | `Process_execution_error message ->
      Printf.sprintf "Process execution error: %s" message

let binary_error_to_string = function
  | #process_error as e -> process_error_to_string e
  | #Runtime.Binary_format.deserialization_error as e ->
      Runtime.Binary_format.show_deserialization_error e

let text_error_to_string = function
  | #process_error as e -> process_error_to_string e
  | #Runtime.Text_format.deserialization_error as e ->
      Runtime.Text_format.show_deserialization_error e

let make_tests title test_fn values_to_test =
  let value_count = List.length values_to_test in
  List.mapi values_to_test ~f:(fun index value ->
      let test_name = Printf.sprintf "%s (%d/%d)" title index (value_count - 1) in
      Alcotest.test_case test_name `Quick @@ test_fn value)

let invariant_suite (type t) (module T : Serdes_testable with type t = t)
    protobuf_type_name values_to_test
  =
  let t_testable : T.t Alcotest.testable = Alcotest.testable T.pp T.equal in
  let protobuf_file_name = "test.proto" in
  let binary_format_roundtrip value () =
    let open Result.Let_syntax in
    match value |> T.to_binary >>= T.of_binary with
    | Ok actual ->
        Alcotest.(check t_testable "to_binary |> of_binary mismatch" value actual)
    | Error e -> Alcotest.fail (binary_error_to_string e)
  in
  let text_format_roundtrip value () =
    let open Result.Let_syntax in
    match value |> T.to_text >>= T.of_text with
    | Ok actual -> Alcotest.(check t_testable "to_text |> of_text mismatch" value actual)
    | Error e -> Alcotest.fail (text_error_to_string e)
  in
  let decode_protoc_binary_output value () =
    let open Result.Let_syntax in
    match
      T.to_text value
      >>= (fun input ->
            execute_process_with_input
              ~prog:"protoc"
              ~args:[Printf.sprintf "--encode=%s" protobuf_type_name; protobuf_file_name]
              ~input)
      >>= T.of_binary
    with
    | Ok actual ->
        Alcotest.(
          check t_testable "to_text |> protoc |> of_binary mismatch" value actual)
    | Error e -> Alcotest.fail (binary_error_to_string e)
  in
  let generate_protoc_binary_input value () =
    let open Result.Let_syntax in
    match
      T.to_binary value
      >>= (fun input ->
            execute_process_with_input
              ~prog:"protoc"
              ~args:[Printf.sprintf "--decode=%s" protobuf_type_name; protobuf_file_name]
              ~input)
      >>= T.of_text
    with
    | Ok actual ->
        Alcotest.(
          check t_testable "to_binary |> protoc |> of_text mismatch" value actual)
    | Error e -> Alcotest.fail (text_error_to_string e)
  in
  ( protobuf_type_name,
    [
      make_tests "Invariant: to_binary |> of_binary is identity" binary_format_roundtrip;
      make_tests "Invariant: to_text |> of_text is identity" text_format_roundtrip;
      make_tests
        "Invariant: to_text |> protoc |> of_binary is identity"
        decode_protoc_binary_output;
      make_tests
        "Invariant: to_binary |> protoc |> of_text is identity"
        generate_protoc_binary_input;
    ]
    |> List.map ~f:(fun test -> test values_to_test)
    |> List.concat )
