open Base

module Plugin = struct
  include Google_protobuf_compiler_plugin_pc

  let decode_request = CodeGeneratorRequest.deserialize

  let encode_response = CodeGeneratorResponse.serialize

  let error_response =
    let bytes_result =
      CodeGeneratorResponse.serialize {error = Some "Protocell error"; file = []}
    in
    Option.value_exn ~message:"Protocell: Fatal error" (Result.ok bytes_result)
end

module Descriptor = struct
  include Google_protobuf_descriptor_pc
end

module Protobuf = struct
  include Shared_types.Protobuf

  let field_type_of_request : Descriptor.FieldDescriptorProto.t -> field_data_type =
   fun {type'; type_name; _} ->
    match type' with
    | TYPE_STRING -> String_t
    | TYPE_BYTES -> Bytes_t
    | TYPE_INT32 -> Int32_t
    | TYPE_INT64 -> Int64_t
    | TYPE_SINT32 -> Sint32_t
    | TYPE_SINT64 -> Sint64_t
    | TYPE_UINT32 -> Uint32_t
    | TYPE_UINT64 -> Uint64_t
    | TYPE_FIXED32 -> Fixed32_t
    | TYPE_FIXED64 -> Fixed64_t
    | TYPE_SFIXED32 -> Sfixed32_t
    | TYPE_SFIXED64 -> Sfixed64_t
    | TYPE_FLOAT -> Float_t
    | TYPE_DOUBLE -> Double_t
    | TYPE_BOOL -> Bool_t
    | TYPE_MESSAGE -> Message_t (Option.value_exn type_name)
    | TYPE_ENUM -> Enum_t (Option.value_exn type_name)
    | TYPE_GROUP -> failwith "Groups are not supported"

  let enum_of_request : Descriptor.EnumDescriptorProto.t -> Enum.t =
   fun {name; value'; _} ->
    let values =
      List.map value' ~f:(fun {name; number; _} ->
          Option.value_exn name, Option.value_exn number)
    in
    {name = Option.value_exn name; values}

  let ocaml_keywords =
    Hash_set.of_list
      (module String)
      [
        "and";
        "as";
        "assert";
        "asr";
        "begin";
        "class";
        "constraint";
        "do";
        "done";
        "downto";
        "else";
        "end";
        "exception";
        "external";
        "false";
        "for";
        "fun";
        "function";
        "functor";
        "if";
        "in";
        "include";
        "inherit";
        "initializer";
        "land";
        "lazy";
        "let";
        "lor";
        "lsl";
        "lsr";
        "lxor";
        "match";
        "method";
        "mod";
        "module";
        "mutable";
        "new";
        "nonrec";
        "object";
        "of";
        "open";
        "or";
        "private";
        "rec";
        "sig";
        "struct";
        "then";
        "to";
        "true";
        "try";
        "type";
        "val";
        "virtual";
        "when";
        "while";
        "with";
        "parser";
        "value";
      ]

  let field_of_request : Descriptor.FieldDescriptorProto.t -> Field.t =
   fun ({name; number; label; oneof_index; _} as field) ->
    {
      name =
        (let name = String.uncapitalize (Option.value_exn name) in
         match Hash_set.mem ocaml_keywords name with
         | true -> Printf.sprintf "%s'" name
         | false -> name);
      number = Option.value_exn number;
      data_type = field_type_of_request field;
      repeated =
        (match label with
        | Descriptor.FieldDescriptorProto.Label.LABEL_REPEATED -> true
        | _ -> false);
      oneof_index;
    }

  let oneof_of_request : Descriptor.OneofDescriptorProto.t -> Oneof.t =
   fun {name; _} -> {name = Option.value_exn name}

  let rec message_of_request : Descriptor.DescriptorProto.t -> Message.t =
   fun {name; field; nested_type; enum_type; oneof_decl; _} ->
    {
      name = Option.value_exn name;
      enums = List.map enum_type ~f:enum_of_request;
      messages = List.map nested_type ~f:message_of_request;
      fields = List.map field ~f:field_of_request;
      oneofs = List.map oneof_decl ~f:oneof_of_request;
    }

  let file_of_request : File.context -> Descriptor.FileDescriptorProto.t -> File.t =
   fun context {name; package; enum_type; message_type; dependency; syntax; _} ->
    let ocaml_module_name name =
      let base_name =
        match String.chop_suffix name ~suffix:".proto" with
        | None -> name
        | Some stem -> stem
      in
      Printf.sprintf "%s_pc" base_name |> String.tr ~target:'/' ~replacement:'_'
    in
    let name = Printf.sprintf "%s.ml" (ocaml_module_name (Option.value_exn name)) in
    let enums = List.map ~f:enum_of_request enum_type in
    let messages = List.map ~f:message_of_request message_type in
    let full_enum_names prefix enums =
      List.map enums ~f:(fun Enum.{name; _} -> Printf.sprintf "%s%s" prefix name)
    in
    let rec full_message_names accumulator to_process =
      match to_process with
      | [] -> accumulator
      | (prefix, Message.{name; enums; messages; _}) :: rest ->
          let accumulator = Printf.sprintf "%s%s" prefix name :: accumulator in
          let prefix = Printf.sprintf "%s%s." prefix name in
          let accumulator = List.concat [full_enum_names prefix enums; accumulator] in
          let to_process =
            List.concat [List.map messages ~f:(fun message -> prefix, message); rest]
          in
          full_message_names accumulator to_process
    in
    let all_names =
      List.concat
        [
          full_enum_names "" enums;
          full_message_names [] (List.map messages ~f:(fun message -> "", message));
        ]
    in
    let package_prefix =
      match package with
      | None -> ""
      | Some package -> Printf.sprintf "%s." package
    in
    let context =
      List.concat
        [
          context;
          all_names
          |> List.map ~f:(fun name -> Printf.sprintf ".%s%s" package_prefix name, name);
        ]
    in
    let dependencies = List.map dependency ~f:ocaml_module_name in
    {
      name;
      package;
      enums;
      messages;
      context;
      dependencies;
      syntax = Option.value_exn syntax;
    }

  let of_request : Plugin.CodeGeneratorRequest.t -> t =
   fun {proto_file; _} ->
    let _, files =
      List.fold proto_file ~init:([], []) ~f:(fun (context, accumulator) proto ->
          let f = file_of_request context proto in
          f.context, f :: accumulator)
    in
    {files}
end

module Generated_code = struct
  include Shared_types.Generated_code

  let file_to_response : File.t -> Plugin.CodeGeneratorResponse.File.t =
   fun {name; contents} ->
    {name = Some name; insertion_point = None; content = Some contents}

  let to_response : t -> Plugin.CodeGeneratorResponse.t =
   fun files -> {error = None; file = List.map ~f:file_to_response files}
end
