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
    line @@ Printf.sprintf "%s { %s }" prefix (String.concat elements ~sep:"; ")

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

  let make_variant_type ~options:{derivers} type_name values =
    let deriving =
      match derivers with
      | [] -> []
      | _ ->
          [String.concat ~sep:", " derivers |> Printf.sprintf "[@@deriving %s]" |> line]
    in
    [
      [
        type_name |> Printf.sprintf "type %s =" |> line;
        values |> List.map ~f:(Printf.sprintf "| %s") |> lines;
      ];
      deriving;
    ]
    |> List.concat
    |> block

  let make_let ~recursive name code =
    let prefix =
      match recursive with
      | true -> "rec "
      | false -> ""
    in
    block [Printf.sprintf "let %s%s =" prefix name |> line; code]

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

  let make_modules ~recursive ~with_implementation (modules : module_ list) =
    let rec modules_code is_first acc = function
      | [] -> List.rev acc
      | {module_name; signature; implementation} :: rest ->
          let prefix =
            match recursive, is_first with
            | false, true -> [Printf.sprintf "module %s : sig" module_name]
            | false, false -> [""; Printf.sprintf "module %s : sig" module_name]
            | true, true -> [Printf.sprintf "module rec %s : sig" module_name]
            | true, false -> [""; Printf.sprintf "and %s : sig" module_name]
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

let generate_enum : options:options -> Protobuf.Enum.t -> Code.module_ =
 fun ~options {name; values} ->
  let type_declaration =
    values |> List.map ~f:fst |> Code.make_variant_type ~options "t"
  in
  let signature =
    Code.
      [
        type_declaration;
        block [line "val default : unit -> t"];
        block [line "val to_int : t -> int"];
        block [line "val of_int : int -> t option"];
        block [line "val to_string : t -> string"];
        block [line "val of_string : string -> t option"];
      ]
  in
  let unique_values =
    List.dedup_and_sort values ~compare:(fun (_, id1) (_, id2) -> id1 - id2)
  in
  let implementation =
    let default_value =
      List.find values ~f:(fun (_, id) -> id = 0)
      |> Option.value ~default:(List.hd_exn values)
    in
    let to_int_function =
      List.concat
        Code.
          [
            [line "function"];
            values
            |> List.map ~f:(fun (name, number) ->
                   line (Printf.sprintf "| %s -> %d" name number));
          ]
    in
    let of_int_function =
      List.concat
        Code.
          [
            [line "function"];
            unique_values
            |> List.map ~f:(fun (name, number) ->
                   line (Printf.sprintf "| %d -> Some %s" number name));
            [line "| _ -> None"];
          ]
    in
    let to_string_function =
      List.concat
        Code.
          [
            [line "function"];
            values
            |> List.map ~f:(fun (name, _) ->
                   line (Printf.sprintf {|| %s -> "%s"|} name name));
          ]
    in
    let of_string_function =
      List.concat
        Code.
          [
            [line "function"];
            unique_values
            |> List.map ~f:(fun (name, _) ->
                   line (Printf.sprintf {|| "%s" -> Some %s|} name name));
            [line "| _ -> None"];
          ]
    in
    Code.
      [
        type_declaration;
        make_let ~recursive:false "default"
        @@ line
        @@ Printf.sprintf "fun () -> %s"
        @@ fst default_value;
        make_let ~recursive:false "to_int" @@ block to_int_function;
        make_let ~recursive:false "of_int" @@ block of_int_function;
        make_let ~recursive:false "to_string" @@ block to_string_function;
        make_let ~recursive:false "of_string" @@ block of_string_function;
      ]
  in
  {module_name = name; signature; implementation}

let rec generate_message
    :  options:options -> string option -> (string, string) Hashtbl.t -> string ->
    Protobuf.Message.t -> Code.module_
  =
 fun ~options package context syntax {name; enums; messages; fields; oneofs = _oneofs} ->
  let determine_module_name name =
    match Hashtbl.find context name with
    | None ->
        let prefix =
          package |> Option.map ~f:(Printf.sprintf ".%s.") |> Option.value ~default:"."
        in
        String.chop_prefix ~prefix name |> Option.value ~default:name
    | Some module_name -> module_name
  in
  let type_to_ocaml_type : Protobuf.field_data_type -> string = function
    | String_t -> "string"
    | Bytes_t -> "string"
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
    | Message_t name -> determine_module_name name |> Printf.sprintf "%s.t"
    | Enum_t name -> determine_module_name name |> Printf.sprintf "%s.t"
  in
  let enums = List.map enums ~f:(generate_enum ~options) in
  let messages =
    List.map messages ~f:(generate_message package context syntax ~options)
  in
  let type_declaration =
    fields
    |> List.map ~f:(fun Protobuf.Field.{name; data_type; repeated; _} ->
           let suffix =
             match repeated with
             | true -> " list"
             | false -> (
               match data_type, syntax with
               | Message_t _, _ -> " option"
               | _, "proto3" -> ""
               | Enum_t _, _ -> ""
               | _ -> " option")
           in
           name, Printf.sprintf "%s%s" (type_to_ocaml_type data_type) suffix)
    |> Code.make_record_type ~options "t"
  in
  let type_to_constructor : Protobuf.field_data_type -> string = function
    | Protobuf.String_t -> "String_t"
    | Bytes_t -> "Bytes_t"
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
    | Enum_t name -> determine_module_name name
  in
  let fn_name_part_of_repeated data_type repeated =
    match repeated with
    | true -> "_repeated"
    | false -> (
      match syntax with
      | "proto3" -> ""
      | _ -> (
        match data_type with
        | Protobuf.Message_t _ | Enum_t _ -> ""
        | _ -> "_optional"))
  in
  let generate_serialization_function function_name format_module_name field_to_ocaml_id
      serialized_enum_type
    =
    Code.make_let ~recursive:true function_name
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
            List.map
              fields
              ~f:(fun (Protobuf.Field.{name; data_type; repeated; _} as field) ->
                match data_type with
                | Message_t _ ->
                    Printf.sprintf
                      {|(%s.serialize%s_user_field %s %s.%s %s o') >>= fun () ->|}
                      format_module_name
                      (fn_name_part_of_repeated data_type repeated)
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      function_name
                      name
                | Enum_t _ ->
                    Printf.sprintf
                      {|(%s.serialize%s_enum_field %s %s.to_%s %s o') >>= fun () ->|}
                      format_module_name
                      (fn_name_part_of_repeated data_type repeated)
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      serialized_enum_type
                      name
                | _ ->
                    Printf.sprintf
                      {|(%s.serialize%s_field %s F'.%s %s o') >>= fun () ->|}
                      format_module_name
                      (fn_name_part_of_repeated data_type repeated)
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
      field_to_ocaml_id serialized_enum_type
    =
    Code.make_let ~recursive:true function_name
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
            List.map
              fields
              ~f:(fun (Protobuf.Field.{name; data_type; repeated; _} as field) ->
                match data_type with
                | Message_t _ ->
                    Printf.sprintf
                      {|(%s.decode%s_user_field %s %s.%s m') >>= fun %s ->|}
                      format_module_name
                      (fn_name_part_of_repeated data_type repeated)
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      function_name
                      name
                | Enum_t _ ->
                    Printf.sprintf
                      {|(%s.decode%s_enum_field %s %s.of_%s %s.default m') >>= fun %s ->|}
                      format_module_name
                      (fn_name_part_of_repeated data_type repeated)
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      serialized_enum_type
                      (type_to_constructor data_type)
                      name
                | _ ->
                    Printf.sprintf
                      "%s.decode%s_field %s F'.%s m' >>= fun %s ->"
                      format_module_name
                      (fn_name_part_of_repeated data_type repeated)
                      (field_to_ocaml_id field)
                      (type_to_constructor data_type)
                      name)
            |> lines ~indented:false;
            fields
            |> List.map ~f:(fun Protobuf.Field.{name; _} -> Printf.sprintf "%s" name)
            |> make_record ~prefix:"Ok";
          ])
    in
    let body = [result_match] |> Code.block ~indented:false in
    Code.make_lambda argument body
  in
  let field_number_to_ocaml_id Protobuf.Field.{number; _} = Printf.sprintf "%d" number in
  let serialize_code =
    generate_serialization_function "serialize" "W'" field_number_to_ocaml_id "int"
  in
  let deserialize_code =
    generate_deserialization_function "deserialize" "W'" field_number_to_ocaml_id "int"
  in
  let field_name_to_ocaml_id Protobuf.Field.{name; _} = Printf.sprintf {|"%s"|} name in
  let stringify_code =
    generate_serialization_function "stringify" "T'" field_name_to_ocaml_id "string"
  in
  let unstringify_code =
    generate_deserialization_function "unstringify" "T'" field_name_to_ocaml_id "string"
  in
  let signature =
    let generated_function_signatures =
      [
        "val serialize : t -> (string, [> W'.serialization_error]) result";
        "val deserialize : string -> (t, [> W'.deserialization_error]) result";
        "val stringify : t -> (string, [> T'.serialization_error]) result";
        "val unstringify : string -> (t, [> T'.deserialization_error]) result";
      ]
    in
    Code.(
      List.concat
        [
          [
            enums |> make_modules ~recursive:false ~with_implementation:false |> block;
            messages |> make_modules ~recursive:true ~with_implementation:false |> block;
            type_declaration;
          ];
          generated_function_signatures
          |> List.map ~f:(fun signature -> block [line signature]);
        ])
  in
  let implementation =
    Code.
      [
        enums |> make_modules ~recursive:false ~with_implementation:true |> block;
        messages |> make_modules ~recursive:true ~with_implementation:true |> block;
        type_declaration;
        serialize_code;
        deserialize_code;
        stringify_code;
        unstringify_code;
      ]
  in
  {module_name = name; signature; implementation}

let generate_file : options:options -> Protobuf.File.t -> Generated_code.File.t =
 fun ~options {name; package; enums; messages; context; dependencies; syntax} ->
  let context = Hashtbl.of_alist_exn (module String) context in
  let contents =
    Code.(
      make_file
        [
          line {|[@@@ocaml.warning "-39"]|};
          line "let (>>=) = Runtime.Result.(>>=)";
          line "module F' = Runtime.Field_value";
          line "module T' = Runtime.Text_format";
          line "module W' = Runtime.Wire_format";
          List.map dependencies ~f:(fun dependency ->
              dependency |> String.capitalize |> Printf.sprintf "open %s" |> line)
          |> block ~indented:false;
          List.map enums ~f:(generate_enum ~options)
          |> Code.make_modules ~recursive:false ~with_implementation:true
          |> block ~indented:false;
          List.map messages ~f:(generate_message ~options package context syntax)
          |> Code.make_modules ~recursive:true ~with_implementation:true
          |> block ~indented:false;
        ])
    |> Code.emit
  in
  {name; contents}

let generate_files : options:options -> Protobuf.t -> Generated_code.t =
 fun ~options {files} -> List.map ~f:(generate_file ~options) files
