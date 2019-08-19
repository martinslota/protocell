open Base
open Stdio
module Plugin = Protoc_interface.Plugin
module Protobuf = Protoc_interface.Protobuf
module Generated_code = Protoc_interface.Generated_code

let () =
  In_channel.stdin
  |> In_channel.input_all
  |> Bytes.of_string
  |> Plugin.decode_request
  |> Protobuf.of_request
  |> Generator.generate_files
  |> Generated_code.to_response
  |> Plugin.encode_response
  |> Bytes.to_string
  |> Out_channel.print_string
