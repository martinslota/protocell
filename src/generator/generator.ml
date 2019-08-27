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
  let type_to_string : Protobuf.field_data_type -> string = function
    | Protobuf.String -> "String"
    | Int32 -> "Int32"
  in
  let type_to_snake_case : Protobuf.field_data_type -> string = function
    | String -> "string"
    | Int32 -> "int_32"
  in
  let type_to_ocaml_type : Protobuf.field_data_type -> string = function
    | String -> "string"
    | Int32 -> "int"
  in
  let fields_code =
    fields
    |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
           Printf.sprintf "%s : %s;" name (type_to_ocaml_type data_type) |> Code.line)
    |> Code.sequence
  in
  let serialize_code =
    let declaration = "let serialize : t -> string =" |> Code.line in
    let definition =
      let arguments =
        fields
        |> List.map ~f:(fun Protobuf.Field.{name; _} -> name)
        |> String.concat ~sep:"; "
      in
      String.concat ~sep:" " ["fun"; "{"; arguments; "}"; "->"] |> Code.line
    in
    let field_info =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; number; data_type} ->
             Printf.sprintf
               "%d, F'.%s, F'.encode_%s %s;"
               number
               (type_to_string data_type)
               (type_to_snake_case data_type)
               name
             |> Code.line)
      |> Code.sequence
    in
    let body =
      ["[" |> Code.line; field_info; "]" |> Code.line; "|> M'.serialize" |> Code.line]
      |> Code.sequence
    in
    [declaration; [definition; body] |> Code.sequence] |> Code.sequence
  in
  let deserialize_code =
    let declaration =
      "let deserialize : string -> (t, F'.decoding_error) result =" |> Code.line
    in
    let definition = "fun input' ->" |> Code.line in
    let decoder_declarations =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
             Printf.sprintf
               "let %s = F'.%s_decoder () in"
               name
               (type_to_snake_case data_type)
             |> Code.line)
      |> Code.sequence
    in
    let deserialize_args =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; number; _} ->
             Printf.sprintf "%d, F'.consume %s;" number name |> Code.line)
      |> Code.sequence
    in
    let result_fields =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; _} ->
             Printf.sprintf "%s = F'.value %s;" name name |> Code.line)
      |> Code.sequence
    in
    let result_match =
      [
        "match M'.deserialize input'" |> Code.line;
        ["[" |> Code.line; deserialize_args; "]" |> Code.line] |> Code.sequence;
        "with" |> Code.line;
        "| Ok () ->" |> Code.line;
        [["Ok {" |> Code.line; result_fields; "}" |> Code.line] |> Code.sequence]
        |> Code.sequence;
        "| Error _ as error -> error" |> Code.line;
      ]
      |> Code.sequence
    in
    let body = [decoder_declarations; result_match] |> Code.sequence in
    [declaration; [definition; body] |> Code.sequence] |> Code.sequence
  in
  let stringify_code =
    let declaration = "let stringify : t -> string =" |> Code.line in
    let definition =
      let arguments =
        fields
        |> List.map ~f:(fun Protobuf.Field.{name; _} -> name)
        |> String.concat ~sep:"; "
      in
      String.concat ~sep:" " ["fun"; "{"; arguments; "}"; "->"] |> Code.line
    in
    let field_info =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
             Printf.sprintf
               {|"%s", F'.stringify_%s %s;|}
               name
               (type_to_snake_case data_type)
               name
             |> Code.line)
      |> Code.sequence
    in
    let body =
      ["[" |> Code.line; field_info; "]" |> Code.line; "|> M'.stringify" |> Code.line]
      |> Code.sequence
    in
    [declaration; [definition; body] |> Code.sequence] |> Code.sequence
  in
  let module_ =
    Code.
      [
        name |> Printf.sprintf "module %s = struct" |> line;
        [line "type t = {"; fields_code; line "}"] |> sequence;
        serialize_code;
        deserialize_code;
        stringify_code;
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
      "module F' = Runtime.Field\nmodule M' = Runtime.Message\n"
      ^ (messages
        |> List.map ~f:generate_message
        |> List.map ~f:Code.emit
        |> String.concat ~sep:"");
  }

let generate_files : Protobuf.t -> Generated_code.t =
 fun {files} -> List.map ~f:generate_file files
