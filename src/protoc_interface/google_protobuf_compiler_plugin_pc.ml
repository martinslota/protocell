[@@@ocaml.warning "-39"]

let (>>=) = Caml.Result.bind

let (>>|) = fun r f -> Caml.Result.map f r

module F' = Runtime.Field_value

module T' = Runtime.Text_format

module W' = Runtime.Wire_format

open Google_protobuf_descriptor_pc


module rec Version : sig
  type t = {
    major : int option;
    minor : int option;
    patch : int option;
    suffix : string option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    major : int option;
    minor : int option;
    patch : int option;
    suffix : string option;
  }

  let rec serialize =
    fun { major; minor; patch; suffix } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_optional_field 1 F'.Int32_t major o') >>= fun () ->
      (W'.serialize_optional_field 2 F'.Int32_t minor o') >>= fun () ->
      (W'.serialize_optional_field 3 F'.Int32_t patch o') >>= fun () ->
      (W'.serialize_optional_field 4 F'.String_t suffix o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_optional_field 1 F'.Int32_t m' >>= fun major ->
      W'.decode_optional_field 2 F'.Int32_t m' >>= fun minor ->
      W'.decode_optional_field 3 F'.Int32_t m' >>= fun patch ->
      W'.decode_optional_field 4 F'.String_t m' >>= fun suffix ->
      Ok { major; minor; patch; suffix }

  let rec stringify =
    fun { major; minor; patch; suffix } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_optional_field "major" F'.Int32_t major o') >>= fun () ->
      (T'.serialize_optional_field "minor" F'.Int32_t minor o') >>= fun () ->
      (T'.serialize_optional_field "patch" F'.Int32_t patch o') >>= fun () ->
      (T'.serialize_optional_field "suffix" F'.String_t suffix o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "major" F'.Int32_t m' >>= fun major ->
      T'.decode_optional_field "minor" F'.Int32_t m' >>= fun minor ->
      T'.decode_optional_field "patch" F'.Int32_t m' >>= fun patch ->
      T'.decode_optional_field "suffix" F'.String_t m' >>= fun suffix ->
      Ok { major; minor; patch; suffix }
end

and CodeGeneratorRequest : sig
  type t = {
    file_to_generate : string list;
    parameter : string option;
    proto_file : FileDescriptorProto.t list;
    compiler_version : Version.t option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    file_to_generate : string list;
    parameter : string option;
    proto_file : FileDescriptorProto.t list;
    compiler_version : Version.t option;
  }

  let rec serialize =
    fun { file_to_generate; parameter; proto_file; compiler_version } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_field 1 F'.String_t file_to_generate o') >>= fun () ->
      (W'.serialize_optional_field 2 F'.String_t parameter o') >>= fun () ->
      (W'.serialize_repeated_user_field 15 FileDescriptorProto.serialize proto_file o') >>= fun () ->
      (W'.serialize_user_field 3 Version.serialize compiler_version o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_repeated_field 1 F'.String_t m' >>= fun file_to_generate ->
      W'.decode_optional_field 2 F'.String_t m' >>= fun parameter ->
      (W'.decode_repeated_user_field 15 FileDescriptorProto.deserialize m') >>= fun proto_file ->
      (W'.decode_user_field 3 Version.deserialize m') >>= fun compiler_version ->
      Ok { file_to_generate; parameter; proto_file; compiler_version }

  let rec stringify =
    fun { file_to_generate; parameter; proto_file; compiler_version } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_field "file_to_generate" F'.String_t file_to_generate o') >>= fun () ->
      (T'.serialize_optional_field "parameter" F'.String_t parameter o') >>= fun () ->
      (T'.serialize_repeated_user_field "proto_file" FileDescriptorProto.stringify proto_file o') >>= fun () ->
      (T'.serialize_user_field "compiler_version" Version.stringify compiler_version o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_field "file_to_generate" F'.String_t m' >>= fun file_to_generate ->
      T'.decode_optional_field "parameter" F'.String_t m' >>= fun parameter ->
      (T'.decode_repeated_user_field "proto_file" FileDescriptorProto.unstringify m') >>= fun proto_file ->
      (T'.decode_user_field "compiler_version" Version.unstringify m') >>= fun compiler_version ->
      Ok { file_to_generate; parameter; proto_file; compiler_version }
end

and CodeGeneratorResponse : sig
  module rec File : sig
    type t = {
      name : string option;
      insertion_point : string option;
      content : string option;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    error : string option;
    file : CodeGeneratorResponse.File.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec File : sig
    type t = {
      name : string option;
      insertion_point : string option;
      content : string option;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      name : string option;
      insertion_point : string option;
      content : string option;
    }
  
    let rec serialize =
      fun { name; insertion_point; content } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_optional_field 1 F'.String_t name o') >>= fun () ->
        (W'.serialize_optional_field 2 F'.String_t insertion_point o') >>= fun () ->
        (W'.serialize_optional_field 15 F'.String_t content o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_optional_field 1 F'.String_t m' >>= fun name ->
        W'.decode_optional_field 2 F'.String_t m' >>= fun insertion_point ->
        W'.decode_optional_field 15 F'.String_t m' >>= fun content ->
        Ok { name; insertion_point; content }
  
    let rec stringify =
      fun { name; insertion_point; content } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_optional_field "name" F'.String_t name o') >>= fun () ->
        (T'.serialize_optional_field "insertion_point" F'.String_t insertion_point o') >>= fun () ->
        (T'.serialize_optional_field "content" F'.String_t content o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
        T'.decode_optional_field "insertion_point" F'.String_t m' >>= fun insertion_point ->
        T'.decode_optional_field "content" F'.String_t m' >>= fun content ->
        Ok { name; insertion_point; content }
  end

  type t = {
    error : string option;
    file : CodeGeneratorResponse.File.t list;
  }

  let rec serialize =
    fun { error; file } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_optional_field 1 F'.String_t error o') >>= fun () ->
      (W'.serialize_repeated_user_field 15 CodeGeneratorResponse.File.serialize file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_optional_field 1 F'.String_t m' >>= fun error ->
      (W'.decode_repeated_user_field 15 CodeGeneratorResponse.File.deserialize m') >>= fun file ->
      Ok { error; file }

  let rec stringify =
    fun { error; file } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_optional_field "error" F'.String_t error o') >>= fun () ->
      (T'.serialize_repeated_user_field "file" CodeGeneratorResponse.File.stringify file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "error" F'.String_t m' >>= fun error ->
      (T'.decode_repeated_user_field "file" CodeGeneratorResponse.File.unstringify m') >>= fun file ->
      Ok { error; file }
end
