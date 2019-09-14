open Base
module Protobuf = Shared_types.Protobuf
module Generated_code = Shared_types.Generated_code

type options = {derivers : string list}

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

  let make_record_type ~options:{derivers} type_name fields =
    let deriving =
      match derivers with
      | [] -> []
      | _ ->
          [String.concat ~sep:", " derivers |> Printf.sprintf "[@@deriving %s]" |> line]
    in
    [
      [
        type_name |> Printf.sprintf "type %s = {" |> line;
        fields
        |> List.map ~f:(fun (field_name, field_type) ->
               Printf.sprintf "%s : %s;" field_name field_type)
        |> lines;
        line "}";
      ];
      deriving;
    ]
    |> List.concat
    |> block

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

let generate_message : options:options -> Protobuf.Message.t -> Code.t =
 fun ~options {name; fields} ->
  let type_to_constructor : Protobuf.field_data_type -> string = function
    | Protobuf.String -> "String"
    | Int32 -> "I32"
    | Int64 -> "I64"
    | Sint32 -> "S32"
    | Sint64 -> "S64"
  in
  let type_to_ocaml_type : Protobuf.field_data_type -> string = function
    | String -> "string"
    | Int32 -> "int"
    | Int64 -> "int"
    | Sint32 -> "int"
    | Sint64 -> "int"
  in
  let type_declaration =
    fields
    |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
           name, type_to_ocaml_type data_type)
    |> Code.make_record_type ~options "t"
  in
  let serialize_code =
    Code.make_let "serialize" "t -> (string, [> M'.serialization_error]) result"
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
                 "%d, F'.make_encoder F'.%s %s F'.Wire"
                 number
                 (type_to_constructor data_type)
                 name)
        |> Code.make_list
      in
      Code.(block [serialization_items; line "|> M'.serialize"])
    in
    Code.make_lambda argument body
  in
  let deserialize_code =
    Code.make_let "deserialize" "string -> (t, [> M'.deserialization_error]) result"
    @@
    let argument = "input'" in
    let decoder_declarations =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
             Printf.sprintf
               "let %s = F'.make_cell F'.%s F'.Wire in"
               name
               (type_to_constructor data_type))
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
                      Printf.sprintf "%d, %s.decode" number name)
               |> make_list;
             ])
          [
            ( "Ok ()",
              fields
              |> List.map ~f:(fun Protobuf.Field.{name; _} ->
                     Printf.sprintf "%s = !(%s.value)" name name)
              |> make_record ~prefix:"Ok " );
            "Error _ as error", lines ["error"];
          ])
    in
    let body = [decoder_declarations; result_match] |> Code.block ~indented:false in
    Code.make_lambda argument body
  in
  let stringify_code =
    Code.make_let "stringify" "t -> (string, [> M'.stringification_error]) result"
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
                 {|"%s", F'.make_encoder F'.%s %s F'.Text|}
                 name
                 (type_to_constructor data_type)
                 name)
        |> Code.make_list
      in
      Code.(block [serialization_items; line "|> M'.stringify"])
    in
    Code.make_lambda argument body
  in
  let unstringify_code =
    Code.make_let "unstringify" "string -> (t, [> M'.unstringification_error]) result"
    @@
    let argument = "input'" in
    let decoder_declarations =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
             Printf.sprintf
               "let %s = F'.make_cell F'.%s F'.Text in"
               name
               (type_to_constructor data_type))
      |> Code.lines
    in
    let result_match =
      Code.(
        make_match
          (block
             [
               argument |> Printf.sprintf "M'.unstringify %s" |> line;
               fields
               |> List.map ~f:(fun Protobuf.Field.{name; _} ->
                      Printf.sprintf "\"%s\", %s.decode" name name)
               |> make_list;
             ])
          [
            ( "Ok ()",
              fields
              |> List.map ~f:(fun Protobuf.Field.{name; _} ->
                     Printf.sprintf "%s = !(%s.value)" name name)
              |> make_record ~prefix:"Ok " );
            "Error _ as error", lines ["error"];
          ])
    in
    let body = [decoder_declarations; result_match] |> Code.block ~indented:false in
    Code.make_lambda argument body
  in
  Code.make_module
    name
    [
      type_declaration;
      serialize_code;
      deserialize_code;
      stringify_code;
      unstringify_code;
    ]

let generate_file : options:options -> Protobuf.File.t -> Generated_code.File.t =
 fun ~options {name; messages} ->
  let contents =
    Code.(
      make_file
        [
          line "module F' = Runtime.Field";
          line "module M' = Runtime.Message";
          List.map messages ~f:(generate_message ~options) |> block ~indented:false;
        ])
    |> Code.emit
  in
  {name; contents}

let generate_files : options:options -> Protobuf.t -> Generated_code.t =
 fun ~options {files} -> List.map ~f:(generate_file ~options) files
