open Base

module Int = struct
  include Int

  let of_protobuf = Option.value_exn
end

module String = struct
  include String

  let of_protobuf = Option.value_exn
end

module Plugin = struct
  include Plugin_types
  include Plugin_pp
  include Plugin_pb

  let decode_request = Fn.compose decode_code_generator_request Pbrt.Decoder.of_bytes

  let encode_response response =
    let encoder = Pbrt.Encoder.create () in
    encode_code_generator_response response encoder;
    Pbrt.Encoder.to_bytes encoder
end

module Descriptor = struct
  include Descriptor_types
  include Descriptor_pp
  include Descriptor_pb
end

module Protobuf = struct
  include Shared_types.Protobuf

  let field_type_of_request : Descriptor.field_descriptor_proto -> field_data_type =
   fun {type_; type_name; _} ->
    match type_ with
    | None -> Message_t (String.of_protobuf type_name)
    | Some Type_string -> String_t
    | Some Type_bytes -> Bytes_t
    | Some Type_int32 -> Int32_t
    | Some Type_int64 -> Int64_t
    | Some Type_sint32 -> Sint32_t
    | Some Type_sint64 -> Sint64_t
    | Some Type_uint32 -> Uint32_t
    | Some Type_uint64 -> Uint64_t
    | Some Type_fixed32 -> Fixed32_t
    | Some Type_fixed64 -> Fixed64_t
    | Some Type_sfixed32 -> Sfixed32_t
    | Some Type_sfixed64 -> Sfixed64_t
    | Some Type_float -> Float_t
    | Some Type_double -> Double_t
    | Some Type_bool -> Bool_t
    | Some Type_message -> Message_t (String.of_protobuf type_name)
    | Some Type_enum -> Enum_t (String.of_protobuf type_name)
    | Some field_type ->
        failwith
          (Caml.Format.asprintf
             "Unsupported field type %a"
             Descriptor.pp_field_descriptor_proto_type
             field_type)

  let enum_of_request : Descriptor.enum_descriptor_proto -> Enum.t =
   fun {name; value; _} ->
    let values =
      List.map value ~f:(fun {name; number; _} ->
          String.of_protobuf name, String.of_protobuf number)
    in
    {name = String.of_protobuf name; values}

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

  let field_of_request : Descriptor.field_descriptor_proto -> Field.t =
   fun ({name; number; label; _} as field) ->
    {
      name =
        (let name = String.uncapitalize @@ String.of_protobuf name in
         match Hash_set.mem ocaml_keywords name with
         | true -> Printf.sprintf "%s'" name
         | false -> name);
      number = Int.of_protobuf number;
      data_type = field_type_of_request field;
      repeated =
        (match label with
        | Some Descriptor.Label_repeated -> true
        | _ -> false);
    }

  let rec message_of_request : Descriptor.descriptor_proto -> Message.t =
   fun {name; field; nested_type; enum_type; _} ->
    {
      name = String.of_protobuf name;
      enums = List.map enum_type ~f:enum_of_request;
      messages = List.map nested_type ~f:message_of_request;
      fields = List.map field ~f:field_of_request;
    }

  let file_of_request : Descriptor.file_descriptor_proto -> File.t =
   fun {name; package; enum_type; message_type; _} ->
    let name = String.of_protobuf name in
    let base_name =
      match String.chop_suffix name ~suffix:".proto" with
      | None -> name
      | Some stem -> stem
    in
    let name = Printf.sprintf "%s_pc.ml" base_name in
    let enums = List.map ~f:enum_of_request enum_type in
    let messages = List.map ~f:message_of_request message_type in
    {name; package; enums; messages}

  let of_request : Plugin.code_generator_request -> t =
   fun {proto_file; _} -> {files = List.map ~f:file_of_request proto_file}
end

module Generated_code = struct
  include Shared_types.Generated_code

  let file_to_response : File.t -> Plugin.code_generator_response_file =
   fun {name; contents} ->
    let name = String.tr ~target:'/' ~replacement:'_' name in
    {name = Some name; insertion_point = None; content = Some contents}

  let to_response : t -> Plugin.code_generator_response =
   fun files -> {error = None; file = List.map ~f:file_to_response files}
end
