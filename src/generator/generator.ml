open Base
module Protobuf = Shared_types.Protobuf
module Generated_code = Shared_types.Generated_code

module Code = struct
  type t =
    | Sequence of t list
    | Line of string

  let line string = Line string

  let sequence sequence = Sequence sequence

  let emit code =
    let rec append buffer indent = function
      | Line string -> List.iter [indent; string; "\n"] ~f:(Buffer.add_string buffer)
      | Sequence sequence ->
          let bigger_indent = Printf.sprintf "  %s" indent in
          List.iter sequence ~f:(fun each ->
              let indent =
                match each with
                | Line _ -> indent
                | Sequence _ -> bigger_indent
              in
              append buffer indent each)
    in
    let buffer = Base.Buffer.create 4096 in
    append buffer "" code; Buffer.contents buffer
end

let generate_message : Protobuf.Message.t -> Code.t =
 fun {name; fields} ->
  let fields_code =
    fields
    |> List.map ~f:(fun Protobuf.Field.{name; _} ->
           name |> Printf.sprintf "%s : int;" |> Code.line)
    |> Code.sequence
  in
  let module_ =
    Code.
      [
        name |> Printf.sprintf "module %s = struct" |> line;
        [
          line "type t = {";
          fields_code;
          line "}";
            (* 
int32 field = 7; -> type t = {field : int}

module M = struct
  type t = {field : int}

  let message_type' = Runtime.Message_type.[Varint, 7]

  let serialize : t -> string = fun {field} -> Runtime.serialize message_type' [field]

  let deserialize : string -> (t, [< Runtime.decoding_error]) result =
   fun bytes ->
    match Runtime.deserialize message_type' with
    | Ok [field] -> Ok {field}
    | Error _ as error -> error
end
*)
          
        ]
        |> sequence;
        line "end";
      ]
    |> Code.sequence
  in
  module_

let generate_file : Protobuf.File.t -> Generated_code.File.t =
 fun {name; messages} ->
  {
    name;
    contents =
      messages
      |> List.map ~f:generate_message
      |> List.map ~f:Code.emit
      |> String.concat ~sep:"";
  }

let generate_files : Protobuf.t -> Generated_code.t =
 fun {files} -> List.map ~f:generate_file files
