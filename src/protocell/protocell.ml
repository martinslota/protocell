open Base
open Stdio

let tap ~f x = f x; x

let () =
  let _request =
    In_channel.stdin
    |> In_channel.input_all
    |> Bytes.of_string
    |> Pbrt.Decoder.of_bytes
    |> Spec.decode_code_generator_request
  in
  let response : Spec.code_generator_response = {error = None; file = []} in
  Pbrt.Encoder.create ()
  |> tap ~f:(Spec.encode_code_generator_response response)
  |> Pbrt.Encoder.to_bytes
  |> Bytes.to_string
  |> Out_channel.print_string
