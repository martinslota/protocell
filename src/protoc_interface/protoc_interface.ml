open Base

module Plugin = struct
  include Google_protobuf_compiler_plugin_pc

  let decode_request = Code_generator_request.deserialize

  let encode_response = Code_generator_response.serialize

  let error_response =
    let bytes_result =
      Code_generator_response.serialize {error = Some "Protocell error"; file = []}
    in
    Option.value_exn ~message:"Protocell: Fatal error" (Result.ok bytes_result)
end

module Descriptor = struct
  include Google_protobuf_descriptor_pc
end

module Protobuf = struct
  include Shared.Protobuf

  let field_type_of_request
      :  package:Module_path.t -> known_types:Module_path.t list ->
      Descriptor.Field_descriptor_proto.t -> field_data_type
    =
   fun ~package ~known_types {type'; type_name; _} ->
    let f type_name =
      let full_path =
        Option.value_exn
          (Option.value_exn type_name
          |> String.chop_prefix_exn ~prefix:"."
          |> String.split ~on:'.'
          |> List.map ~f:Module_name.of_string
          |> Option.all)
      in
      match List.mem known_types full_path ~equal:Module_path.equal with
      | true -> full_path
      | false -> List.drop full_path (List.length package)
    in
    match type' with
    | Type_string -> String_t
    | Type_bytes -> Bytes_t
    | Type_int32 -> Int32_t
    | Type_int64 -> Int64_t
    | Type_sint32 -> Sint32_t
    | Type_sint64 -> Sint64_t
    | Type_uint32 -> Uint32_t
    | Type_uint64 -> Uint64_t
    | Type_fixed32 -> Fixed32_t
    | Type_fixed64 -> Fixed64_t
    | Type_sfixed32 -> Sfixed32_t
    | Type_sfixed64 -> Sfixed64_t
    | Type_float -> Float_t
    | Type_double -> Double_t
    | Type_bool -> Bool_t
    | Type_message -> Message_t (f type_name)
    | Type_enum -> Enum_t (f type_name)
    | Type_group -> failwith "Groups are not supported"

  let enum_of_request : Descriptor.Enum_descriptor_proto.t -> Enum.t =
   fun {name; value'; _} ->
    let values =
      List.map value' ~f:(fun {name; number; _} ->
          Enum.
            {
              id = Option.value_exn number;
              original_name = Option.value_exn name;
              variant_name =
                Option.value_exn (Option.bind name ~f:Variant_name.of_string);
            })
    in
    {module_name = Option.value_exn (Option.bind name ~f:Module_name.of_string); values}

  let field_of_request
      :  package:Module_path.t -> known_types:Module_path.t list ->
      Descriptor.Field_descriptor_proto.t -> Field.t
    =
   fun ~package ~known_types ({name; number; label; oneof_index; _} as field) ->
    {
      field_name = Option.value_exn (Option.bind name ~f:Field_name.of_string);
      variant_name = Option.value_exn (Option.bind name ~f:Variant_name.of_string);
      number = Option.value_exn number;
      data_type = field_type_of_request ~package ~known_types field;
      repeated =
        (match label with
        | Descriptor.Field_descriptor_proto.Label.Label_repeated -> true
        | _ -> false);
      oneof_index;
    }

  let oneof_of_request : Descriptor.Oneof_descriptor_proto.t -> Oneof.t =
   fun {name; _} ->
    {
      module_name = Option.value_exn (Option.bind name ~f:Module_name.of_string);
      field_name = Option.value_exn (Option.bind name ~f:Field_name.of_string);
    }

  let rec message_of_request
      :  package:Module_path.t -> known_types:Module_path.t list ->
      Descriptor.Descriptor_proto.t -> Message.t
    =
   fun ~package ~known_types {name; field; nested_type; enum_type; oneof_decl; _} ->
    let fields = List.map field ~f:(field_of_request ~package ~known_types) in
    let oneofs = List.map oneof_decl ~f:oneof_of_request in
    {
      module_name = Option.value_exn (Option.bind name ~f:Module_name.of_string);
      enums = List.map enum_type ~f:enum_of_request;
      messages = List.map nested_type ~f:(message_of_request ~package ~known_types);
      field_groups = Field.determine_groups fields oneofs;
    }

  let file_of_request
      : (string, File.t) List.Assoc.t -> Descriptor.File_descriptor_proto.t -> File.t
    =
   fun known_files {name; package; enum_type; message_type; dependency; syntax; _} ->
    let dependencies =
      List.filter_map known_files ~f:(fun (file_name, file) ->
          match List.exists dependency ~f:(String.equal file_name) with
          | true -> Some file
          | false -> None)
    in
    let enum_module_paths prefix enums =
      List.map enums ~f:(fun Enum.{module_name; _} ->
          List.concat [prefix; [module_name]])
    in
    let rec message_module_paths prefix messages =
      List.concat_map messages ~f:(fun Message.{module_name; messages; enums; _} ->
          let prefix = List.concat [prefix; [module_name]] in
          List.concat
            [
              [prefix];
              message_module_paths prefix messages;
              enum_module_paths prefix enums;
            ])
    in
    let known_types =
      List.concat_map dependencies ~f:(fun {enums; package; messages; _} ->
          List.concat
            [message_module_paths package messages; enum_module_paths package enums])
    in
    let ocaml_module_name name =
      let base_name =
        match String.chop_suffix name ~suffix:".proto" with
        | None -> name
        | Some stem -> stem
      in
      Printf.sprintf "%s_pc" base_name |> String.tr ~target:'/' ~replacement:'_'
    in
    let package =
      match package with
      | None -> []
      | Some package ->
          Option.value_exn
            (package
            |> String.split ~on:'.'
            |> List.map ~f:Module_name.of_string
            |> Option.all)
    in
    let file_name = Printf.sprintf "%s.ml" (ocaml_module_name (Option.value_exn name)) in
    let module_name =
      Option.(value_exn (name >>| ocaml_module_name >>= Module_name.of_string))
    in
    let enums = List.map ~f:enum_of_request enum_type in
    let messages = List.map ~f:(message_of_request ~package ~known_types) message_type in
    let syntax = Option.value syntax ~default:"proto2" in
    {file_name; package; module_name; enums; messages; dependencies; syntax}

  let of_request : Plugin.Code_generator_request.t -> t =
   fun {proto_file; _} ->
    let _, files =
      List.fold proto_file ~init:([], []) ~f:(fun (x, accumulator) proto ->
          let f = file_of_request x proto in
          let x = (Option.value_exn proto.name, f) :: x in
          x, f :: accumulator)
    in
    {files}
end

module Generated_code = struct
  include Shared.Generated_code

  let file_to_response : File.t -> Plugin.Code_generator_response.File.t =
   fun {file_name; contents} ->
    {name = Some file_name; insertion_point = None; content = Some contents}

  let to_response : t -> Plugin.Code_generator_response.t =
   fun files -> {error = None; file = List.map ~f:file_to_response files}
end
