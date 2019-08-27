open Core
module F' = Runtime.Field
module M' = Runtime.Message
module Message_name = Test_pb.Message_name

let t : Message_name.t Alcotest.testable =
  let fmt =
    Fmt.of_to_string (fun Message_name.{int_field; string_field} ->
        Printf.sprintf "int_field = %d; string_field = %s" int_field string_field)
  in
  let equal m1 m2 =
    m1.Message_name.int_field = m2.Message_name.int_field
    && String.equal m1.string_field m2.string_field
  in
  Alcotest.testable fmt equal

let serdes_test () =
  let expected = Message_name.{int_field = 42; string_field = "hey there!"} in
  match expected |> Message_name.serialize |> Message_name.deserialize with
  | Ok actual -> Alcotest.(check t "WTF?" expected actual)
  | Error _ -> Alcotest.fail "Serdes code failed"

let () =
  let p =
    Unix.create_process ~prog:"protoc" ~args:["--decode=Message_name"; "test_pb.proto"]
  in
  let i = Unix.in_channel_of_descr p.stdout in
  let o = Unix.out_channel_of_descr p.stdin in
  let m = Message_name.{int_field = 42; string_field = "hey there!"} in
  let e = Message_name.serialize m in
  let () = Stdio.Out_channel.output_string o e in
  let () = Stdio.Out_channel.close o in
  let lines = Stdio.In_channel.input_lines i in
  let s = Unix.waitpid p.pid in
  Stdio.print_endline @@ Unix.Exit_or_signal.to_string_hum s;
  Stdio.print_endline @@ String.concat ~sep:"\n" lines;
  ()

let () =
  let p =
    Unix.create_process ~prog:"protoc" ~args:["--encode=Message_name"; "test_pb.proto"]
  in
  let i = Unix.in_channel_of_descr p.stdout in
  let o = Unix.out_channel_of_descr p.stdin in
  let m = Message_name.{int_field = 42; string_field = "hey there!"} in
  let e = Message_name.stringify m in
  Stdio.printf "Input: %s" e;
  let () = Stdio.Out_channel.output_string o e in
  let () = Stdio.Out_channel.close o in
  let serialized = Stdio.In_channel.input_all i in
  let s = Unix.waitpid p.pid in
  Stdio.print_endline @@ Unix.Exit_or_signal.to_string_hum s;
  let serialized2 = Message_name.serialize m in
  Stdio.printf "serialized: %s" (String.escaped serialized);
  Stdio.printf "serialized2: %s" (String.escaped serialized2);
  match Message_name.deserialize serialized with
  | Error _ -> Stdio.print_endline "Error"
  | Ok mmm ->
      Stdio.print_endline @@ Message_name.stringify mmm;
      ()

let () =
  Alcotest.run
    "protocell test suite"
    ["", [Alcotest.test_case "Basic serdes test" `Quick serdes_test]]
