open Base
open Stdio
module Plugin = Protoc_interface.Plugin
module Protobuf = Protoc_interface.Protobuf
module Generated_code = Protoc_interface.Generated_code

let tap ~f x = f x; x

let generate_file : Shared_types.Protobuf.File.t -> Shared_types.Generated_code.File.t =
 fun {name; _} -> {name; contents = name ^ "\n"}

let generate_files : Shared_types.Protobuf.t -> Shared_types.Generated_code.t =
 fun {files} -> List.map ~f:generate_file files

let () =
  In_channel.stdin
  |> In_channel.input_all
  |> Bytes.of_string
  |> Plugin.decode_request
  |> Protobuf.of_request
  |> generate_files
  |> Generated_code.to_response
  |> Plugin.encode_response
  |> Bytes.to_string
  |> Out_channel.print_string
