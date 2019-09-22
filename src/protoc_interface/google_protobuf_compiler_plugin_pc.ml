[@@@ocaml.warning "-39"]

let (>>=) = Runtime.Result.(>>=)

module F' = Runtime.Field_value

module T' = Runtime.Text_format

module W' = Runtime.Wire_format

open Google_protobuf_descriptor_pc


module rec CodeGeneratorRequest : sig
  type t = {
    file_to_generate : string list;
    parameter : string;
    proto_file : FileDescriptorProto.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    file_to_generate : string list;
    parameter : string;
    proto_file : FileDescriptorProto.t list;
  }

  let rec serialize =
    fun { file_to_generate; parameter; proto_file } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_field 1 F'.String_t file_to_generate o') >>= fun () ->
      (W'.serialize_field 2 F'.String_t parameter o') >>= fun () ->
      (W'.serialize_repeated_user_field 15 FileDescriptorProto.serialize proto_file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_repeated_field 1 F'.String_t m' >>= fun file_to_generate ->
      W'.decode_field 2 F'.String_t m' >>= fun parameter ->
      (W'.decode_repeated_user_field 15 FileDescriptorProto.deserialize m') >>= fun proto_file ->
      Ok { file_to_generate; parameter; proto_file }

  let rec stringify =
    fun { file_to_generate; parameter; proto_file } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_field "file_to_generate" F'.String_t file_to_generate o') >>= fun () ->
      (T'.serialize_field "parameter" F'.String_t parameter o') >>= fun () ->
      (T'.serialize_repeated_user_field "proto_file" FileDescriptorProto.stringify proto_file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_field "file_to_generate" F'.String_t m' >>= fun file_to_generate ->
      T'.decode_field "parameter" F'.String_t m' >>= fun parameter ->
      (T'.decode_repeated_user_field "proto_file" FileDescriptorProto.unstringify m') >>= fun proto_file ->
      Ok { file_to_generate; parameter; proto_file }
end

and CodeGeneratorResponse : sig
  module rec File : sig
    type t = {
      name : string;
      insertion_point : string;
      content : string;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    error : string;
    file : CodeGeneratorResponse.File.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec File : sig
    type t = {
      name : string;
      insertion_point : string;
      content : string;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      name : string;
      insertion_point : string;
      content : string;
    }
  
    let rec serialize =
      fun { name; insertion_point; content } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
        (W'.serialize_field 2 F'.String_t insertion_point o') >>= fun () ->
        (W'.serialize_field 15 F'.String_t content o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_field 1 F'.String_t m' >>= fun name ->
        W'.decode_field 2 F'.String_t m' >>= fun insertion_point ->
        W'.decode_field 15 F'.String_t m' >>= fun content ->
        Ok { name; insertion_point; content }
  
    let rec stringify =
      fun { name; insertion_point; content } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
        (T'.serialize_field "insertion_point" F'.String_t insertion_point o') >>= fun () ->
        (T'.serialize_field "content" F'.String_t content o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_field "name" F'.String_t m' >>= fun name ->
        T'.decode_field "insertion_point" F'.String_t m' >>= fun insertion_point ->
        T'.decode_field "content" F'.String_t m' >>= fun content ->
        Ok { name; insertion_point; content }
  end

  type t = {
    error : string;
    file : CodeGeneratorResponse.File.t list;
  }

  let rec serialize =
    fun { error; file } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t error o') >>= fun () ->
      (W'.serialize_repeated_user_field 15 CodeGeneratorResponse.File.serialize file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun error ->
      (W'.decode_repeated_user_field 15 CodeGeneratorResponse.File.deserialize m') >>= fun file ->
      Ok { error; file }

  let rec stringify =
    fun { error; file } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "error" F'.String_t error o') >>= fun () ->
      (T'.serialize_repeated_user_field "file" CodeGeneratorResponse.File.stringify file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "error" F'.String_t m' >>= fun error ->
      (T'.decode_repeated_user_field "file" CodeGeneratorResponse.File.unstringify m') >>= fun file ->
      Ok { error; file }
end
