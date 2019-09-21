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

  type module_ = {
    module_name : string;
    signature : t list;
    implementation : t list;
  }

  let line string = Line string

  let block ?(indented = true) contents = Block {indented; contents}

  let lines ?(indented = true) strings = strings |> List.map ~f:line |> block ~indented

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

  let make_let name code = block [Printf.sprintf "let %s =" name |> line; code]

  let make_match expression cases =
    let cases =
      List.map cases ~f:(fun (pattern, code) ->
          [pattern |> Printf.sprintf "| %s ->" |> line; block [code]])
    in
    [line "match"; expression; line "with"] :: cases |> List.concat |> block

  let make_lambda argument body =
    block [argument |> Printf.sprintf "fun %s ->" |> line; body]

  let add_vertical_space items =
    items
    |> List.filter ~f:(function
           | Block {contents = []; _} -> false
           | _ -> true)
    |> List.intersperse ~sep:(line "")

  let make_recursive_modules ~with_implementation (modules : module_ list) =
    let rec modules_code is_first acc = function
      | [] -> List.rev acc
      | {module_name; signature; implementation} :: rest ->
          let prefix =
            match is_first with
            | true -> [Printf.sprintf "module rec %s : sig" module_name]
            | false -> [""; Printf.sprintf "and %s : sig" module_name]
          in
          let code =
            List.concat
              [
                List.map prefix ~f:line;
                add_vertical_space signature;
                (match with_implementation with
                | true ->
                    List.concat
                      [[line "end = struct"]; add_vertical_space implementation]
                | false -> []);
                [line "end"];
              ]
          in
          modules_code false (block ~indented:false code :: acc) rest
    in
    modules_code true [] modules

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

let rec generate_message : options:options -> Protobuf.Message.t -> Code.module_ =
 fun ~options {name; messages; fields} ->
  let determine_module_name name =
    match String.is_prefix ~prefix:"." name with
    | true -> String.subo ~pos:1 name
    | false -> name
  in
  let type_to_ocaml_type : Protobuf.field_data_type -> string = function
    | String_t -> "string"
    | Int32_t -> "int"
    | Int64_t -> "int"
    | Sint32_t -> "int"
    | Sint64_t -> "int"
    | Uint32_t -> "int"
    | Uint64_t -> "int"
    | Fixed32_t -> "int"
    | Fixed64_t -> "int"
    | Sfixed32_t -> "int"
    | Sfixed64_t -> "int"
    | Float_t -> "float"
    | Double_t -> "float"
    | Bool_t -> "bool"
    | Message_t name -> determine_module_name name |> Printf.sprintf "%s.t option"
    | _ -> failwith "TODO"
  in
  let messages = List.map messages ~f:(generate_message ~options) in
  let type_declaration =
    fields
    |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
           name, type_to_ocaml_type data_type)
    |> Code.make_record_type ~options "t"
  in
  let type_to_constructor : Protobuf.field_data_type -> string = function
    | Protobuf.String_t -> "String_t"
    | Int32_t -> "Int32_t"
    | Int64_t -> "Int64_t"
    | Sint32_t -> "Sint32_t"
    | Sint64_t -> "Sint64_t"
    | Uint32_t -> "Uint32_t"
    | Uint64_t -> "Uint64_t"
    | Fixed32_t -> "Fixed32_t"
    | Fixed64_t -> "Fixed64_t"
    | Sfixed32_t -> "Sfixed32_t"
    | Sfixed64_t -> "Sfixed64_t"
    | Float_t -> "Float_t"
    | Double_t -> "Double_t"
    | Bool_t -> "Bool_t"
    | Message_t name -> determine_module_name name
    | _ -> failwith "TODO"
  in
  let generate_serialization_function function_name format_module_name field_to_ocaml_id =
    Code.make_let function_name
    @@
    let argument =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; _} -> name)
      |> String.concat ~sep:"; "
      |> Printf.sprintf "{ %s }"
    in
    let body =
      Code.(
        block
          [
            line "let o' = Runtime.Byte_output.create () in";
            List.map fields ~f:(fun (Protobuf.Field.{name; data_type; _} as field) ->
                match data_type with
                | Message_t _ ->
                    Printf.sprintf
                      {|(%s.serialize_user_field %s %s.%s %s o') >>= fun () ->|}
                      format_module_name
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      function_name
                      name
                | _ ->
                    Printf.sprintf
                      {|(%s.serialize_field %s F'.%s %s o') >>= fun () ->|}
                      format_module_name
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      name)
            |> lines ~indented:false;
            line "Ok (Runtime.Byte_output.contents o')";
          ])
    in
    Code.make_lambda argument body
  in
  let generate_deserialization_function function_name format_module_name
      field_to_ocaml_id
    =
    Code.make_let function_name
    @@
    let argument = "input'" in
    let _decoder_declarations =
      fields
      |> List.map ~f:(fun Protobuf.Field.{name; data_type; _} ->
             Printf.sprintf
               "let %s = S'.allocate F'.%s in"
               name
               (type_to_constructor data_type))
      |> Code.lines
    in
    let result_match =
      Code.(
        block
          [
            line (Printf.sprintf "Ok (Runtime.Byte_input.create %s) >>=" argument);
            line
              (Printf.sprintf "%s.deserialize_message >>= fun m' ->" format_module_name);
            List.map fields ~f:(fun (Protobuf.Field.{name; data_type; _} as field) ->
                match data_type with
                | Message_t _ ->
                    Printf.sprintf
                      {|(%s.decode_user_field %s %s.%s m') >>= fun %s ->|}
                      format_module_name
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      function_name
                      name
                | _ ->
                    Printf.sprintf
                      "%s.decode_field %s F'.%s m' >>= fun %s ->"
                      format_module_name
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      name)
            |> lines ~indented:false;
            fields
            |> List.map ~f:(fun Protobuf.Field.{name; _} -> Printf.sprintf "%s" name)
            |> make_record ~prefix:"Ok ";
          ])
    in
    let body = [result_match] |> Code.block ~indented:false in
    Code.make_lambda argument body
  in
  let field_number_to_ocaml_id Protobuf.Field.{number; _} = Printf.sprintf "%d" number in
  let serialize_code =
    generate_serialization_function "serialize" "W'" field_number_to_ocaml_id
  in
  let deserialize_code =
    generate_deserialization_function "deserialize" "W'" field_number_to_ocaml_id
  in
  let field_name_to_ocaml_id Protobuf.Field.{name; _} = Printf.sprintf {|"%s"|} name in
  let stringify_code =
    generate_serialization_function "stringify" "T'" field_name_to_ocaml_id
  in
  let unstringify_code =
    generate_deserialization_function "unstringify" "T'" field_name_to_ocaml_id
  in
  let signature =
    Code.
      [
        messages |> Code.make_recursive_modules ~with_implementation:false |> Code.block;
        type_declaration;
        block [line "val serialize : t -> (string, [> W'.serialization_error]) result"];
        block
          [line "val deserialize : string -> (t, [> W'.deserialization_error]) result"];
        block [line "val stringify : t -> (string, [> T'.serialization_error]) result"];
        block
          [line "val unstringify : string -> (t, [> T'.deserialization_error]) result"];
      ]
  in
  let implementation =
    [
      messages |> Code.make_recursive_modules ~with_implementation:true |> Code.block;
      type_declaration;
      serialize_code;
      deserialize_code;
      stringify_code;
      unstringify_code;
    ]
  in
  {module_name = name; signature; implementation}

let generate_file : options:options -> Protobuf.File.t -> Generated_code.File.t =
 fun ~options {name; messages} ->
  let contents =
    Code.(
      make_file
        [
          line "let (>>=) = Runtime.Result.(>>=)";
          line "module F' = Runtime.Field_value";
          line "module T' = Runtime.Text_format";
          line "module W' = Runtime.Wire_format";
          List.map messages ~f:(generate_message ~options)
          |> Code.make_recursive_modules ~with_implementation:true
          |> block ~indented:false;
        ])
    |> Code.emit
  in
  {name; contents}

let generate_files : options:options -> Protobuf.t -> Generated_code.t =
 fun ~options {files} -> List.map ~f:(generate_file ~options) files
