open Base
module Simple_message = Simple_pc.Simple_message

let message = Simple_message.{content = "protocell_example"}

let () =
  let open Result.Let_syntax in
  message
  |> Simple_message.to_binary
  >>= Simple_message.of_binary
  >>= Simple_message.to_text
  >>| Printf.sprintf "Message after binary serialization:\n%s"
  >>| Stdio.print_endline
  |> ignore
