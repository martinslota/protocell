[@@@ocaml.warning "-39"]

let (>>=) = Runtime.Result.(>>=)

let (>>|) = Runtime.Result.(>>|)

module F' = Runtime.Field_value

module B' = Runtime.Binary_format

module T' = Runtime.Text_format

module rec File_descriptor_set : sig
  type t = {
    file : File_descriptor_proto.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    file : File_descriptor_proto.t list;
  }

  let rec serialize =
    fun { file } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_repeated_user_field 1 File_descriptor_proto.serialize file o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_repeated_user_field 1 File_descriptor_proto.deserialize m' >>= fun file ->
      Ok { file }

  let rec stringify =
    fun { file } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_repeated_user_field "file" File_descriptor_proto.stringify file o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_user_field "file" File_descriptor_proto.unstringify m' >>= fun file ->
      Ok { file }
end

and File_descriptor_proto : sig
  type t = {
    name : string option;
    package : string option;
    dependency : string list;
    public_dependency : int list;
    weak_dependency : int list;
    message_type : Descriptor_proto.t list;
    enum_type : Enum_descriptor_proto.t list;
    service : Service_descriptor_proto.t list;
    extension : Field_descriptor_proto.t list;
    options : File_options.t option;
    source_code_info : Source_code_info.t option;
    syntax : string option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string option;
    package : string option;
    dependency : string list;
    public_dependency : int list;
    weak_dependency : int list;
    message_type : Descriptor_proto.t list;
    enum_type : Enum_descriptor_proto.t list;
    service : Service_descriptor_proto.t list;
    extension : Field_descriptor_proto.t list;
    options : File_options.t option;
    source_code_info : Source_code_info.t option;
    syntax : string option;
  }

  let rec serialize =
    fun { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_optional_field 2 F'.String_t package o' >>= fun () ->
      B'.serialize_repeated_field 3 F'.String_t dependency o' >>= fun () ->
      B'.serialize_repeated_field 10 F'.Int32_t public_dependency o' >>= fun () ->
      B'.serialize_repeated_field 11 F'.Int32_t weak_dependency o' >>= fun () ->
      B'.serialize_repeated_user_field 4 Descriptor_proto.serialize message_type o' >>= fun () ->
      B'.serialize_repeated_user_field 5 Enum_descriptor_proto.serialize enum_type o' >>= fun () ->
      B'.serialize_repeated_user_field 6 Service_descriptor_proto.serialize service o' >>= fun () ->
      B'.serialize_repeated_user_field 7 Field_descriptor_proto.serialize extension o' >>= fun () ->
      B'.serialize_user_field 8 File_options.serialize options o' >>= fun () ->
      B'.serialize_user_field 9 Source_code_info.serialize source_code_info o' >>= fun () ->
      B'.serialize_optional_field 12 F'.String_t syntax o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_optional_field 2 F'.String_t m' >>= fun package ->
      B'.decode_repeated_field 3 F'.String_t m' >>= fun dependency ->
      B'.decode_repeated_field 10 F'.Int32_t m' >>= fun public_dependency ->
      B'.decode_repeated_field 11 F'.Int32_t m' >>= fun weak_dependency ->
      B'.decode_repeated_user_field 4 Descriptor_proto.deserialize m' >>= fun message_type ->
      B'.decode_repeated_user_field 5 Enum_descriptor_proto.deserialize m' >>= fun enum_type ->
      B'.decode_repeated_user_field 6 Service_descriptor_proto.deserialize m' >>= fun service ->
      B'.decode_repeated_user_field 7 Field_descriptor_proto.deserialize m' >>= fun extension ->
      B'.decode_user_field 8 File_options.deserialize m' >>= fun options ->
      B'.decode_user_field 9 Source_code_info.deserialize m' >>= fun source_code_info ->
      B'.decode_optional_field 12 F'.String_t m' >>= fun syntax ->
      Ok { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax }

  let rec stringify =
    fun { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_optional_field "package" F'.String_t package o' >>= fun () ->
      T'.serialize_repeated_field "dependency" F'.String_t dependency o' >>= fun () ->
      T'.serialize_repeated_field "public_dependency" F'.Int32_t public_dependency o' >>= fun () ->
      T'.serialize_repeated_field "weak_dependency" F'.Int32_t weak_dependency o' >>= fun () ->
      T'.serialize_repeated_user_field "message_type" Descriptor_proto.stringify message_type o' >>= fun () ->
      T'.serialize_repeated_user_field "enum_type" Enum_descriptor_proto.stringify enum_type o' >>= fun () ->
      T'.serialize_repeated_user_field "service" Service_descriptor_proto.stringify service o' >>= fun () ->
      T'.serialize_repeated_user_field "extension" Field_descriptor_proto.stringify extension o' >>= fun () ->
      T'.serialize_user_field "options" File_options.stringify options o' >>= fun () ->
      T'.serialize_user_field "source_code_info" Source_code_info.stringify source_code_info o' >>= fun () ->
      T'.serialize_optional_field "syntax" F'.String_t syntax o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_optional_field "package" F'.String_t m' >>= fun package ->
      T'.decode_repeated_field "dependency" F'.String_t m' >>= fun dependency ->
      T'.decode_repeated_field "public_dependency" F'.Int32_t m' >>= fun public_dependency ->
      T'.decode_repeated_field "weak_dependency" F'.Int32_t m' >>= fun weak_dependency ->
      T'.decode_repeated_user_field "message_type" Descriptor_proto.unstringify m' >>= fun message_type ->
      T'.decode_repeated_user_field "enum_type" Enum_descriptor_proto.unstringify m' >>= fun enum_type ->
      T'.decode_repeated_user_field "service" Service_descriptor_proto.unstringify m' >>= fun service ->
      T'.decode_repeated_user_field "extension" Field_descriptor_proto.unstringify m' >>= fun extension ->
      T'.decode_user_field "options" File_options.unstringify m' >>= fun options ->
      T'.decode_user_field "source_code_info" Source_code_info.unstringify m' >>= fun source_code_info ->
      T'.decode_optional_field "syntax" F'.String_t m' >>= fun syntax ->
      Ok { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax }
end

and Descriptor_proto : sig
  module rec Extension_range : sig
    type t = {
      start : int option;
      end' : int option;
      options : Extension_range_options.t option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end
  
  and Reserved_range : sig
    type t = {
      start : int option;
      end' : int option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    name : string option;
    field : Field_descriptor_proto.t list;
    extension : Field_descriptor_proto.t list;
    nested_type : Descriptor_proto.t list;
    enum_type : Enum_descriptor_proto.t list;
    extension_range : Descriptor_proto.Extension_range.t list;
    oneof_decl : Oneof_descriptor_proto.t list;
    options : Message_options.t option;
    reserved_range : Descriptor_proto.Reserved_range.t list;
    reserved_name : string list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Extension_range : sig
    type t = {
      start : int option;
      end' : int option;
      options : Extension_range_options.t option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      start : int option;
      end' : int option;
      options : Extension_range_options.t option;
    }
  
    let rec serialize =
      fun { start; end'; options } ->
        let o' = Runtime.Byte_output.create () in
        B'.serialize_optional_field 1 F'.Int32_t start o' >>= fun () ->
        B'.serialize_optional_field 2 F'.Int32_t end' o' >>= fun () ->
        B'.serialize_user_field 3 Extension_range_options.serialize options o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        B'.deserialize_message >>= fun m' ->
        B'.decode_optional_field 1 F'.Int32_t m' >>= fun start ->
        B'.decode_optional_field 2 F'.Int32_t m' >>= fun end' ->
        B'.decode_user_field 3 Extension_range_options.deserialize m' >>= fun options ->
        Ok { start; end'; options }
  
    let rec stringify =
      fun { start; end'; options } ->
        let o' = Runtime.Byte_output.create () in
        T'.serialize_optional_field "start" F'.Int32_t start o' >>= fun () ->
        T'.serialize_optional_field "end'" F'.Int32_t end' o' >>= fun () ->
        T'.serialize_user_field "options" Extension_range_options.stringify options o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_optional_field "start" F'.Int32_t m' >>= fun start ->
        T'.decode_optional_field "end'" F'.Int32_t m' >>= fun end' ->
        T'.decode_user_field "options" Extension_range_options.unstringify m' >>= fun options ->
        Ok { start; end'; options }
  end
  
  and Reserved_range : sig
    type t = {
      start : int option;
      end' : int option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      start : int option;
      end' : int option;
    }
  
    let rec serialize =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        B'.serialize_optional_field 1 F'.Int32_t start o' >>= fun () ->
        B'.serialize_optional_field 2 F'.Int32_t end' o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        B'.deserialize_message >>= fun m' ->
        B'.decode_optional_field 1 F'.Int32_t m' >>= fun start ->
        B'.decode_optional_field 2 F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  
    let rec stringify =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        T'.serialize_optional_field "start" F'.Int32_t start o' >>= fun () ->
        T'.serialize_optional_field "end'" F'.Int32_t end' o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_optional_field "start" F'.Int32_t m' >>= fun start ->
        T'.decode_optional_field "end'" F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  end

  type t = {
    name : string option;
    field : Field_descriptor_proto.t list;
    extension : Field_descriptor_proto.t list;
    nested_type : Descriptor_proto.t list;
    enum_type : Enum_descriptor_proto.t list;
    extension_range : Descriptor_proto.Extension_range.t list;
    oneof_decl : Oneof_descriptor_proto.t list;
    options : Message_options.t option;
    reserved_range : Descriptor_proto.Reserved_range.t list;
    reserved_name : string list;
  }

  let rec serialize =
    fun { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_repeated_user_field 2 Field_descriptor_proto.serialize field o' >>= fun () ->
      B'.serialize_repeated_user_field 6 Field_descriptor_proto.serialize extension o' >>= fun () ->
      B'.serialize_repeated_user_field 3 Descriptor_proto.serialize nested_type o' >>= fun () ->
      B'.serialize_repeated_user_field 4 Enum_descriptor_proto.serialize enum_type o' >>= fun () ->
      B'.serialize_repeated_user_field 5 Descriptor_proto.Extension_range.serialize extension_range o' >>= fun () ->
      B'.serialize_repeated_user_field 8 Oneof_descriptor_proto.serialize oneof_decl o' >>= fun () ->
      B'.serialize_user_field 7 Message_options.serialize options o' >>= fun () ->
      B'.serialize_repeated_user_field 9 Descriptor_proto.Reserved_range.serialize reserved_range o' >>= fun () ->
      B'.serialize_repeated_field 10 F'.String_t reserved_name o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_repeated_user_field 2 Field_descriptor_proto.deserialize m' >>= fun field ->
      B'.decode_repeated_user_field 6 Field_descriptor_proto.deserialize m' >>= fun extension ->
      B'.decode_repeated_user_field 3 Descriptor_proto.deserialize m' >>= fun nested_type ->
      B'.decode_repeated_user_field 4 Enum_descriptor_proto.deserialize m' >>= fun enum_type ->
      B'.decode_repeated_user_field 5 Descriptor_proto.Extension_range.deserialize m' >>= fun extension_range ->
      B'.decode_repeated_user_field 8 Oneof_descriptor_proto.deserialize m' >>= fun oneof_decl ->
      B'.decode_user_field 7 Message_options.deserialize m' >>= fun options ->
      B'.decode_repeated_user_field 9 Descriptor_proto.Reserved_range.deserialize m' >>= fun reserved_range ->
      B'.decode_repeated_field 10 F'.String_t m' >>= fun reserved_name ->
      Ok { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name }

  let rec stringify =
    fun { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_repeated_user_field "field" Field_descriptor_proto.stringify field o' >>= fun () ->
      T'.serialize_repeated_user_field "extension" Field_descriptor_proto.stringify extension o' >>= fun () ->
      T'.serialize_repeated_user_field "nested_type" Descriptor_proto.stringify nested_type o' >>= fun () ->
      T'.serialize_repeated_user_field "enum_type" Enum_descriptor_proto.stringify enum_type o' >>= fun () ->
      T'.serialize_repeated_user_field "extension_range" Descriptor_proto.Extension_range.stringify extension_range o' >>= fun () ->
      T'.serialize_repeated_user_field "oneof_decl" Oneof_descriptor_proto.stringify oneof_decl o' >>= fun () ->
      T'.serialize_user_field "options" Message_options.stringify options o' >>= fun () ->
      T'.serialize_repeated_user_field "reserved_range" Descriptor_proto.Reserved_range.stringify reserved_range o' >>= fun () ->
      T'.serialize_repeated_field "reserved_name" F'.String_t reserved_name o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_repeated_user_field "field" Field_descriptor_proto.unstringify m' >>= fun field ->
      T'.decode_repeated_user_field "extension" Field_descriptor_proto.unstringify m' >>= fun extension ->
      T'.decode_repeated_user_field "nested_type" Descriptor_proto.unstringify m' >>= fun nested_type ->
      T'.decode_repeated_user_field "enum_type" Enum_descriptor_proto.unstringify m' >>= fun enum_type ->
      T'.decode_repeated_user_field "extension_range" Descriptor_proto.Extension_range.unstringify m' >>= fun extension_range ->
      T'.decode_repeated_user_field "oneof_decl" Oneof_descriptor_proto.unstringify m' >>= fun oneof_decl ->
      T'.decode_user_field "options" Message_options.unstringify m' >>= fun options ->
      T'.decode_repeated_user_field "reserved_range" Descriptor_proto.Reserved_range.unstringify m' >>= fun reserved_range ->
      T'.decode_repeated_field "reserved_name" F'.String_t m' >>= fun reserved_name ->
      Ok { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name }
end

and Extension_range_options : sig
  type t = {
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { uninterpreted_option }

  let rec stringify =
    fun { uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { uninterpreted_option }
end

and Field_descriptor_proto : sig
  module Type' : sig
    type t =
      | Type_double
      | Type_float
      | Type_int64
      | Type_uint64
      | Type_int32
      | Type_fixed64
      | Type_fixed32
      | Type_bool
      | Type_string
      | Type_group
      | Type_message
      | Type_bytes
      | Type_uint32
      | Type_enum
      | Type_sfixed32
      | Type_sfixed64
      | Type_sint32
      | Type_sint64
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end
  
  module Label : sig
    type t =
      | Label_optional
      | Label_required
      | Label_repeated
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    name : string option;
    number : int option;
    label : Field_descriptor_proto.Label.t;
    type' : Field_descriptor_proto.Type'.t;
    type_name : string option;
    extendee : string option;
    default_value : string option;
    oneof_index : int option;
    json_name : string option;
    options : Field_options.t option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module Type' : sig
    type t =
      | Type_double
      | Type_float
      | Type_int64
      | Type_uint64
      | Type_int32
      | Type_fixed64
      | Type_fixed32
      | Type_bool
      | Type_string
      | Type_group
      | Type_message
      | Type_bytes
      | Type_uint32
      | Type_enum
      | Type_sfixed32
      | Type_sfixed64
      | Type_sint32
      | Type_sint64
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | Type_double
      | Type_float
      | Type_int64
      | Type_uint64
      | Type_int32
      | Type_fixed64
      | Type_fixed32
      | Type_bool
      | Type_string
      | Type_group
      | Type_message
      | Type_bytes
      | Type_uint32
      | Type_enum
      | Type_sfixed32
      | Type_sfixed64
      | Type_sint32
      | Type_sint64
  
    let default =
      fun () -> Type_double
  
    let to_int =
      function
      | Type_double -> 1
      | Type_float -> 2
      | Type_int64 -> 3
      | Type_uint64 -> 4
      | Type_int32 -> 5
      | Type_fixed64 -> 6
      | Type_fixed32 -> 7
      | Type_bool -> 8
      | Type_string -> 9
      | Type_group -> 10
      | Type_message -> 11
      | Type_bytes -> 12
      | Type_uint32 -> 13
      | Type_enum -> 14
      | Type_sfixed32 -> 15
      | Type_sfixed64 -> 16
      | Type_sint32 -> 17
      | Type_sint64 -> 18
  
    let of_int =
      function
      | 1 -> Some Type_double
      | 2 -> Some Type_float
      | 3 -> Some Type_int64
      | 4 -> Some Type_uint64
      | 5 -> Some Type_int32
      | 6 -> Some Type_fixed64
      | 7 -> Some Type_fixed32
      | 8 -> Some Type_bool
      | 9 -> Some Type_string
      | 10 -> Some Type_group
      | 11 -> Some Type_message
      | 12 -> Some Type_bytes
      | 13 -> Some Type_uint32
      | 14 -> Some Type_enum
      | 15 -> Some Type_sfixed32
      | 16 -> Some Type_sfixed64
      | 17 -> Some Type_sint32
      | 18 -> Some Type_sint64
      | _ -> None
  
    let to_string =
      function
      | Type_double -> "TYPE_DOUBLE"
      | Type_float -> "TYPE_FLOAT"
      | Type_int64 -> "TYPE_INT64"
      | Type_uint64 -> "TYPE_UINT64"
      | Type_int32 -> "TYPE_INT32"
      | Type_fixed64 -> "TYPE_FIXED64"
      | Type_fixed32 -> "TYPE_FIXED32"
      | Type_bool -> "TYPE_BOOL"
      | Type_string -> "TYPE_STRING"
      | Type_group -> "TYPE_GROUP"
      | Type_message -> "TYPE_MESSAGE"
      | Type_bytes -> "TYPE_BYTES"
      | Type_uint32 -> "TYPE_UINT32"
      | Type_enum -> "TYPE_ENUM"
      | Type_sfixed32 -> "TYPE_SFIXED32"
      | Type_sfixed64 -> "TYPE_SFIXED64"
      | Type_sint32 -> "TYPE_SINT32"
      | Type_sint64 -> "TYPE_SINT64"
  
    let of_string =
      function
      | "TYPE_DOUBLE" -> Some Type_double
      | "TYPE_FLOAT" -> Some Type_float
      | "TYPE_INT64" -> Some Type_int64
      | "TYPE_UINT64" -> Some Type_uint64
      | "TYPE_INT32" -> Some Type_int32
      | "TYPE_FIXED64" -> Some Type_fixed64
      | "TYPE_FIXED32" -> Some Type_fixed32
      | "TYPE_BOOL" -> Some Type_bool
      | "TYPE_STRING" -> Some Type_string
      | "TYPE_GROUP" -> Some Type_group
      | "TYPE_MESSAGE" -> Some Type_message
      | "TYPE_BYTES" -> Some Type_bytes
      | "TYPE_UINT32" -> Some Type_uint32
      | "TYPE_ENUM" -> Some Type_enum
      | "TYPE_SFIXED32" -> Some Type_sfixed32
      | "TYPE_SFIXED64" -> Some Type_sfixed64
      | "TYPE_SINT32" -> Some Type_sint32
      | "TYPE_SINT64" -> Some Type_sint64
      | _ -> None
  end
  
  module Label : sig
    type t =
      | Label_optional
      | Label_required
      | Label_repeated
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | Label_optional
      | Label_required
      | Label_repeated
  
    let default =
      fun () -> Label_optional
  
    let to_int =
      function
      | Label_optional -> 1
      | Label_required -> 2
      | Label_repeated -> 3
  
    let of_int =
      function
      | 1 -> Some Label_optional
      | 2 -> Some Label_required
      | 3 -> Some Label_repeated
      | _ -> None
  
    let to_string =
      function
      | Label_optional -> "LABEL_OPTIONAL"
      | Label_required -> "LABEL_REQUIRED"
      | Label_repeated -> "LABEL_REPEATED"
  
    let of_string =
      function
      | "LABEL_OPTIONAL" -> Some Label_optional
      | "LABEL_REQUIRED" -> Some Label_required
      | "LABEL_REPEATED" -> Some Label_repeated
      | _ -> None
  end

  type t = {
    name : string option;
    number : int option;
    label : Field_descriptor_proto.Label.t;
    type' : Field_descriptor_proto.Type'.t;
    type_name : string option;
    extendee : string option;
    default_value : string option;
    oneof_index : int option;
    json_name : string option;
    options : Field_options.t option;
  }

  let rec serialize =
    fun { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_optional_field 3 F'.Int32_t number o' >>= fun () ->
      B'.serialize_enum_field 4 Field_descriptor_proto.Label.to_int label o' >>= fun () ->
      B'.serialize_enum_field 5 Field_descriptor_proto.Type'.to_int type' o' >>= fun () ->
      B'.serialize_optional_field 6 F'.String_t type_name o' >>= fun () ->
      B'.serialize_optional_field 2 F'.String_t extendee o' >>= fun () ->
      B'.serialize_optional_field 7 F'.String_t default_value o' >>= fun () ->
      B'.serialize_optional_field 9 F'.Int32_t oneof_index o' >>= fun () ->
      B'.serialize_optional_field 10 F'.String_t json_name o' >>= fun () ->
      B'.serialize_user_field 8 Field_options.serialize options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_optional_field 3 F'.Int32_t m' >>= fun number ->
      B'.decode_enum_field 4 Field_descriptor_proto.Label.of_int Field_descriptor_proto.Label.default m' >>= fun label ->
      B'.decode_enum_field 5 Field_descriptor_proto.Type'.of_int Field_descriptor_proto.Type'.default m' >>= fun type' ->
      B'.decode_optional_field 6 F'.String_t m' >>= fun type_name ->
      B'.decode_optional_field 2 F'.String_t m' >>= fun extendee ->
      B'.decode_optional_field 7 F'.String_t m' >>= fun default_value ->
      B'.decode_optional_field 9 F'.Int32_t m' >>= fun oneof_index ->
      B'.decode_optional_field 10 F'.String_t m' >>= fun json_name ->
      B'.decode_user_field 8 Field_options.deserialize m' >>= fun options ->
      Ok { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options }

  let rec stringify =
    fun { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_optional_field "number" F'.Int32_t number o' >>= fun () ->
      T'.serialize_enum_field "label" Field_descriptor_proto.Label.to_string label o' >>= fun () ->
      T'.serialize_enum_field "type'" Field_descriptor_proto.Type'.to_string type' o' >>= fun () ->
      T'.serialize_optional_field "type_name" F'.String_t type_name o' >>= fun () ->
      T'.serialize_optional_field "extendee" F'.String_t extendee o' >>= fun () ->
      T'.serialize_optional_field "default_value" F'.String_t default_value o' >>= fun () ->
      T'.serialize_optional_field "oneof_index" F'.Int32_t oneof_index o' >>= fun () ->
      T'.serialize_optional_field "json_name" F'.String_t json_name o' >>= fun () ->
      T'.serialize_user_field "options" Field_options.stringify options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_optional_field "number" F'.Int32_t m' >>= fun number ->
      T'.decode_enum_field "label" Field_descriptor_proto.Label.of_string Field_descriptor_proto.Label.default m' >>= fun label ->
      T'.decode_enum_field "type'" Field_descriptor_proto.Type'.of_string Field_descriptor_proto.Type'.default m' >>= fun type' ->
      T'.decode_optional_field "type_name" F'.String_t m' >>= fun type_name ->
      T'.decode_optional_field "extendee" F'.String_t m' >>= fun extendee ->
      T'.decode_optional_field "default_value" F'.String_t m' >>= fun default_value ->
      T'.decode_optional_field "oneof_index" F'.Int32_t m' >>= fun oneof_index ->
      T'.decode_optional_field "json_name" F'.String_t m' >>= fun json_name ->
      T'.decode_user_field "options" Field_options.unstringify m' >>= fun options ->
      Ok { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options }
end

and Oneof_descriptor_proto : sig
  type t = {
    name : string option;
    options : Oneof_options.t option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string option;
    options : Oneof_options.t option;
  }

  let rec serialize =
    fun { name; options } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_user_field 2 Oneof_options.serialize options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_user_field 2 Oneof_options.deserialize m' >>= fun options ->
      Ok { name; options }

  let rec stringify =
    fun { name; options } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_user_field "options" Oneof_options.stringify options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_user_field "options" Oneof_options.unstringify m' >>= fun options ->
      Ok { name; options }
end

and Enum_descriptor_proto : sig
  module rec Enum_reserved_range : sig
    type t = {
      start : int option;
      end' : int option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    name : string option;
    value' : Enum_value_descriptor_proto.t list;
    options : Enum_options.t option;
    reserved_range : Enum_descriptor_proto.Enum_reserved_range.t list;
    reserved_name : string list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Enum_reserved_range : sig
    type t = {
      start : int option;
      end' : int option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      start : int option;
      end' : int option;
    }
  
    let rec serialize =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        B'.serialize_optional_field 1 F'.Int32_t start o' >>= fun () ->
        B'.serialize_optional_field 2 F'.Int32_t end' o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        B'.deserialize_message >>= fun m' ->
        B'.decode_optional_field 1 F'.Int32_t m' >>= fun start ->
        B'.decode_optional_field 2 F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  
    let rec stringify =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        T'.serialize_optional_field "start" F'.Int32_t start o' >>= fun () ->
        T'.serialize_optional_field "end'" F'.Int32_t end' o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_optional_field "start" F'.Int32_t m' >>= fun start ->
        T'.decode_optional_field "end'" F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  end

  type t = {
    name : string option;
    value' : Enum_value_descriptor_proto.t list;
    options : Enum_options.t option;
    reserved_range : Enum_descriptor_proto.Enum_reserved_range.t list;
    reserved_name : string list;
  }

  let rec serialize =
    fun { name; value'; options; reserved_range; reserved_name } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_repeated_user_field 2 Enum_value_descriptor_proto.serialize value' o' >>= fun () ->
      B'.serialize_user_field 3 Enum_options.serialize options o' >>= fun () ->
      B'.serialize_repeated_user_field 4 Enum_descriptor_proto.Enum_reserved_range.serialize reserved_range o' >>= fun () ->
      B'.serialize_repeated_field 5 F'.String_t reserved_name o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_repeated_user_field 2 Enum_value_descriptor_proto.deserialize m' >>= fun value' ->
      B'.decode_user_field 3 Enum_options.deserialize m' >>= fun options ->
      B'.decode_repeated_user_field 4 Enum_descriptor_proto.Enum_reserved_range.deserialize m' >>= fun reserved_range ->
      B'.decode_repeated_field 5 F'.String_t m' >>= fun reserved_name ->
      Ok { name; value'; options; reserved_range; reserved_name }

  let rec stringify =
    fun { name; value'; options; reserved_range; reserved_name } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_repeated_user_field "value'" Enum_value_descriptor_proto.stringify value' o' >>= fun () ->
      T'.serialize_user_field "options" Enum_options.stringify options o' >>= fun () ->
      T'.serialize_repeated_user_field "reserved_range" Enum_descriptor_proto.Enum_reserved_range.stringify reserved_range o' >>= fun () ->
      T'.serialize_repeated_field "reserved_name" F'.String_t reserved_name o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_repeated_user_field "value'" Enum_value_descriptor_proto.unstringify m' >>= fun value' ->
      T'.decode_user_field "options" Enum_options.unstringify m' >>= fun options ->
      T'.decode_repeated_user_field "reserved_range" Enum_descriptor_proto.Enum_reserved_range.unstringify m' >>= fun reserved_range ->
      T'.decode_repeated_field "reserved_name" F'.String_t m' >>= fun reserved_name ->
      Ok { name; value'; options; reserved_range; reserved_name }
end

and Enum_value_descriptor_proto : sig
  type t = {
    name : string option;
    number : int option;
    options : Enum_value_options.t option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string option;
    number : int option;
    options : Enum_value_options.t option;
  }

  let rec serialize =
    fun { name; number; options } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_optional_field 2 F'.Int32_t number o' >>= fun () ->
      B'.serialize_user_field 3 Enum_value_options.serialize options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_optional_field 2 F'.Int32_t m' >>= fun number ->
      B'.decode_user_field 3 Enum_value_options.deserialize m' >>= fun options ->
      Ok { name; number; options }

  let rec stringify =
    fun { name; number; options } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_optional_field "number" F'.Int32_t number o' >>= fun () ->
      T'.serialize_user_field "options" Enum_value_options.stringify options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_optional_field "number" F'.Int32_t m' >>= fun number ->
      T'.decode_user_field "options" Enum_value_options.unstringify m' >>= fun options ->
      Ok { name; number; options }
end

and Service_descriptor_proto : sig
  type t = {
    name : string option;
    method' : Method_descriptor_proto.t list;
    options : Service_options.t option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string option;
    method' : Method_descriptor_proto.t list;
    options : Service_options.t option;
  }

  let rec serialize =
    fun { name; method'; options } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_repeated_user_field 2 Method_descriptor_proto.serialize method' o' >>= fun () ->
      B'.serialize_user_field 3 Service_options.serialize options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_repeated_user_field 2 Method_descriptor_proto.deserialize m' >>= fun method' ->
      B'.decode_user_field 3 Service_options.deserialize m' >>= fun options ->
      Ok { name; method'; options }

  let rec stringify =
    fun { name; method'; options } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_repeated_user_field "method'" Method_descriptor_proto.stringify method' o' >>= fun () ->
      T'.serialize_user_field "options" Service_options.stringify options o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_repeated_user_field "method'" Method_descriptor_proto.unstringify m' >>= fun method' ->
      T'.decode_user_field "options" Service_options.unstringify m' >>= fun options ->
      Ok { name; method'; options }
end

and Method_descriptor_proto : sig
  type t = {
    name : string option;
    input_type : string option;
    output_type : string option;
    options : Method_options.t option;
    client_streaming : bool option;
    server_streaming : bool option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string option;
    input_type : string option;
    output_type : string option;
    options : Method_options.t option;
    client_streaming : bool option;
    server_streaming : bool option;
  }

  let rec serialize =
    fun { name; input_type; output_type; options; client_streaming; server_streaming } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t name o' >>= fun () ->
      B'.serialize_optional_field 2 F'.String_t input_type o' >>= fun () ->
      B'.serialize_optional_field 3 F'.String_t output_type o' >>= fun () ->
      B'.serialize_user_field 4 Method_options.serialize options o' >>= fun () ->
      B'.serialize_optional_field 5 F'.Bool_t client_streaming o' >>= fun () ->
      B'.serialize_optional_field 6 F'.Bool_t server_streaming o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun name ->
      B'.decode_optional_field 2 F'.String_t m' >>= fun input_type ->
      B'.decode_optional_field 3 F'.String_t m' >>= fun output_type ->
      B'.decode_user_field 4 Method_options.deserialize m' >>= fun options ->
      B'.decode_optional_field 5 F'.Bool_t m' >>= fun client_streaming ->
      B'.decode_optional_field 6 F'.Bool_t m' >>= fun server_streaming ->
      Ok { name; input_type; output_type; options; client_streaming; server_streaming }

  let rec stringify =
    fun { name; input_type; output_type; options; client_streaming; server_streaming } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "name" F'.String_t name o' >>= fun () ->
      T'.serialize_optional_field "input_type" F'.String_t input_type o' >>= fun () ->
      T'.serialize_optional_field "output_type" F'.String_t output_type o' >>= fun () ->
      T'.serialize_user_field "options" Method_options.stringify options o' >>= fun () ->
      T'.serialize_optional_field "client_streaming" F'.Bool_t client_streaming o' >>= fun () ->
      T'.serialize_optional_field "server_streaming" F'.Bool_t server_streaming o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "name" F'.String_t m' >>= fun name ->
      T'.decode_optional_field "input_type" F'.String_t m' >>= fun input_type ->
      T'.decode_optional_field "output_type" F'.String_t m' >>= fun output_type ->
      T'.decode_user_field "options" Method_options.unstringify m' >>= fun options ->
      T'.decode_optional_field "client_streaming" F'.Bool_t m' >>= fun client_streaming ->
      T'.decode_optional_field "server_streaming" F'.Bool_t m' >>= fun server_streaming ->
      Ok { name; input_type; output_type; options; client_streaming; server_streaming }
end

and File_options : sig
  module Optimize_mode : sig
    type t =
      | Speed
      | Code_size
      | Lite_runtime
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    java_package : string option;
    java_outer_classname : string option;
    java_multiple_files : bool option;
    java_generate_equals_and_hash : bool option;
    java_string_check_utf8 : bool option;
    optimize_for : File_options.Optimize_mode.t;
    go_package : string option;
    cc_generic_services : bool option;
    java_generic_services : bool option;
    py_generic_services : bool option;
    php_generic_services : bool option;
    deprecated : bool option;
    cc_enable_arenas : bool option;
    objc_class_prefix : string option;
    csharp_namespace : string option;
    swift_prefix : string option;
    php_class_prefix : string option;
    php_namespace : string option;
    php_metadata_namespace : string option;
    ruby_package : string option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module Optimize_mode : sig
    type t =
      | Speed
      | Code_size
      | Lite_runtime
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | Speed
      | Code_size
      | Lite_runtime
  
    let default =
      fun () -> Speed
  
    let to_int =
      function
      | Speed -> 1
      | Code_size -> 2
      | Lite_runtime -> 3
  
    let of_int =
      function
      | 1 -> Some Speed
      | 2 -> Some Code_size
      | 3 -> Some Lite_runtime
      | _ -> None
  
    let to_string =
      function
      | Speed -> "SPEED"
      | Code_size -> "CODE_SIZE"
      | Lite_runtime -> "LITE_RUNTIME"
  
    let of_string =
      function
      | "SPEED" -> Some Speed
      | "CODE_SIZE" -> Some Code_size
      | "LITE_RUNTIME" -> Some Lite_runtime
      | _ -> None
  end

  type t = {
    java_package : string option;
    java_outer_classname : string option;
    java_multiple_files : bool option;
    java_generate_equals_and_hash : bool option;
    java_string_check_utf8 : bool option;
    optimize_for : File_options.Optimize_mode.t;
    go_package : string option;
    cc_generic_services : bool option;
    java_generic_services : bool option;
    py_generic_services : bool option;
    php_generic_services : bool option;
    deprecated : bool option;
    cc_enable_arenas : bool option;
    objc_class_prefix : string option;
    csharp_namespace : string option;
    swift_prefix : string option;
    php_class_prefix : string option;
    php_namespace : string option;
    php_metadata_namespace : string option;
    ruby_package : string option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; php_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; swift_prefix; php_class_prefix; php_namespace; php_metadata_namespace; ruby_package; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.String_t java_package o' >>= fun () ->
      B'.serialize_optional_field 8 F'.String_t java_outer_classname o' >>= fun () ->
      B'.serialize_optional_field 10 F'.Bool_t java_multiple_files o' >>= fun () ->
      B'.serialize_optional_field 20 F'.Bool_t java_generate_equals_and_hash o' >>= fun () ->
      B'.serialize_optional_field 27 F'.Bool_t java_string_check_utf8 o' >>= fun () ->
      B'.serialize_enum_field 9 File_options.Optimize_mode.to_int optimize_for o' >>= fun () ->
      B'.serialize_optional_field 11 F'.String_t go_package o' >>= fun () ->
      B'.serialize_optional_field 16 F'.Bool_t cc_generic_services o' >>= fun () ->
      B'.serialize_optional_field 17 F'.Bool_t java_generic_services o' >>= fun () ->
      B'.serialize_optional_field 18 F'.Bool_t py_generic_services o' >>= fun () ->
      B'.serialize_optional_field 42 F'.Bool_t php_generic_services o' >>= fun () ->
      B'.serialize_optional_field 23 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_optional_field 31 F'.Bool_t cc_enable_arenas o' >>= fun () ->
      B'.serialize_optional_field 36 F'.String_t objc_class_prefix o' >>= fun () ->
      B'.serialize_optional_field 37 F'.String_t csharp_namespace o' >>= fun () ->
      B'.serialize_optional_field 39 F'.String_t swift_prefix o' >>= fun () ->
      B'.serialize_optional_field 40 F'.String_t php_class_prefix o' >>= fun () ->
      B'.serialize_optional_field 41 F'.String_t php_namespace o' >>= fun () ->
      B'.serialize_optional_field 44 F'.String_t php_metadata_namespace o' >>= fun () ->
      B'.serialize_optional_field 45 F'.String_t ruby_package o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.String_t m' >>= fun java_package ->
      B'.decode_optional_field 8 F'.String_t m' >>= fun java_outer_classname ->
      B'.decode_optional_field 10 F'.Bool_t m' >>= fun java_multiple_files ->
      B'.decode_optional_field 20 F'.Bool_t m' >>= fun java_generate_equals_and_hash ->
      B'.decode_optional_field 27 F'.Bool_t m' >>= fun java_string_check_utf8 ->
      B'.decode_enum_field 9 File_options.Optimize_mode.of_int File_options.Optimize_mode.default m' >>= fun optimize_for ->
      B'.decode_optional_field 11 F'.String_t m' >>= fun go_package ->
      B'.decode_optional_field 16 F'.Bool_t m' >>= fun cc_generic_services ->
      B'.decode_optional_field 17 F'.Bool_t m' >>= fun java_generic_services ->
      B'.decode_optional_field 18 F'.Bool_t m' >>= fun py_generic_services ->
      B'.decode_optional_field 42 F'.Bool_t m' >>= fun php_generic_services ->
      B'.decode_optional_field 23 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_optional_field 31 F'.Bool_t m' >>= fun cc_enable_arenas ->
      B'.decode_optional_field 36 F'.String_t m' >>= fun objc_class_prefix ->
      B'.decode_optional_field 37 F'.String_t m' >>= fun csharp_namespace ->
      B'.decode_optional_field 39 F'.String_t m' >>= fun swift_prefix ->
      B'.decode_optional_field 40 F'.String_t m' >>= fun php_class_prefix ->
      B'.decode_optional_field 41 F'.String_t m' >>= fun php_namespace ->
      B'.decode_optional_field 44 F'.String_t m' >>= fun php_metadata_namespace ->
      B'.decode_optional_field 45 F'.String_t m' >>= fun ruby_package ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; php_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; swift_prefix; php_class_prefix; php_namespace; php_metadata_namespace; ruby_package; uninterpreted_option }

  let rec stringify =
    fun { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; php_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; swift_prefix; php_class_prefix; php_namespace; php_metadata_namespace; ruby_package; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "java_package" F'.String_t java_package o' >>= fun () ->
      T'.serialize_optional_field "java_outer_classname" F'.String_t java_outer_classname o' >>= fun () ->
      T'.serialize_optional_field "java_multiple_files" F'.Bool_t java_multiple_files o' >>= fun () ->
      T'.serialize_optional_field "java_generate_equals_and_hash" F'.Bool_t java_generate_equals_and_hash o' >>= fun () ->
      T'.serialize_optional_field "java_string_check_utf8" F'.Bool_t java_string_check_utf8 o' >>= fun () ->
      T'.serialize_enum_field "optimize_for" File_options.Optimize_mode.to_string optimize_for o' >>= fun () ->
      T'.serialize_optional_field "go_package" F'.String_t go_package o' >>= fun () ->
      T'.serialize_optional_field "cc_generic_services" F'.Bool_t cc_generic_services o' >>= fun () ->
      T'.serialize_optional_field "java_generic_services" F'.Bool_t java_generic_services o' >>= fun () ->
      T'.serialize_optional_field "py_generic_services" F'.Bool_t py_generic_services o' >>= fun () ->
      T'.serialize_optional_field "php_generic_services" F'.Bool_t php_generic_services o' >>= fun () ->
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_optional_field "cc_enable_arenas" F'.Bool_t cc_enable_arenas o' >>= fun () ->
      T'.serialize_optional_field "objc_class_prefix" F'.String_t objc_class_prefix o' >>= fun () ->
      T'.serialize_optional_field "csharp_namespace" F'.String_t csharp_namespace o' >>= fun () ->
      T'.serialize_optional_field "swift_prefix" F'.String_t swift_prefix o' >>= fun () ->
      T'.serialize_optional_field "php_class_prefix" F'.String_t php_class_prefix o' >>= fun () ->
      T'.serialize_optional_field "php_namespace" F'.String_t php_namespace o' >>= fun () ->
      T'.serialize_optional_field "php_metadata_namespace" F'.String_t php_metadata_namespace o' >>= fun () ->
      T'.serialize_optional_field "ruby_package" F'.String_t ruby_package o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "java_package" F'.String_t m' >>= fun java_package ->
      T'.decode_optional_field "java_outer_classname" F'.String_t m' >>= fun java_outer_classname ->
      T'.decode_optional_field "java_multiple_files" F'.Bool_t m' >>= fun java_multiple_files ->
      T'.decode_optional_field "java_generate_equals_and_hash" F'.Bool_t m' >>= fun java_generate_equals_and_hash ->
      T'.decode_optional_field "java_string_check_utf8" F'.Bool_t m' >>= fun java_string_check_utf8 ->
      T'.decode_enum_field "optimize_for" File_options.Optimize_mode.of_string File_options.Optimize_mode.default m' >>= fun optimize_for ->
      T'.decode_optional_field "go_package" F'.String_t m' >>= fun go_package ->
      T'.decode_optional_field "cc_generic_services" F'.Bool_t m' >>= fun cc_generic_services ->
      T'.decode_optional_field "java_generic_services" F'.Bool_t m' >>= fun java_generic_services ->
      T'.decode_optional_field "py_generic_services" F'.Bool_t m' >>= fun py_generic_services ->
      T'.decode_optional_field "php_generic_services" F'.Bool_t m' >>= fun php_generic_services ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_optional_field "cc_enable_arenas" F'.Bool_t m' >>= fun cc_enable_arenas ->
      T'.decode_optional_field "objc_class_prefix" F'.String_t m' >>= fun objc_class_prefix ->
      T'.decode_optional_field "csharp_namespace" F'.String_t m' >>= fun csharp_namespace ->
      T'.decode_optional_field "swift_prefix" F'.String_t m' >>= fun swift_prefix ->
      T'.decode_optional_field "php_class_prefix" F'.String_t m' >>= fun php_class_prefix ->
      T'.decode_optional_field "php_namespace" F'.String_t m' >>= fun php_namespace ->
      T'.decode_optional_field "php_metadata_namespace" F'.String_t m' >>= fun php_metadata_namespace ->
      T'.decode_optional_field "ruby_package" F'.String_t m' >>= fun ruby_package ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; php_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; swift_prefix; php_class_prefix; php_namespace; php_metadata_namespace; ruby_package; uninterpreted_option }
end

and Message_options : sig
  type t = {
    message_set_wire_format : bool option;
    no_standard_descriptor_accessor : bool option;
    deprecated : bool option;
    map_entry : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    message_set_wire_format : bool option;
    no_standard_descriptor_accessor : bool option;
    deprecated : bool option;
    map_entry : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.Bool_t message_set_wire_format o' >>= fun () ->
      B'.serialize_optional_field 2 F'.Bool_t no_standard_descriptor_accessor o' >>= fun () ->
      B'.serialize_optional_field 3 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_optional_field 7 F'.Bool_t map_entry o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.Bool_t m' >>= fun message_set_wire_format ->
      B'.decode_optional_field 2 F'.Bool_t m' >>= fun no_standard_descriptor_accessor ->
      B'.decode_optional_field 3 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_optional_field 7 F'.Bool_t m' >>= fun map_entry ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option }

  let rec stringify =
    fun { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "message_set_wire_format" F'.Bool_t message_set_wire_format o' >>= fun () ->
      T'.serialize_optional_field "no_standard_descriptor_accessor" F'.Bool_t no_standard_descriptor_accessor o' >>= fun () ->
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_optional_field "map_entry" F'.Bool_t map_entry o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "message_set_wire_format" F'.Bool_t m' >>= fun message_set_wire_format ->
      T'.decode_optional_field "no_standard_descriptor_accessor" F'.Bool_t m' >>= fun no_standard_descriptor_accessor ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_optional_field "map_entry" F'.Bool_t m' >>= fun map_entry ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option }
end

and Field_options : sig
  module C_type : sig
    type t =
      | String
      | Cord
      | String_piece
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end
  
  module J_s_type : sig
    type t =
      | Js_normal
      | Js_string
      | Js_number
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    ctype : Field_options.C_type.t;
    packed : bool option;
    jstype : Field_options.J_s_type.t;
    lazy' : bool option;
    deprecated : bool option;
    weak : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module C_type : sig
    type t =
      | String
      | Cord
      | String_piece
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | String
      | Cord
      | String_piece
  
    let default =
      fun () -> String
  
    let to_int =
      function
      | String -> 0
      | Cord -> 1
      | String_piece -> 2
  
    let of_int =
      function
      | 0 -> Some String
      | 1 -> Some Cord
      | 2 -> Some String_piece
      | _ -> None
  
    let to_string =
      function
      | String -> "STRING"
      | Cord -> "CORD"
      | String_piece -> "STRING_PIECE"
  
    let of_string =
      function
      | "STRING" -> Some String
      | "CORD" -> Some Cord
      | "STRING_PIECE" -> Some String_piece
      | _ -> None
  end
  
  module J_s_type : sig
    type t =
      | Js_normal
      | Js_string
      | Js_number
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | Js_normal
      | Js_string
      | Js_number
  
    let default =
      fun () -> Js_normal
  
    let to_int =
      function
      | Js_normal -> 0
      | Js_string -> 1
      | Js_number -> 2
  
    let of_int =
      function
      | 0 -> Some Js_normal
      | 1 -> Some Js_string
      | 2 -> Some Js_number
      | _ -> None
  
    let to_string =
      function
      | Js_normal -> "JS_NORMAL"
      | Js_string -> "JS_STRING"
      | Js_number -> "JS_NUMBER"
  
    let of_string =
      function
      | "JS_NORMAL" -> Some Js_normal
      | "JS_STRING" -> Some Js_string
      | "JS_NUMBER" -> Some Js_number
      | _ -> None
  end

  type t = {
    ctype : Field_options.C_type.t;
    packed : bool option;
    jstype : Field_options.J_s_type.t;
    lazy' : bool option;
    deprecated : bool option;
    weak : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_enum_field 1 Field_options.C_type.to_int ctype o' >>= fun () ->
      B'.serialize_optional_field 2 F'.Bool_t packed o' >>= fun () ->
      B'.serialize_enum_field 6 Field_options.J_s_type.to_int jstype o' >>= fun () ->
      B'.serialize_optional_field 5 F'.Bool_t lazy' o' >>= fun () ->
      B'.serialize_optional_field 3 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_optional_field 10 F'.Bool_t weak o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_enum_field 1 Field_options.C_type.of_int Field_options.C_type.default m' >>= fun ctype ->
      B'.decode_optional_field 2 F'.Bool_t m' >>= fun packed ->
      B'.decode_enum_field 6 Field_options.J_s_type.of_int Field_options.J_s_type.default m' >>= fun jstype ->
      B'.decode_optional_field 5 F'.Bool_t m' >>= fun lazy' ->
      B'.decode_optional_field 3 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_optional_field 10 F'.Bool_t m' >>= fun weak ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option }

  let rec stringify =
    fun { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_enum_field "ctype" Field_options.C_type.to_string ctype o' >>= fun () ->
      T'.serialize_optional_field "packed" F'.Bool_t packed o' >>= fun () ->
      T'.serialize_enum_field "jstype" Field_options.J_s_type.to_string jstype o' >>= fun () ->
      T'.serialize_optional_field "lazy'" F'.Bool_t lazy' o' >>= fun () ->
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_optional_field "weak" F'.Bool_t weak o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_enum_field "ctype" Field_options.C_type.of_string Field_options.C_type.default m' >>= fun ctype ->
      T'.decode_optional_field "packed" F'.Bool_t m' >>= fun packed ->
      T'.decode_enum_field "jstype" Field_options.J_s_type.of_string Field_options.J_s_type.default m' >>= fun jstype ->
      T'.decode_optional_field "lazy'" F'.Bool_t m' >>= fun lazy' ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_optional_field "weak" F'.Bool_t m' >>= fun weak ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option }
end

and Oneof_options : sig
  type t = {
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { uninterpreted_option }

  let rec stringify =
    fun { uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { uninterpreted_option }
end

and Enum_options : sig
  type t = {
    allow_alias : bool option;
    deprecated : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    allow_alias : bool option;
    deprecated : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { allow_alias; deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 2 F'.Bool_t allow_alias o' >>= fun () ->
      B'.serialize_optional_field 3 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 2 F'.Bool_t m' >>= fun allow_alias ->
      B'.decode_optional_field 3 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { allow_alias; deprecated; uninterpreted_option }

  let rec stringify =
    fun { allow_alias; deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "allow_alias" F'.Bool_t allow_alias o' >>= fun () ->
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "allow_alias" F'.Bool_t m' >>= fun allow_alias ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { allow_alias; deprecated; uninterpreted_option }
end

and Enum_value_options : sig
  type t = {
    deprecated : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    deprecated : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 1 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 1 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }

  let rec stringify =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }
end

and Service_options : sig
  type t = {
    deprecated : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    deprecated : bool option;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 33 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 33 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }

  let rec stringify =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }
end

and Method_options : sig
  module Idempotency_level : sig
    type t =
      | Idempotency_unknown
      | No_side_effects
      | Idempotent
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    deprecated : bool option;
    idempotency_level : Method_options.Idempotency_level.t;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module Idempotency_level : sig
    type t =
      | Idempotency_unknown
      | No_side_effects
      | Idempotent
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | Idempotency_unknown
      | No_side_effects
      | Idempotent
  
    let default =
      fun () -> Idempotency_unknown
  
    let to_int =
      function
      | Idempotency_unknown -> 0
      | No_side_effects -> 1
      | Idempotent -> 2
  
    let of_int =
      function
      | 0 -> Some Idempotency_unknown
      | 1 -> Some No_side_effects
      | 2 -> Some Idempotent
      | _ -> None
  
    let to_string =
      function
      | Idempotency_unknown -> "IDEMPOTENCY_UNKNOWN"
      | No_side_effects -> "NO_SIDE_EFFECTS"
      | Idempotent -> "IDEMPOTENT"
  
    let of_string =
      function
      | "IDEMPOTENCY_UNKNOWN" -> Some Idempotency_unknown
      | "NO_SIDE_EFFECTS" -> Some No_side_effects
      | "IDEMPOTENT" -> Some Idempotent
      | _ -> None
  end

  type t = {
    deprecated : bool option;
    idempotency_level : Method_options.Idempotency_level.t;
    uninterpreted_option : Uninterpreted_option.t list;
  }

  let rec serialize =
    fun { deprecated; idempotency_level; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_optional_field 33 F'.Bool_t deprecated o' >>= fun () ->
      B'.serialize_enum_field 34 Method_options.Idempotency_level.to_int idempotency_level o' >>= fun () ->
      B'.serialize_repeated_user_field 999 Uninterpreted_option.serialize uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_optional_field 33 F'.Bool_t m' >>= fun deprecated ->
      B'.decode_enum_field 34 Method_options.Idempotency_level.of_int Method_options.Idempotency_level.default m' >>= fun idempotency_level ->
      B'.decode_repeated_user_field 999 Uninterpreted_option.deserialize m' >>= fun uninterpreted_option ->
      Ok { deprecated; idempotency_level; uninterpreted_option }

  let rec stringify =
    fun { deprecated; idempotency_level; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_optional_field "deprecated" F'.Bool_t deprecated o' >>= fun () ->
      T'.serialize_enum_field "idempotency_level" Method_options.Idempotency_level.to_string idempotency_level o' >>= fun () ->
      T'.serialize_repeated_user_field "uninterpreted_option" Uninterpreted_option.stringify uninterpreted_option o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_optional_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_enum_field "idempotency_level" Method_options.Idempotency_level.of_string Method_options.Idempotency_level.default m' >>= fun idempotency_level ->
      T'.decode_repeated_user_field "uninterpreted_option" Uninterpreted_option.unstringify m' >>= fun uninterpreted_option ->
      Ok { deprecated; idempotency_level; uninterpreted_option }
end

and Uninterpreted_option : sig
  module rec Name_part : sig
    type t = {
      name_part : string option;
      is_extension : bool option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    name : Uninterpreted_option.Name_part.t list;
    identifier_value : string option;
    positive_int_value : int option;
    negative_int_value : int option;
    double_value : float option;
    string_value : string option;
    aggregate_value : string option;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Name_part : sig
    type t = {
      name_part : string option;
      is_extension : bool option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      name_part : string option;
      is_extension : bool option;
    }
  
    let rec serialize =
      fun { name_part; is_extension } ->
        let o' = Runtime.Byte_output.create () in
        B'.serialize_optional_field 1 F'.String_t name_part o' >>= fun () ->
        B'.serialize_optional_field 2 F'.Bool_t is_extension o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        B'.deserialize_message >>= fun m' ->
        B'.decode_optional_field 1 F'.String_t m' >>= fun name_part ->
        B'.decode_optional_field 2 F'.Bool_t m' >>= fun is_extension ->
        Ok { name_part; is_extension }
  
    let rec stringify =
      fun { name_part; is_extension } ->
        let o' = Runtime.Byte_output.create () in
        T'.serialize_optional_field "name_part" F'.String_t name_part o' >>= fun () ->
        T'.serialize_optional_field "is_extension" F'.Bool_t is_extension o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_optional_field "name_part" F'.String_t m' >>= fun name_part ->
        T'.decode_optional_field "is_extension" F'.Bool_t m' >>= fun is_extension ->
        Ok { name_part; is_extension }
  end

  type t = {
    name : Uninterpreted_option.Name_part.t list;
    identifier_value : string option;
    positive_int_value : int option;
    negative_int_value : int option;
    double_value : float option;
    string_value : string option;
    aggregate_value : string option;
  }

  let rec serialize =
    fun { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_repeated_user_field 2 Uninterpreted_option.Name_part.serialize name o' >>= fun () ->
      B'.serialize_optional_field 3 F'.String_t identifier_value o' >>= fun () ->
      B'.serialize_optional_field 4 F'.Uint64_t positive_int_value o' >>= fun () ->
      B'.serialize_optional_field 5 F'.Int64_t negative_int_value o' >>= fun () ->
      B'.serialize_optional_field 6 F'.Double_t double_value o' >>= fun () ->
      B'.serialize_optional_field 7 F'.Bytes_t string_value o' >>= fun () ->
      B'.serialize_optional_field 8 F'.String_t aggregate_value o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_repeated_user_field 2 Uninterpreted_option.Name_part.deserialize m' >>= fun name ->
      B'.decode_optional_field 3 F'.String_t m' >>= fun identifier_value ->
      B'.decode_optional_field 4 F'.Uint64_t m' >>= fun positive_int_value ->
      B'.decode_optional_field 5 F'.Int64_t m' >>= fun negative_int_value ->
      B'.decode_optional_field 6 F'.Double_t m' >>= fun double_value ->
      B'.decode_optional_field 7 F'.Bytes_t m' >>= fun string_value ->
      B'.decode_optional_field 8 F'.String_t m' >>= fun aggregate_value ->
      Ok { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value }

  let rec stringify =
    fun { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_repeated_user_field "name" Uninterpreted_option.Name_part.stringify name o' >>= fun () ->
      T'.serialize_optional_field "identifier_value" F'.String_t identifier_value o' >>= fun () ->
      T'.serialize_optional_field "positive_int_value" F'.Uint64_t positive_int_value o' >>= fun () ->
      T'.serialize_optional_field "negative_int_value" F'.Int64_t negative_int_value o' >>= fun () ->
      T'.serialize_optional_field "double_value" F'.Double_t double_value o' >>= fun () ->
      T'.serialize_optional_field "string_value" F'.Bytes_t string_value o' >>= fun () ->
      T'.serialize_optional_field "aggregate_value" F'.String_t aggregate_value o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_user_field "name" Uninterpreted_option.Name_part.unstringify m' >>= fun name ->
      T'.decode_optional_field "identifier_value" F'.String_t m' >>= fun identifier_value ->
      T'.decode_optional_field "positive_int_value" F'.Uint64_t m' >>= fun positive_int_value ->
      T'.decode_optional_field "negative_int_value" F'.Int64_t m' >>= fun negative_int_value ->
      T'.decode_optional_field "double_value" F'.Double_t m' >>= fun double_value ->
      T'.decode_optional_field "string_value" F'.Bytes_t m' >>= fun string_value ->
      T'.decode_optional_field "aggregate_value" F'.String_t m' >>= fun aggregate_value ->
      Ok { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value }
end

and Source_code_info : sig
  module rec Location : sig
    type t = {
      path : int list;
      span : int list;
      leading_comments : string option;
      trailing_comments : string option;
      leading_detached_comments : string list;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    location : Source_code_info.Location.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Location : sig
    type t = {
      path : int list;
      span : int list;
      leading_comments : string option;
      trailing_comments : string option;
      leading_detached_comments : string list;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      path : int list;
      span : int list;
      leading_comments : string option;
      trailing_comments : string option;
      leading_detached_comments : string list;
    }
  
    let rec serialize =
      fun { path; span; leading_comments; trailing_comments; leading_detached_comments } ->
        let o' = Runtime.Byte_output.create () in
        B'.serialize_repeated_field 1 F'.Int32_t path o' >>= fun () ->
        B'.serialize_repeated_field 2 F'.Int32_t span o' >>= fun () ->
        B'.serialize_optional_field 3 F'.String_t leading_comments o' >>= fun () ->
        B'.serialize_optional_field 4 F'.String_t trailing_comments o' >>= fun () ->
        B'.serialize_repeated_field 6 F'.String_t leading_detached_comments o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        B'.deserialize_message >>= fun m' ->
        B'.decode_repeated_field 1 F'.Int32_t m' >>= fun path ->
        B'.decode_repeated_field 2 F'.Int32_t m' >>= fun span ->
        B'.decode_optional_field 3 F'.String_t m' >>= fun leading_comments ->
        B'.decode_optional_field 4 F'.String_t m' >>= fun trailing_comments ->
        B'.decode_repeated_field 6 F'.String_t m' >>= fun leading_detached_comments ->
        Ok { path; span; leading_comments; trailing_comments; leading_detached_comments }
  
    let rec stringify =
      fun { path; span; leading_comments; trailing_comments; leading_detached_comments } ->
        let o' = Runtime.Byte_output.create () in
        T'.serialize_repeated_field "path" F'.Int32_t path o' >>= fun () ->
        T'.serialize_repeated_field "span" F'.Int32_t span o' >>= fun () ->
        T'.serialize_optional_field "leading_comments" F'.String_t leading_comments o' >>= fun () ->
        T'.serialize_optional_field "trailing_comments" F'.String_t trailing_comments o' >>= fun () ->
        T'.serialize_repeated_field "leading_detached_comments" F'.String_t leading_detached_comments o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_repeated_field "path" F'.Int32_t m' >>= fun path ->
        T'.decode_repeated_field "span" F'.Int32_t m' >>= fun span ->
        T'.decode_optional_field "leading_comments" F'.String_t m' >>= fun leading_comments ->
        T'.decode_optional_field "trailing_comments" F'.String_t m' >>= fun trailing_comments ->
        T'.decode_repeated_field "leading_detached_comments" F'.String_t m' >>= fun leading_detached_comments ->
        Ok { path; span; leading_comments; trailing_comments; leading_detached_comments }
  end

  type t = {
    location : Source_code_info.Location.t list;
  }

  let rec serialize =
    fun { location } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_repeated_user_field 1 Source_code_info.Location.serialize location o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_repeated_user_field 1 Source_code_info.Location.deserialize m' >>= fun location ->
      Ok { location }

  let rec stringify =
    fun { location } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_repeated_user_field "location" Source_code_info.Location.stringify location o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_user_field "location" Source_code_info.Location.unstringify m' >>= fun location ->
      Ok { location }
end

and Generated_code_info : sig
  module rec Annotation : sig
    type t = {
      path : int list;
      source_file : string option;
      begin' : int option;
      end' : int option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    annotation : Generated_code_info.Annotation.t list;
  }

  val serialize : t -> (string, [> B'.serialization_error]) result

  val deserialize : string -> (t, [> B'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Annotation : sig
    type t = {
      path : int list;
      source_file : string option;
      begin' : int option;
      end' : int option;
    }
  
    val serialize : t -> (string, [> B'.serialization_error]) result
  
    val deserialize : string -> (t, [> B'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      path : int list;
      source_file : string option;
      begin' : int option;
      end' : int option;
    }
  
    let rec serialize =
      fun { path; source_file; begin'; end' } ->
        let o' = Runtime.Byte_output.create () in
        B'.serialize_repeated_field 1 F'.Int32_t path o' >>= fun () ->
        B'.serialize_optional_field 2 F'.String_t source_file o' >>= fun () ->
        B'.serialize_optional_field 3 F'.Int32_t begin' o' >>= fun () ->
        B'.serialize_optional_field 4 F'.Int32_t end' o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        B'.deserialize_message >>= fun m' ->
        B'.decode_repeated_field 1 F'.Int32_t m' >>= fun path ->
        B'.decode_optional_field 2 F'.String_t m' >>= fun source_file ->
        B'.decode_optional_field 3 F'.Int32_t m' >>= fun begin' ->
        B'.decode_optional_field 4 F'.Int32_t m' >>= fun end' ->
        Ok { path; source_file; begin'; end' }
  
    let rec stringify =
      fun { path; source_file; begin'; end' } ->
        let o' = Runtime.Byte_output.create () in
        T'.serialize_repeated_field "path" F'.Int32_t path o' >>= fun () ->
        T'.serialize_optional_field "source_file" F'.String_t source_file o' >>= fun () ->
        T'.serialize_optional_field "begin'" F'.Int32_t begin' o' >>= fun () ->
        T'.serialize_optional_field "end'" F'.Int32_t end' o' >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_repeated_field "path" F'.Int32_t m' >>= fun path ->
        T'.decode_optional_field "source_file" F'.String_t m' >>= fun source_file ->
        T'.decode_optional_field "begin'" F'.Int32_t m' >>= fun begin' ->
        T'.decode_optional_field "end'" F'.Int32_t m' >>= fun end' ->
        Ok { path; source_file; begin'; end' }
  end

  type t = {
    annotation : Generated_code_info.Annotation.t list;
  }

  let rec serialize =
    fun { annotation } ->
      let o' = Runtime.Byte_output.create () in
      B'.serialize_repeated_user_field 1 Generated_code_info.Annotation.serialize annotation o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      B'.deserialize_message >>= fun m' ->
      B'.decode_repeated_user_field 1 Generated_code_info.Annotation.deserialize m' >>= fun annotation ->
      Ok { annotation }

  let rec stringify =
    fun { annotation } ->
      let o' = Runtime.Byte_output.create () in
      T'.serialize_repeated_user_field "annotation" Generated_code_info.Annotation.stringify annotation o' >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_repeated_user_field "annotation" Generated_code_info.Annotation.unstringify m' >>= fun annotation ->
      Ok { annotation }
end
