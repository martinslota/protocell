open Base
module Protobuf = Shared_types.Protobuf
module Generated_code = Shared_types.Generated_code

module Code = struct
  type t =
    | Line of string
    | Block of block

  and block = {
    indented : bool;
    contents : t list;
  }

  let line string = Line string

  let block ?(indented = true) contents = Block {indented; contents}

  let lines strings = strings |> List.map ~f:line |> block

  let make_list elements =
    block [line "["; elements |> List.map ~f:(fun e -> e ^ ";") |> lines; line "]"]

  let make_record ?(prefix = "") elements =
    block
      [
        line @@ prefix ^ "{";
        elements |> List.map ~f:(fun e -> e ^ ";") |> lines;
        line "}";
      ]

  let make_record_type type_name fields =
    block
      [
        type_name |> Printf.sprintf "type %s = {" |> line;
        fields
        |> List.map ~f:(fun (field_name, field_type) ->
               Printf.sprintf "%s : %s;" field_name field_type)
        |> lines;
        line "}";
      ]

  let make_let name type_annotation code =
    block [Printf.sprintf "let %s : %s =" name type_annotation |> line; code]

  let make_match expression cases =
    let cases =
      List.map cases ~f:(fun (pattern, code) ->
          [pattern |> Printf.sprintf "| %s ->" |> line; block [code]])
    in
    [line "match"; expression; line "with"] :: cases |> List.concat |> block

  let make_lambda argument body =
    block [argument |> Printf.sprintf "fun %s ->" |> line; body]

  let make_module name items =
    let items = List.intersperse items ~sep:(line "") in
    block ~indented:false
    @@ List.concat
         [[name |> Printf.sprintf "module %s = struct" |> line]; items; [line "end"]]

  let make_file items =
    let items = List.intersperse items ~sep:(line "") in
    block ~indented:false items

  let emit code =
    let rec append ~indent buffer = function
      | Line string -> List.iter [indent; string; "\n"] ~f:(Buffer.add_string buffer)
      | Block {indented; contents} ->
          let indent = if indented then Printf.sprintf "  %s" indent else indent in
          List.iter contents ~f:(fun each -> append buffer ~indent each)
    in
    let buffer = Base.Buffer.create 4096 in
    append buffer ~indent:"" code; Buffer.contents buffer
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
  let type_declaration =
    fields
    |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
           name, type_to_ocaml_type data_type)
    |> Code.make_record_type "t"
  in
  let serialize_code =
    Code.make_let "serialize" "t -> string"
    @@
    let argument =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; _} -> name)
      |> String.concat ~sep:"; "
      |> Printf.sprintf "{ %s }"
    in
    let body =
      let serialization_items =
        fields
        |> List.map ~f:(fun Protobuf.Field.{name; number; data_type} ->
               Printf.sprintf
                 "%d, F'.%s, F'.encode_%s %s"
                 number
                 (type_to_string data_type)
                 (type_to_snake_case data_type)
                 name)
        |> Code.make_list
      in
      Code.(block [serialization_items; line "|> M'.serialize"])
    in
    Code.make_lambda argument body
  in
  let deserialize_code =
    Code.make_let "deserialize" "string -> (t, F'.decoding_error) result"
    @@
    let argument = "input'" in
    let decoder_declarations =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
             Printf.sprintf
               "let %s = F'.%s_decoder () in"
               name
               (type_to_snake_case data_type))
      |> Code.lines
    in
    let result_match =
      Code.(
        make_match
          (block
             [
               argument |> Printf.sprintf "M'.deserialize %s" |> line;
               fields
               |> List.map ~f:(fun Protobuf.Field.{name; number; _} ->
                      Printf.sprintf "%d, F'.consume %s" number name)
               |> make_list;
             ])
          [
            ( "Ok ()",
              fields
              |> List.map ~f:(fun Protobuf.Field.{name; _} ->
                     Printf.sprintf "%s = F'.value %s" name name)
              |> make_record ~prefix:"Ok " );
            "Error _ as error", lines ["error"];
          ])
    in
    let body = [decoder_declarations; result_match] |> Code.block ~indented:false in
    Code.make_lambda argument body
  in
  let stringify_code =
    Code.make_let "stringify" "t -> string"
    @@
    let argument =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; _} -> name)
      |> String.concat ~sep:"; "
      |> Printf.sprintf "{ %s }"
    in
    let body =
      let serialization_items =
        fields
        |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
               Printf.sprintf
                 {|"%s", F'.stringify_%s %s|}
                 name
                 (type_to_snake_case data_type)
                 name)
        |> Code.make_list
      in
      Code.(block [serialization_items; line "|> M'.stringify"])
    in
    Code.make_lambda argument body
  in
  Code.make_module
    name
    [type_declaration; serialize_code; deserialize_code; stringify_code]

let generate_file : Protobuf.File.t -> Generated_code.File.t =
 fun {name; messages} ->
  let contents =
    Code.(
      make_file
        [
          line "module F' = Runtime.Field";
          line "module M' = Runtime.Message";
          List.map messages ~f:generate_message |> block ~indented:false;
        ])
    |> Code.emit
  in
  {name; contents}

let generate_files : Protobuf.t -> Generated_code.t =
 fun {files} -> List.map ~f:generate_file files
