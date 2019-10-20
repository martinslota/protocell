open Base
open Stdio
module Plugin = Protoc_interface.Plugin
module Protobuf = Protoc_interface.Protobuf
module Generated_code = Protoc_interface.Generated_code

let () =
  let open Result.Let_syntax in
  match
    In_channel.stdin
    |> In_channel.input_all
    |> Plugin.decode_request
    >>= Protobuf.of_request
    >>| Generator.generate_files
    >>| Generated_code.to_response
    >>= Plugin.encode_response
  with
  | Ok bytes -> Out_channel.(output_string stdout bytes)
  | Error error -> Out_channel.(output_string stdout @@ Plugin.error_response error)
