open Base

module Int = struct
  include Int

  let of_protobuf = Option.value ~default:0
end

module String = struct
  include String

  let of_protobuf = Option.value ~default:""
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

  let field_type_of_request
      : Descriptor.field_descriptor_proto_type option -> field_data_type
    = function
    | None -> failwith "No field type"
    | Some Type_string -> String_t
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
    | Some Type_message -> Message_t
    | Some Type_bytes -> Bytes_t
    | Some Type_enum -> Enum_t
    | Some field_type ->
        failwith
          (Caml.Format.asprintf
             "Unsupported field type %a"
             Descriptor.pp_field_descriptor_proto_type
             field_type)

  let field_of_request : Descriptor.field_descriptor_proto -> Field.t =
   fun {name; number; type_; _} ->
    {
      name = String.of_protobuf name;
      number = Int.of_protobuf number;
      data_type = field_type_of_request type_;
    }

  let message_of_request : Descriptor.descriptor_proto -> Message.t =
   fun {name; field; _} ->
    {name = String.of_protobuf name; fields = List.map ~f:field_of_request field}

  let file_of_request : Descriptor.file_descriptor_proto -> File.t =
   fun {name; message_type; _} ->
    let name = String.of_protobuf name in
    let base_name =
      match String.chop_suffix name ~suffix:".proto" with
      | None -> name
      | Some stem -> stem
    in
    let name = Printf.sprintf "%s_pc.ml" base_name in
    {name; messages = List.map ~f:message_of_request message_type}

  let of_request : Plugin.code_generator_request -> t =
   fun {proto_file; _} -> {files = List.map ~f:file_of_request proto_file}
end

module Generated_code = struct
  include Shared_types.Generated_code

  let file_to_response : File.t -> Plugin.code_generator_response_file =
   fun {name; contents} ->
    {name = Some name; insertion_point = None; content = Some contents}

  let to_response : t -> Plugin.code_generator_response =
   fun files -> {error = None; file = List.map ~f:file_to_response files}
end
