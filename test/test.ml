open Base

module Message_name = struct
  type t = {
    int_field : int;
    string_field : string;
  }

  module F' = Runtime.Field
  module M' = Runtime.Message

  let serialize : t -> string =
   fun {int_field; string_field} ->
    F'.[7, Int32, encode_int_32 int_field; 42, String, encode_string string_field]
    |> M'.serialize

  let deserialize : string -> (t, F'.decoding_error) Result.t =
   fun input ->
    let int_field = F'.int_32_decoder () in
    let string_field = F'.string_decoder () in
    match
      M'.deserialize input [7, F'.consume int_field; 42, F'.consume string_field]
    with
    | Ok () -> Ok {int_field = F'.value int_field; string_field = F'.value string_field}
    | Error _ as error -> error
end

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
  Alcotest.run
    "protocell test suite"
    ["", [Alcotest.test_case "Basic serdes test" `Quick serdes_test]]
