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
  | Error _ -> Error (Unix.Exit_or_signal.to_string_hum code_or_signal)

module type Serdes_testable = sig
  type t [@@deriving eq, show]

  val serialize : t -> string

  val stringify : t -> string

  val deserialize : string -> (t, Runtime.Message.e1) result

  val unstringify : string -> (t, Runtime.Message.e2) result

  val name : string

  val protobuf_type_name : string

  val values_to_test : t list
end

module Suite (T : Serdes_testable) = struct
  let t_testable : T.t Alcotest.testable = Alcotest.testable T.pp T.equal

  let protobuf_file_name = T.name |> String.lowercase |> Printf.sprintf "%s.proto"

  let serdes_test value () =
    match value |> T.serialize |> T.deserialize with
    | Ok actual -> Alcotest.(check t_testable "WTF?" value actual)
    | Error _ -> Alcotest.fail "Serdes code failed"

  let stringification_test value () =
    match value |> T.stringify |> T.unstringify with
    | Ok actual -> Alcotest.(check t_testable "WTF?" value actual)
    | Error _ -> Alcotest.fail "Stringification code failed"

  let protoc_serdes_test value () =
    match
      execute_process_with_input
        ~prog:"protoc"
        ~args:[Printf.sprintf "--encode=%s" T.protobuf_type_name; protobuf_file_name]
        ~input:(T.stringify value)
    with
    | Error error -> Alcotest.fail error
    | Ok output -> (
      match T.deserialize output with
      | Error _ -> Alcotest.fail "Deserialization error"
      | Ok actual -> Alcotest.(check t_testable "WTF?" value actual))

  let protoc_serdes_test2 value () =
    match
      execute_process_with_input
        ~prog:"protoc"
        ~args:[Printf.sprintf "--decode=%s" T.protobuf_type_name; protobuf_file_name]
        ~input:(T.serialize value)
    with
    | Error error -> Alcotest.fail error
    | Ok output -> (
      match T.unstringify output with
      | Error _ -> Alcotest.fail "Unstrigification error"
      | Ok actual -> Alcotest.(check t_testable "WTF?" value actual))

  let tests =
    let value_count = List.length T.values_to_test in
    ( T.protobuf_type_name,
      [
        List.mapi T.values_to_test ~f:(fun index value ->
            let test_name =
              Printf.sprintf
                "Serialize and deserialize using generated code (%d/%d)"
                (index + 1)
                value_count
            in
            Alcotest.test_case test_name `Quick @@ serdes_test value);
        List.mapi T.values_to_test ~f:(fun index value ->
            let test_name =
              Printf.sprintf
                "Stringify and unstringify using generated code (%d/%d)"
                (index + 1)
                value_count
            in
            Alcotest.test_case test_name `Quick @@ stringification_test value);
        List.mapi T.values_to_test ~f:(fun index value ->
            let test_name =
              Printf.sprintf
                "Serialize using protoc, deserialize using generated code (%d/%d)"
                (index + 1)
                value_count
            in
            Alcotest.test_case test_name `Quick @@ protoc_serdes_test value);
        List.mapi T.values_to_test ~f:(fun index value ->
            let test_name =
              Printf.sprintf
                "Serialize using generated code, deserialize using protoc (%d/%d)"
                (index + 1)
                value_count
            in
            Alcotest.test_case test_name `Quick @@ protoc_serdes_test2 value);
      ]
      |> List.concat )
end
