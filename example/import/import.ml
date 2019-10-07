open Base
module Main_message = Import_pc.Main_message

let message =
  Main_message.{ingredient = Some (); timestamp = Some {seconds = 1; nanos = 2}}

let () =
  let open Result.Let_syntax in
  message
  |> Main_message.to_binary
  >>= Main_message.of_binary
  >>| Main_message.show
  >>| Printf.sprintf "Here's the deserialized message:\n%s"
  >>| Stdio.print_endline
  |> ignore
