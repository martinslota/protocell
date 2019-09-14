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

  val serialize : t -> (string, [> Runtime.Message.serialization_error]) result

  val stringify : t -> (string, [> Runtime.Message.stringification_error]) result

  val deserialize : string -> (t, [> Runtime.Message.deserialization_error]) result

  val unstringify : string -> (t, [> Runtime.Message.unstringification_error]) result

  val name : string

  val protobuf_type_name : string

  val values_to_test : t list
end

(* FIXME take instead the protobuf message module, name of file, name of the message and the values; generate just the alcotest "success" cases without name *)
(* FIXME consider other generators that assert errors generated; perhaps just in the generated code? *)
let suite (module T : Serdes_testable) =
  let t_testable : T.t Alcotest.testable = Alcotest.testable T.pp T.equal in
  let protobuf_file_name = T.name |> String.lowercase |> Printf.sprintf "%s.proto" in
  let serdes_test value () =
    let open Result.Let_syntax in
    match value |> T.serialize >>= T.deserialize with
    (* FIXME improve messages *)
    | Ok actual -> Alcotest.(check t_testable "WTF?" value actual)
    | Error _ -> Alcotest.fail "Serdes code failed"
  in
  let stringification_test value () =
    let open Result.Let_syntax in
    match value |> T.stringify >>= T.unstringify with
    (* FIXME improve messages *)
    | Ok actual -> Alcotest.(check t_testable "WTF?" value actual)
    | Error _ -> Alcotest.fail "Stringification code failed"
  in
  let protoc_serdes_test value () =
    let open Result.Let_syntax in
    match
      T.stringify value
      >>= (fun input ->
            execute_process_with_input
              ~prog:"protoc"
              ~args:
                [Printf.sprintf "--encode=%s" T.protobuf_type_name; protobuf_file_name]
              ~input)
      >>= T.deserialize
    with
    | Error _ -> Alcotest.fail "Deserialization error"
    | Ok actual -> Alcotest.(check t_testable "WTF?" value actual)
  in
  let protoc_serdes_test2 value () =
    let open Result.Let_syntax in
    match
      T.serialize value
      >>= (fun input ->
            execute_process_with_input
              ~prog:"protoc"
              ~args:
                [Printf.sprintf "--decode=%s" T.protobuf_type_name; protobuf_file_name]
              ~input)
      >>= T.unstringify
    with
    | Error _ -> Alcotest.fail "Unstrigification error"
    | Ok actual -> Alcotest.(check t_testable "WTF?" value actual)
  in
  let value_count = List.length T.values_to_test in
  let make_tests title test_fn =
    List.mapi T.values_to_test ~f:(fun index value ->
        let test_name = Printf.sprintf "%s (%d/%d)" title (index + 1) value_count in
        Alcotest.test_case test_name `Quick @@ test_fn value)
  in
  ( T.protobuf_type_name,
    [
      make_tests "Serialize and deserialize using generated code" serdes_test;
      make_tests "Stringify and unstringify using generated code" stringification_test;
      make_tests
        "Serialize using protoc, deserialize using generated code"
        protoc_serdes_test;
      make_tests
        "Serialize using generated code, deserialize using protoc"
        protoc_serdes_test2;
    ]
    |> List.concat )
