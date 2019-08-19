open Base
module Protobuf = Shared_types.Protobuf
module Generated_code = Shared_types.Generated_code

let generate_message : Protobuf.Message.t -> string list =
 fun {name; fields} ->
  List.concat
    [
      [Printf.sprintf "module %s = struct" name; "type t = {"];
      List.map fields ~f:(fun {name; _} -> Printf.sprintf "%s : int;" name);
      ["}"; "end"];
    ]

let generate_file : Protobuf.File.t -> Generated_code.File.t =
 fun {name; messages} ->
  {
    name;
    contents =
      (let code =
         messages
         |> List.map ~f:generate_message
         |> List.map ~f:(String.concat ~sep:"\n")
         |> String.concat ~sep:"\n"
       in
       Printf.sprintf "%s\n" code);
  }

let generate_files : Protobuf.t -> Generated_code.t =
 fun {files} -> List.map ~f:generate_file files
