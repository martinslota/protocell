[@@@ocaml.warning "-39"]

let (>>=) = Runtime.Result.(>>=)

module F' = Runtime.Field_value

module T' = Runtime.Text_format

module W' = Runtime.Wire_format



module rec FileDescriptorSet : sig
  type t = {
    file : FileDescriptorProto.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    file : FileDescriptorProto.t list;
  }

  let rec serialize =
    fun { file } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_user_field 1 FileDescriptorProto.serialize file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      (W'.decode_repeated_user_field 1 FileDescriptorProto.deserialize m') >>= fun file ->
      Ok { file }

  let rec stringify =
    fun { file } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_user_field "file" FileDescriptorProto.stringify file o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      (T'.decode_repeated_user_field "file" FileDescriptorProto.unstringify m') >>= fun file ->
      Ok { file }
end

and FileDescriptorProto : sig
  type t = {
    name : string;
    package : string;
    dependency : string list;
    public_dependency : int list;
    weak_dependency : int list;
    message_type : DescriptorProto.t list;
    enum_type : EnumDescriptorProto.t list;
    service : ServiceDescriptorProto.t list;
    extension : FieldDescriptorProto.t list;
    options : FileOptions.t option;
    source_code_info : SourceCodeInfo.t option;
    syntax : string;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string;
    package : string;
    dependency : string list;
    public_dependency : int list;
    weak_dependency : int list;
    message_type : DescriptorProto.t list;
    enum_type : EnumDescriptorProto.t list;
    service : ServiceDescriptorProto.t list;
    extension : FieldDescriptorProto.t list;
    options : FileOptions.t option;
    source_code_info : SourceCodeInfo.t option;
    syntax : string;
  }

  let rec serialize =
    fun { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_field 2 F'.String_t package o') >>= fun () ->
      (W'.serialize_repeated_field 3 F'.String_t dependency o') >>= fun () ->
      (W'.serialize_repeated_field 10 F'.Int32_t public_dependency o') >>= fun () ->
      (W'.serialize_repeated_field 11 F'.Int32_t weak_dependency o') >>= fun () ->
      (W'.serialize_repeated_user_field 4 DescriptorProto.serialize message_type o') >>= fun () ->
      (W'.serialize_repeated_user_field 5 EnumDescriptorProto.serialize enum_type o') >>= fun () ->
      (W'.serialize_repeated_user_field 6 ServiceDescriptorProto.serialize service o') >>= fun () ->
      (W'.serialize_repeated_user_field 7 FieldDescriptorProto.serialize extension o') >>= fun () ->
      (W'.serialize_user_field 8 FileOptions.serialize options o') >>= fun () ->
      (W'.serialize_user_field 9 SourceCodeInfo.serialize source_code_info o') >>= fun () ->
      (W'.serialize_field 12 F'.String_t syntax o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      W'.decode_field 2 F'.String_t m' >>= fun package ->
      W'.decode_repeated_field 3 F'.String_t m' >>= fun dependency ->
      W'.decode_repeated_field 10 F'.Int32_t m' >>= fun public_dependency ->
      W'.decode_repeated_field 11 F'.Int32_t m' >>= fun weak_dependency ->
      (W'.decode_repeated_user_field 4 DescriptorProto.deserialize m') >>= fun message_type ->
      (W'.decode_repeated_user_field 5 EnumDescriptorProto.deserialize m') >>= fun enum_type ->
      (W'.decode_repeated_user_field 6 ServiceDescriptorProto.deserialize m') >>= fun service ->
      (W'.decode_repeated_user_field 7 FieldDescriptorProto.deserialize m') >>= fun extension ->
      (W'.decode_user_field 8 FileOptions.deserialize m') >>= fun options ->
      (W'.decode_user_field 9 SourceCodeInfo.deserialize m') >>= fun source_code_info ->
      W'.decode_field 12 F'.String_t m' >>= fun syntax ->
      Ok { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax }

  let rec stringify =
    fun { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_field "package" F'.String_t package o') >>= fun () ->
      (T'.serialize_repeated_field "dependency" F'.String_t dependency o') >>= fun () ->
      (T'.serialize_repeated_field "public_dependency" F'.Int32_t public_dependency o') >>= fun () ->
      (T'.serialize_repeated_field "weak_dependency" F'.Int32_t weak_dependency o') >>= fun () ->
      (T'.serialize_repeated_user_field "message_type" DescriptorProto.stringify message_type o') >>= fun () ->
      (T'.serialize_repeated_user_field "enum_type" EnumDescriptorProto.stringify enum_type o') >>= fun () ->
      (T'.serialize_repeated_user_field "service" ServiceDescriptorProto.stringify service o') >>= fun () ->
      (T'.serialize_repeated_user_field "extension" FieldDescriptorProto.stringify extension o') >>= fun () ->
      (T'.serialize_user_field "options" FileOptions.stringify options o') >>= fun () ->
      (T'.serialize_user_field "source_code_info" SourceCodeInfo.stringify source_code_info o') >>= fun () ->
      (T'.serialize_field "syntax" F'.String_t syntax o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      T'.decode_field "package" F'.String_t m' >>= fun package ->
      T'.decode_repeated_field "dependency" F'.String_t m' >>= fun dependency ->
      T'.decode_repeated_field "public_dependency" F'.Int32_t m' >>= fun public_dependency ->
      T'.decode_repeated_field "weak_dependency" F'.Int32_t m' >>= fun weak_dependency ->
      (T'.decode_repeated_user_field "message_type" DescriptorProto.unstringify m') >>= fun message_type ->
      (T'.decode_repeated_user_field "enum_type" EnumDescriptorProto.unstringify m') >>= fun enum_type ->
      (T'.decode_repeated_user_field "service" ServiceDescriptorProto.unstringify m') >>= fun service ->
      (T'.decode_repeated_user_field "extension" FieldDescriptorProto.unstringify m') >>= fun extension ->
      (T'.decode_user_field "options" FileOptions.unstringify m') >>= fun options ->
      (T'.decode_user_field "source_code_info" SourceCodeInfo.unstringify m') >>= fun source_code_info ->
      T'.decode_field "syntax" F'.String_t m' >>= fun syntax ->
      Ok { name; package; dependency; public_dependency; weak_dependency; message_type; enum_type; service; extension; options; source_code_info; syntax }
end

and DescriptorProto : sig
  module rec ExtensionRange : sig
    type t = {
      start : int;
      end' : int;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end
  
  and ReservedRange : sig
    type t = {
      start : int;
      end' : int;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    name : string;
    field : FieldDescriptorProto.t list;
    extension : FieldDescriptorProto.t list;
    nested_type : DescriptorProto.t list;
    enum_type : EnumDescriptorProto.t list;
    extension_range : DescriptorProto.ExtensionRange.t list;
    oneof_decl : OneofDescriptorProto.t list;
    options : MessageOptions.t option;
    reserved_range : DescriptorProto.ReservedRange.t list;
    reserved_name : string list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec ExtensionRange : sig
    type t = {
      start : int;
      end' : int;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      start : int;
      end' : int;
    }
  
    let rec serialize =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_field 1 F'.Int32_t start o') >>= fun () ->
        (W'.serialize_field 2 F'.Int32_t end' o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_field 1 F'.Int32_t m' >>= fun start ->
        W'.decode_field 2 F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  
    let rec stringify =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_field "start" F'.Int32_t start o') >>= fun () ->
        (T'.serialize_field "end'" F'.Int32_t end' o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_field "start" F'.Int32_t m' >>= fun start ->
        T'.decode_field "end'" F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  end
  
  and ReservedRange : sig
    type t = {
      start : int;
      end' : int;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      start : int;
      end' : int;
    }
  
    let rec serialize =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_field 1 F'.Int32_t start o') >>= fun () ->
        (W'.serialize_field 2 F'.Int32_t end' o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_field 1 F'.Int32_t m' >>= fun start ->
        W'.decode_field 2 F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  
    let rec stringify =
      fun { start; end' } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_field "start" F'.Int32_t start o') >>= fun () ->
        (T'.serialize_field "end'" F'.Int32_t end' o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_field "start" F'.Int32_t m' >>= fun start ->
        T'.decode_field "end'" F'.Int32_t m' >>= fun end' ->
        Ok { start; end' }
  end

  type t = {
    name : string;
    field : FieldDescriptorProto.t list;
    extension : FieldDescriptorProto.t list;
    nested_type : DescriptorProto.t list;
    enum_type : EnumDescriptorProto.t list;
    extension_range : DescriptorProto.ExtensionRange.t list;
    oneof_decl : OneofDescriptorProto.t list;
    options : MessageOptions.t option;
    reserved_range : DescriptorProto.ReservedRange.t list;
    reserved_name : string list;
  }

  let rec serialize =
    fun { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_repeated_user_field 2 FieldDescriptorProto.serialize field o') >>= fun () ->
      (W'.serialize_repeated_user_field 6 FieldDescriptorProto.serialize extension o') >>= fun () ->
      (W'.serialize_repeated_user_field 3 DescriptorProto.serialize nested_type o') >>= fun () ->
      (W'.serialize_repeated_user_field 4 EnumDescriptorProto.serialize enum_type o') >>= fun () ->
      (W'.serialize_repeated_user_field 5 DescriptorProto.ExtensionRange.serialize extension_range o') >>= fun () ->
      (W'.serialize_repeated_user_field 8 OneofDescriptorProto.serialize oneof_decl o') >>= fun () ->
      (W'.serialize_user_field 7 MessageOptions.serialize options o') >>= fun () ->
      (W'.serialize_repeated_user_field 9 DescriptorProto.ReservedRange.serialize reserved_range o') >>= fun () ->
      (W'.serialize_repeated_field 10 F'.String_t reserved_name o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      (W'.decode_repeated_user_field 2 FieldDescriptorProto.deserialize m') >>= fun field ->
      (W'.decode_repeated_user_field 6 FieldDescriptorProto.deserialize m') >>= fun extension ->
      (W'.decode_repeated_user_field 3 DescriptorProto.deserialize m') >>= fun nested_type ->
      (W'.decode_repeated_user_field 4 EnumDescriptorProto.deserialize m') >>= fun enum_type ->
      (W'.decode_repeated_user_field 5 DescriptorProto.ExtensionRange.deserialize m') >>= fun extension_range ->
      (W'.decode_repeated_user_field 8 OneofDescriptorProto.deserialize m') >>= fun oneof_decl ->
      (W'.decode_user_field 7 MessageOptions.deserialize m') >>= fun options ->
      (W'.decode_repeated_user_field 9 DescriptorProto.ReservedRange.deserialize m') >>= fun reserved_range ->
      W'.decode_repeated_field 10 F'.String_t m' >>= fun reserved_name ->
      Ok { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name }

  let rec stringify =
    fun { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_repeated_user_field "field" FieldDescriptorProto.stringify field o') >>= fun () ->
      (T'.serialize_repeated_user_field "extension" FieldDescriptorProto.stringify extension o') >>= fun () ->
      (T'.serialize_repeated_user_field "nested_type" DescriptorProto.stringify nested_type o') >>= fun () ->
      (T'.serialize_repeated_user_field "enum_type" EnumDescriptorProto.stringify enum_type o') >>= fun () ->
      (T'.serialize_repeated_user_field "extension_range" DescriptorProto.ExtensionRange.stringify extension_range o') >>= fun () ->
      (T'.serialize_repeated_user_field "oneof_decl" OneofDescriptorProto.stringify oneof_decl o') >>= fun () ->
      (T'.serialize_user_field "options" MessageOptions.stringify options o') >>= fun () ->
      (T'.serialize_repeated_user_field "reserved_range" DescriptorProto.ReservedRange.stringify reserved_range o') >>= fun () ->
      (T'.serialize_repeated_field "reserved_name" F'.String_t reserved_name o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      (T'.decode_repeated_user_field "field" FieldDescriptorProto.unstringify m') >>= fun field ->
      (T'.decode_repeated_user_field "extension" FieldDescriptorProto.unstringify m') >>= fun extension ->
      (T'.decode_repeated_user_field "nested_type" DescriptorProto.unstringify m') >>= fun nested_type ->
      (T'.decode_repeated_user_field "enum_type" EnumDescriptorProto.unstringify m') >>= fun enum_type ->
      (T'.decode_repeated_user_field "extension_range" DescriptorProto.ExtensionRange.unstringify m') >>= fun extension_range ->
      (T'.decode_repeated_user_field "oneof_decl" OneofDescriptorProto.unstringify m') >>= fun oneof_decl ->
      (T'.decode_user_field "options" MessageOptions.unstringify m') >>= fun options ->
      (T'.decode_repeated_user_field "reserved_range" DescriptorProto.ReservedRange.unstringify m') >>= fun reserved_range ->
      T'.decode_repeated_field "reserved_name" F'.String_t m' >>= fun reserved_name ->
      Ok { name; field; extension; nested_type; enum_type; extension_range; oneof_decl; options; reserved_range; reserved_name }
end

and FieldDescriptorProto : sig
  module Type : sig
    type t =
      | TYPE_DOUBLE
      | TYPE_FLOAT
      | TYPE_INT64
      | TYPE_UINT64
      | TYPE_INT32
      | TYPE_FIXED64
      | TYPE_FIXED32
      | TYPE_BOOL
      | TYPE_STRING
      | TYPE_GROUP
      | TYPE_MESSAGE
      | TYPE_BYTES
      | TYPE_UINT32
      | TYPE_ENUM
      | TYPE_SFIXED32
      | TYPE_SFIXED64
      | TYPE_SINT32
      | TYPE_SINT64
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end
  
  module Label : sig
    type t =
      | LABEL_OPTIONAL
      | LABEL_REQUIRED
      | LABEL_REPEATED
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    name : string;
    number : int;
    label : FieldDescriptorProto.Label.t;
    type' : FieldDescriptorProto.Type.t;
    type_name : string;
    extendee : string;
    default_value : string;
    oneof_index : int;
    json_name : string;
    options : FieldOptions.t option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module Type : sig
    type t =
      | TYPE_DOUBLE
      | TYPE_FLOAT
      | TYPE_INT64
      | TYPE_UINT64
      | TYPE_INT32
      | TYPE_FIXED64
      | TYPE_FIXED32
      | TYPE_BOOL
      | TYPE_STRING
      | TYPE_GROUP
      | TYPE_MESSAGE
      | TYPE_BYTES
      | TYPE_UINT32
      | TYPE_ENUM
      | TYPE_SFIXED32
      | TYPE_SFIXED64
      | TYPE_SINT32
      | TYPE_SINT64
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | TYPE_DOUBLE
      | TYPE_FLOAT
      | TYPE_INT64
      | TYPE_UINT64
      | TYPE_INT32
      | TYPE_FIXED64
      | TYPE_FIXED32
      | TYPE_BOOL
      | TYPE_STRING
      | TYPE_GROUP
      | TYPE_MESSAGE
      | TYPE_BYTES
      | TYPE_UINT32
      | TYPE_ENUM
      | TYPE_SFIXED32
      | TYPE_SFIXED64
      | TYPE_SINT32
      | TYPE_SINT64
  
    let default =
    fun () -> TYPE_DOUBLE
  
    let to_int =
      function
      | TYPE_DOUBLE -> 1
      | TYPE_FLOAT -> 2
      | TYPE_INT64 -> 3
      | TYPE_UINT64 -> 4
      | TYPE_INT32 -> 5
      | TYPE_FIXED64 -> 6
      | TYPE_FIXED32 -> 7
      | TYPE_BOOL -> 8
      | TYPE_STRING -> 9
      | TYPE_GROUP -> 10
      | TYPE_MESSAGE -> 11
      | TYPE_BYTES -> 12
      | TYPE_UINT32 -> 13
      | TYPE_ENUM -> 14
      | TYPE_SFIXED32 -> 15
      | TYPE_SFIXED64 -> 16
      | TYPE_SINT32 -> 17
      | TYPE_SINT64 -> 18
  
    let of_int =
      function
      | 1 -> Some TYPE_DOUBLE
      | 2 -> Some TYPE_FLOAT
      | 3 -> Some TYPE_INT64
      | 4 -> Some TYPE_UINT64
      | 5 -> Some TYPE_INT32
      | 6 -> Some TYPE_FIXED64
      | 7 -> Some TYPE_FIXED32
      | 8 -> Some TYPE_BOOL
      | 9 -> Some TYPE_STRING
      | 10 -> Some TYPE_GROUP
      | 11 -> Some TYPE_MESSAGE
      | 12 -> Some TYPE_BYTES
      | 13 -> Some TYPE_UINT32
      | 14 -> Some TYPE_ENUM
      | 15 -> Some TYPE_SFIXED32
      | 16 -> Some TYPE_SFIXED64
      | 17 -> Some TYPE_SINT32
      | 18 -> Some TYPE_SINT64
      | _ -> None
  
    let to_string =
      function
      | TYPE_DOUBLE -> "TYPE_DOUBLE"
      | TYPE_FLOAT -> "TYPE_FLOAT"
      | TYPE_INT64 -> "TYPE_INT64"
      | TYPE_UINT64 -> "TYPE_UINT64"
      | TYPE_INT32 -> "TYPE_INT32"
      | TYPE_FIXED64 -> "TYPE_FIXED64"
      | TYPE_FIXED32 -> "TYPE_FIXED32"
      | TYPE_BOOL -> "TYPE_BOOL"
      | TYPE_STRING -> "TYPE_STRING"
      | TYPE_GROUP -> "TYPE_GROUP"
      | TYPE_MESSAGE -> "TYPE_MESSAGE"
      | TYPE_BYTES -> "TYPE_BYTES"
      | TYPE_UINT32 -> "TYPE_UINT32"
      | TYPE_ENUM -> "TYPE_ENUM"
      | TYPE_SFIXED32 -> "TYPE_SFIXED32"
      | TYPE_SFIXED64 -> "TYPE_SFIXED64"
      | TYPE_SINT32 -> "TYPE_SINT32"
      | TYPE_SINT64 -> "TYPE_SINT64"
  
    let of_string =
      function
      | "TYPE_DOUBLE" -> Some TYPE_DOUBLE
      | "TYPE_FLOAT" -> Some TYPE_FLOAT
      | "TYPE_INT64" -> Some TYPE_INT64
      | "TYPE_UINT64" -> Some TYPE_UINT64
      | "TYPE_INT32" -> Some TYPE_INT32
      | "TYPE_FIXED64" -> Some TYPE_FIXED64
      | "TYPE_FIXED32" -> Some TYPE_FIXED32
      | "TYPE_BOOL" -> Some TYPE_BOOL
      | "TYPE_STRING" -> Some TYPE_STRING
      | "TYPE_GROUP" -> Some TYPE_GROUP
      | "TYPE_MESSAGE" -> Some TYPE_MESSAGE
      | "TYPE_BYTES" -> Some TYPE_BYTES
      | "TYPE_UINT32" -> Some TYPE_UINT32
      | "TYPE_ENUM" -> Some TYPE_ENUM
      | "TYPE_SFIXED32" -> Some TYPE_SFIXED32
      | "TYPE_SFIXED64" -> Some TYPE_SFIXED64
      | "TYPE_SINT32" -> Some TYPE_SINT32
      | "TYPE_SINT64" -> Some TYPE_SINT64
      | _ -> None
  end
  
  module Label : sig
    type t =
      | LABEL_OPTIONAL
      | LABEL_REQUIRED
      | LABEL_REPEATED
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | LABEL_OPTIONAL
      | LABEL_REQUIRED
      | LABEL_REPEATED
  
    let default =
    fun () -> LABEL_OPTIONAL
  
    let to_int =
      function
      | LABEL_OPTIONAL -> 1
      | LABEL_REQUIRED -> 2
      | LABEL_REPEATED -> 3
  
    let of_int =
      function
      | 1 -> Some LABEL_OPTIONAL
      | 2 -> Some LABEL_REQUIRED
      | 3 -> Some LABEL_REPEATED
      | _ -> None
  
    let to_string =
      function
      | LABEL_OPTIONAL -> "LABEL_OPTIONAL"
      | LABEL_REQUIRED -> "LABEL_REQUIRED"
      | LABEL_REPEATED -> "LABEL_REPEATED"
  
    let of_string =
      function
      | "LABEL_OPTIONAL" -> Some LABEL_OPTIONAL
      | "LABEL_REQUIRED" -> Some LABEL_REQUIRED
      | "LABEL_REPEATED" -> Some LABEL_REPEATED
      | _ -> None
  end

  type t = {
    name : string;
    number : int;
    label : FieldDescriptorProto.Label.t;
    type' : FieldDescriptorProto.Type.t;
    type_name : string;
    extendee : string;
    default_value : string;
    oneof_index : int;
    json_name : string;
    options : FieldOptions.t option;
  }

  let rec serialize =
    fun { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_field 3 F'.Int32_t number o') >>= fun () ->
      (W'.serialize_enum_field 4 FieldDescriptorProto.Label.to_int label o') >>= fun () ->
      (W'.serialize_enum_field 5 FieldDescriptorProto.Type.to_int type' o') >>= fun () ->
      (W'.serialize_field 6 F'.String_t type_name o') >>= fun () ->
      (W'.serialize_field 2 F'.String_t extendee o') >>= fun () ->
      (W'.serialize_field 7 F'.String_t default_value o') >>= fun () ->
      (W'.serialize_field 9 F'.Int32_t oneof_index o') >>= fun () ->
      (W'.serialize_field 10 F'.String_t json_name o') >>= fun () ->
      (W'.serialize_user_field 8 FieldOptions.serialize options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      W'.decode_field 3 F'.Int32_t m' >>= fun number ->
      (W'.decode_enum_field 4 FieldDescriptorProto.Label.of_int FieldDescriptorProto.Label.default m') >>= fun label ->
      (W'.decode_enum_field 5 FieldDescriptorProto.Type.of_int FieldDescriptorProto.Type.default m') >>= fun type' ->
      W'.decode_field 6 F'.String_t m' >>= fun type_name ->
      W'.decode_field 2 F'.String_t m' >>= fun extendee ->
      W'.decode_field 7 F'.String_t m' >>= fun default_value ->
      W'.decode_field 9 F'.Int32_t m' >>= fun oneof_index ->
      W'.decode_field 10 F'.String_t m' >>= fun json_name ->
      (W'.decode_user_field 8 FieldOptions.deserialize m') >>= fun options ->
      Ok { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options }

  let rec stringify =
    fun { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_field "number" F'.Int32_t number o') >>= fun () ->
      (T'.serialize_enum_field "label" FieldDescriptorProto.Label.to_string label o') >>= fun () ->
      (T'.serialize_enum_field "type'" FieldDescriptorProto.Type.to_string type' o') >>= fun () ->
      (T'.serialize_field "type_name" F'.String_t type_name o') >>= fun () ->
      (T'.serialize_field "extendee" F'.String_t extendee o') >>= fun () ->
      (T'.serialize_field "default_value" F'.String_t default_value o') >>= fun () ->
      (T'.serialize_field "oneof_index" F'.Int32_t oneof_index o') >>= fun () ->
      (T'.serialize_field "json_name" F'.String_t json_name o') >>= fun () ->
      (T'.serialize_user_field "options" FieldOptions.stringify options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      T'.decode_field "number" F'.Int32_t m' >>= fun number ->
      (T'.decode_enum_field "label" FieldDescriptorProto.Label.of_string FieldDescriptorProto.Label.default m') >>= fun label ->
      (T'.decode_enum_field "type'" FieldDescriptorProto.Type.of_string FieldDescriptorProto.Type.default m') >>= fun type' ->
      T'.decode_field "type_name" F'.String_t m' >>= fun type_name ->
      T'.decode_field "extendee" F'.String_t m' >>= fun extendee ->
      T'.decode_field "default_value" F'.String_t m' >>= fun default_value ->
      T'.decode_field "oneof_index" F'.Int32_t m' >>= fun oneof_index ->
      T'.decode_field "json_name" F'.String_t m' >>= fun json_name ->
      (T'.decode_user_field "options" FieldOptions.unstringify m') >>= fun options ->
      Ok { name; number; label; type'; type_name; extendee; default_value; oneof_index; json_name; options }
end

and OneofDescriptorProto : sig
  type t = {
    name : string;
    options : OneofOptions.t option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string;
    options : OneofOptions.t option;
  }

  let rec serialize =
    fun { name; options } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_user_field 2 OneofOptions.serialize options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      (W'.decode_user_field 2 OneofOptions.deserialize m') >>= fun options ->
      Ok { name; options }

  let rec stringify =
    fun { name; options } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_user_field "options" OneofOptions.stringify options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      (T'.decode_user_field "options" OneofOptions.unstringify m') >>= fun options ->
      Ok { name; options }
end

and EnumDescriptorProto : sig
  type t = {
    name : string;
    value' : EnumValueDescriptorProto.t list;
    options : EnumOptions.t option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string;
    value' : EnumValueDescriptorProto.t list;
    options : EnumOptions.t option;
  }

  let rec serialize =
    fun { name; value'; options } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_repeated_user_field 2 EnumValueDescriptorProto.serialize value' o') >>= fun () ->
      (W'.serialize_user_field 3 EnumOptions.serialize options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      (W'.decode_repeated_user_field 2 EnumValueDescriptorProto.deserialize m') >>= fun value' ->
      (W'.decode_user_field 3 EnumOptions.deserialize m') >>= fun options ->
      Ok { name; value'; options }

  let rec stringify =
    fun { name; value'; options } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_repeated_user_field "value'" EnumValueDescriptorProto.stringify value' o') >>= fun () ->
      (T'.serialize_user_field "options" EnumOptions.stringify options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      (T'.decode_repeated_user_field "value'" EnumValueDescriptorProto.unstringify m') >>= fun value' ->
      (T'.decode_user_field "options" EnumOptions.unstringify m') >>= fun options ->
      Ok { name; value'; options }
end

and EnumValueDescriptorProto : sig
  type t = {
    name : string;
    number : int;
    options : EnumValueOptions.t option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string;
    number : int;
    options : EnumValueOptions.t option;
  }

  let rec serialize =
    fun { name; number; options } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_field 2 F'.Int32_t number o') >>= fun () ->
      (W'.serialize_user_field 3 EnumValueOptions.serialize options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      W'.decode_field 2 F'.Int32_t m' >>= fun number ->
      (W'.decode_user_field 3 EnumValueOptions.deserialize m') >>= fun options ->
      Ok { name; number; options }

  let rec stringify =
    fun { name; number; options } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_field "number" F'.Int32_t number o') >>= fun () ->
      (T'.serialize_user_field "options" EnumValueOptions.stringify options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      T'.decode_field "number" F'.Int32_t m' >>= fun number ->
      (T'.decode_user_field "options" EnumValueOptions.unstringify m') >>= fun options ->
      Ok { name; number; options }
end

and ServiceDescriptorProto : sig
  type t = {
    name : string;
    method' : MethodDescriptorProto.t list;
    options : ServiceOptions.t option;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string;
    method' : MethodDescriptorProto.t list;
    options : ServiceOptions.t option;
  }

  let rec serialize =
    fun { name; method'; options } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_repeated_user_field 2 MethodDescriptorProto.serialize method' o') >>= fun () ->
      (W'.serialize_user_field 3 ServiceOptions.serialize options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      (W'.decode_repeated_user_field 2 MethodDescriptorProto.deserialize m') >>= fun method' ->
      (W'.decode_user_field 3 ServiceOptions.deserialize m') >>= fun options ->
      Ok { name; method'; options }

  let rec stringify =
    fun { name; method'; options } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_repeated_user_field "method'" MethodDescriptorProto.stringify method' o') >>= fun () ->
      (T'.serialize_user_field "options" ServiceOptions.stringify options o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      (T'.decode_repeated_user_field "method'" MethodDescriptorProto.unstringify m') >>= fun method' ->
      (T'.decode_user_field "options" ServiceOptions.unstringify m') >>= fun options ->
      Ok { name; method'; options }
end

and MethodDescriptorProto : sig
  type t = {
    name : string;
    input_type : string;
    output_type : string;
    options : MethodOptions.t option;
    client_streaming : bool;
    server_streaming : bool;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    name : string;
    input_type : string;
    output_type : string;
    options : MethodOptions.t option;
    client_streaming : bool;
    server_streaming : bool;
  }

  let rec serialize =
    fun { name; input_type; output_type; options; client_streaming; server_streaming } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t name o') >>= fun () ->
      (W'.serialize_field 2 F'.String_t input_type o') >>= fun () ->
      (W'.serialize_field 3 F'.String_t output_type o') >>= fun () ->
      (W'.serialize_user_field 4 MethodOptions.serialize options o') >>= fun () ->
      (W'.serialize_field 5 F'.Bool_t client_streaming o') >>= fun () ->
      (W'.serialize_field 6 F'.Bool_t server_streaming o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun name ->
      W'.decode_field 2 F'.String_t m' >>= fun input_type ->
      W'.decode_field 3 F'.String_t m' >>= fun output_type ->
      (W'.decode_user_field 4 MethodOptions.deserialize m') >>= fun options ->
      W'.decode_field 5 F'.Bool_t m' >>= fun client_streaming ->
      W'.decode_field 6 F'.Bool_t m' >>= fun server_streaming ->
      Ok { name; input_type; output_type; options; client_streaming; server_streaming }

  let rec stringify =
    fun { name; input_type; output_type; options; client_streaming; server_streaming } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "name" F'.String_t name o') >>= fun () ->
      (T'.serialize_field "input_type" F'.String_t input_type o') >>= fun () ->
      (T'.serialize_field "output_type" F'.String_t output_type o') >>= fun () ->
      (T'.serialize_user_field "options" MethodOptions.stringify options o') >>= fun () ->
      (T'.serialize_field "client_streaming" F'.Bool_t client_streaming o') >>= fun () ->
      (T'.serialize_field "server_streaming" F'.Bool_t server_streaming o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "name" F'.String_t m' >>= fun name ->
      T'.decode_field "input_type" F'.String_t m' >>= fun input_type ->
      T'.decode_field "output_type" F'.String_t m' >>= fun output_type ->
      (T'.decode_user_field "options" MethodOptions.unstringify m') >>= fun options ->
      T'.decode_field "client_streaming" F'.Bool_t m' >>= fun client_streaming ->
      T'.decode_field "server_streaming" F'.Bool_t m' >>= fun server_streaming ->
      Ok { name; input_type; output_type; options; client_streaming; server_streaming }
end

and FileOptions : sig
  module OptimizeMode : sig
    type t =
      | SPEED
      | CODE_SIZE
      | LITE_RUNTIME
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    java_package : string;
    java_outer_classname : string;
    java_multiple_files : bool;
    java_generate_equals_and_hash : bool;
    java_string_check_utf8 : bool;
    optimize_for : FileOptions.OptimizeMode.t;
    go_package : string;
    cc_generic_services : bool;
    java_generic_services : bool;
    py_generic_services : bool;
    deprecated : bool;
    cc_enable_arenas : bool;
    objc_class_prefix : string;
    csharp_namespace : string;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module OptimizeMode : sig
    type t =
      | SPEED
      | CODE_SIZE
      | LITE_RUNTIME
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | SPEED
      | CODE_SIZE
      | LITE_RUNTIME
  
    let default =
    fun () -> SPEED
  
    let to_int =
      function
      | SPEED -> 1
      | CODE_SIZE -> 2
      | LITE_RUNTIME -> 3
  
    let of_int =
      function
      | 1 -> Some SPEED
      | 2 -> Some CODE_SIZE
      | 3 -> Some LITE_RUNTIME
      | _ -> None
  
    let to_string =
      function
      | SPEED -> "SPEED"
      | CODE_SIZE -> "CODE_SIZE"
      | LITE_RUNTIME -> "LITE_RUNTIME"
  
    let of_string =
      function
      | "SPEED" -> Some SPEED
      | "CODE_SIZE" -> Some CODE_SIZE
      | "LITE_RUNTIME" -> Some LITE_RUNTIME
      | _ -> None
  end

  type t = {
    java_package : string;
    java_outer_classname : string;
    java_multiple_files : bool;
    java_generate_equals_and_hash : bool;
    java_string_check_utf8 : bool;
    optimize_for : FileOptions.OptimizeMode.t;
    go_package : string;
    cc_generic_services : bool;
    java_generic_services : bool;
    py_generic_services : bool;
    deprecated : bool;
    cc_enable_arenas : bool;
    objc_class_prefix : string;
    csharp_namespace : string;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.String_t java_package o') >>= fun () ->
      (W'.serialize_field 8 F'.String_t java_outer_classname o') >>= fun () ->
      (W'.serialize_field 10 F'.Bool_t java_multiple_files o') >>= fun () ->
      (W'.serialize_field 20 F'.Bool_t java_generate_equals_and_hash o') >>= fun () ->
      (W'.serialize_field 27 F'.Bool_t java_string_check_utf8 o') >>= fun () ->
      (W'.serialize_enum_field 9 FileOptions.OptimizeMode.to_int optimize_for o') >>= fun () ->
      (W'.serialize_field 11 F'.String_t go_package o') >>= fun () ->
      (W'.serialize_field 16 F'.Bool_t cc_generic_services o') >>= fun () ->
      (W'.serialize_field 17 F'.Bool_t java_generic_services o') >>= fun () ->
      (W'.serialize_field 18 F'.Bool_t py_generic_services o') >>= fun () ->
      (W'.serialize_field 23 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_field 31 F'.Bool_t cc_enable_arenas o') >>= fun () ->
      (W'.serialize_field 36 F'.String_t objc_class_prefix o') >>= fun () ->
      (W'.serialize_field 37 F'.String_t csharp_namespace o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.String_t m' >>= fun java_package ->
      W'.decode_field 8 F'.String_t m' >>= fun java_outer_classname ->
      W'.decode_field 10 F'.Bool_t m' >>= fun java_multiple_files ->
      W'.decode_field 20 F'.Bool_t m' >>= fun java_generate_equals_and_hash ->
      W'.decode_field 27 F'.Bool_t m' >>= fun java_string_check_utf8 ->
      (W'.decode_enum_field 9 FileOptions.OptimizeMode.of_int FileOptions.OptimizeMode.default m') >>= fun optimize_for ->
      W'.decode_field 11 F'.String_t m' >>= fun go_package ->
      W'.decode_field 16 F'.Bool_t m' >>= fun cc_generic_services ->
      W'.decode_field 17 F'.Bool_t m' >>= fun java_generic_services ->
      W'.decode_field 18 F'.Bool_t m' >>= fun py_generic_services ->
      W'.decode_field 23 F'.Bool_t m' >>= fun deprecated ->
      W'.decode_field 31 F'.Bool_t m' >>= fun cc_enable_arenas ->
      W'.decode_field 36 F'.String_t m' >>= fun objc_class_prefix ->
      W'.decode_field 37 F'.String_t m' >>= fun csharp_namespace ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; uninterpreted_option }

  let rec stringify =
    fun { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "java_package" F'.String_t java_package o') >>= fun () ->
      (T'.serialize_field "java_outer_classname" F'.String_t java_outer_classname o') >>= fun () ->
      (T'.serialize_field "java_multiple_files" F'.Bool_t java_multiple_files o') >>= fun () ->
      (T'.serialize_field "java_generate_equals_and_hash" F'.Bool_t java_generate_equals_and_hash o') >>= fun () ->
      (T'.serialize_field "java_string_check_utf8" F'.Bool_t java_string_check_utf8 o') >>= fun () ->
      (T'.serialize_enum_field "optimize_for" FileOptions.OptimizeMode.to_string optimize_for o') >>= fun () ->
      (T'.serialize_field "go_package" F'.String_t go_package o') >>= fun () ->
      (T'.serialize_field "cc_generic_services" F'.Bool_t cc_generic_services o') >>= fun () ->
      (T'.serialize_field "java_generic_services" F'.Bool_t java_generic_services o') >>= fun () ->
      (T'.serialize_field "py_generic_services" F'.Bool_t py_generic_services o') >>= fun () ->
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_field "cc_enable_arenas" F'.Bool_t cc_enable_arenas o') >>= fun () ->
      (T'.serialize_field "objc_class_prefix" F'.String_t objc_class_prefix o') >>= fun () ->
      (T'.serialize_field "csharp_namespace" F'.String_t csharp_namespace o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "java_package" F'.String_t m' >>= fun java_package ->
      T'.decode_field "java_outer_classname" F'.String_t m' >>= fun java_outer_classname ->
      T'.decode_field "java_multiple_files" F'.Bool_t m' >>= fun java_multiple_files ->
      T'.decode_field "java_generate_equals_and_hash" F'.Bool_t m' >>= fun java_generate_equals_and_hash ->
      T'.decode_field "java_string_check_utf8" F'.Bool_t m' >>= fun java_string_check_utf8 ->
      (T'.decode_enum_field "optimize_for" FileOptions.OptimizeMode.of_string FileOptions.OptimizeMode.default m') >>= fun optimize_for ->
      T'.decode_field "go_package" F'.String_t m' >>= fun go_package ->
      T'.decode_field "cc_generic_services" F'.Bool_t m' >>= fun cc_generic_services ->
      T'.decode_field "java_generic_services" F'.Bool_t m' >>= fun java_generic_services ->
      T'.decode_field "py_generic_services" F'.Bool_t m' >>= fun py_generic_services ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_field "cc_enable_arenas" F'.Bool_t m' >>= fun cc_enable_arenas ->
      T'.decode_field "objc_class_prefix" F'.String_t m' >>= fun objc_class_prefix ->
      T'.decode_field "csharp_namespace" F'.String_t m' >>= fun csharp_namespace ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { java_package; java_outer_classname; java_multiple_files; java_generate_equals_and_hash; java_string_check_utf8; optimize_for; go_package; cc_generic_services; java_generic_services; py_generic_services; deprecated; cc_enable_arenas; objc_class_prefix; csharp_namespace; uninterpreted_option }
end

and MessageOptions : sig
  type t = {
    message_set_wire_format : bool;
    no_standard_descriptor_accessor : bool;
    deprecated : bool;
    map_entry : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    message_set_wire_format : bool;
    no_standard_descriptor_accessor : bool;
    deprecated : bool;
    map_entry : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.Bool_t message_set_wire_format o') >>= fun () ->
      (W'.serialize_field 2 F'.Bool_t no_standard_descriptor_accessor o') >>= fun () ->
      (W'.serialize_field 3 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_field 7 F'.Bool_t map_entry o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.Bool_t m' >>= fun message_set_wire_format ->
      W'.decode_field 2 F'.Bool_t m' >>= fun no_standard_descriptor_accessor ->
      W'.decode_field 3 F'.Bool_t m' >>= fun deprecated ->
      W'.decode_field 7 F'.Bool_t m' >>= fun map_entry ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option }

  let rec stringify =
    fun { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "message_set_wire_format" F'.Bool_t message_set_wire_format o') >>= fun () ->
      (T'.serialize_field "no_standard_descriptor_accessor" F'.Bool_t no_standard_descriptor_accessor o') >>= fun () ->
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_field "map_entry" F'.Bool_t map_entry o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "message_set_wire_format" F'.Bool_t m' >>= fun message_set_wire_format ->
      T'.decode_field "no_standard_descriptor_accessor" F'.Bool_t m' >>= fun no_standard_descriptor_accessor ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_field "map_entry" F'.Bool_t m' >>= fun map_entry ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { message_set_wire_format; no_standard_descriptor_accessor; deprecated; map_entry; uninterpreted_option }
end

and FieldOptions : sig
  module CType : sig
    type t =
      | STRING
      | CORD
      | STRING_PIECE
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end
  
  module JSType : sig
    type t =
      | JS_NORMAL
      | JS_STRING
      | JS_NUMBER
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end

  type t = {
    ctype : FieldOptions.CType.t;
    packed : bool;
    jstype : FieldOptions.JSType.t;
    lazy' : bool;
    deprecated : bool;
    weak : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module CType : sig
    type t =
      | STRING
      | CORD
      | STRING_PIECE
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | STRING
      | CORD
      | STRING_PIECE
  
    let default =
    fun () -> STRING
  
    let to_int =
      function
      | STRING -> 0
      | CORD -> 1
      | STRING_PIECE -> 2
  
    let of_int =
      function
      | 0 -> Some STRING
      | 1 -> Some CORD
      | 2 -> Some STRING_PIECE
      | _ -> None
  
    let to_string =
      function
      | STRING -> "STRING"
      | CORD -> "CORD"
      | STRING_PIECE -> "STRING_PIECE"
  
    let of_string =
      function
      | "STRING" -> Some STRING
      | "CORD" -> Some CORD
      | "STRING_PIECE" -> Some STRING_PIECE
      | _ -> None
  end
  
  module JSType : sig
    type t =
      | JS_NORMAL
      | JS_STRING
      | JS_NUMBER
  
    val default : unit -> t
  
    val to_int : t -> int
  
    val of_int : int -> t option
  
    val to_string : t -> string
  
    val of_string : string -> t option
  end = struct
    type t =
      | JS_NORMAL
      | JS_STRING
      | JS_NUMBER
  
    let default =
    fun () -> JS_NORMAL
  
    let to_int =
      function
      | JS_NORMAL -> 0
      | JS_STRING -> 1
      | JS_NUMBER -> 2
  
    let of_int =
      function
      | 0 -> Some JS_NORMAL
      | 1 -> Some JS_STRING
      | 2 -> Some JS_NUMBER
      | _ -> None
  
    let to_string =
      function
      | JS_NORMAL -> "JS_NORMAL"
      | JS_STRING -> "JS_STRING"
      | JS_NUMBER -> "JS_NUMBER"
  
    let of_string =
      function
      | "JS_NORMAL" -> Some JS_NORMAL
      | "JS_STRING" -> Some JS_STRING
      | "JS_NUMBER" -> Some JS_NUMBER
      | _ -> None
  end

  type t = {
    ctype : FieldOptions.CType.t;
    packed : bool;
    jstype : FieldOptions.JSType.t;
    lazy' : bool;
    deprecated : bool;
    weak : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_enum_field 1 FieldOptions.CType.to_int ctype o') >>= fun () ->
      (W'.serialize_field 2 F'.Bool_t packed o') >>= fun () ->
      (W'.serialize_enum_field 6 FieldOptions.JSType.to_int jstype o') >>= fun () ->
      (W'.serialize_field 5 F'.Bool_t lazy' o') >>= fun () ->
      (W'.serialize_field 3 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_field 10 F'.Bool_t weak o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      (W'.decode_enum_field 1 FieldOptions.CType.of_int FieldOptions.CType.default m') >>= fun ctype ->
      W'.decode_field 2 F'.Bool_t m' >>= fun packed ->
      (W'.decode_enum_field 6 FieldOptions.JSType.of_int FieldOptions.JSType.default m') >>= fun jstype ->
      W'.decode_field 5 F'.Bool_t m' >>= fun lazy' ->
      W'.decode_field 3 F'.Bool_t m' >>= fun deprecated ->
      W'.decode_field 10 F'.Bool_t m' >>= fun weak ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option }

  let rec stringify =
    fun { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_enum_field "ctype" FieldOptions.CType.to_string ctype o') >>= fun () ->
      (T'.serialize_field "packed" F'.Bool_t packed o') >>= fun () ->
      (T'.serialize_enum_field "jstype" FieldOptions.JSType.to_string jstype o') >>= fun () ->
      (T'.serialize_field "lazy'" F'.Bool_t lazy' o') >>= fun () ->
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_field "weak" F'.Bool_t weak o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      (T'.decode_enum_field "ctype" FieldOptions.CType.of_string FieldOptions.CType.default m') >>= fun ctype ->
      T'.decode_field "packed" F'.Bool_t m' >>= fun packed ->
      (T'.decode_enum_field "jstype" FieldOptions.JSType.of_string FieldOptions.JSType.default m') >>= fun jstype ->
      T'.decode_field "lazy'" F'.Bool_t m' >>= fun lazy' ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      T'.decode_field "weak" F'.Bool_t m' >>= fun weak ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { ctype; packed; jstype; lazy'; deprecated; weak; uninterpreted_option }
end

and OneofOptions : sig
  type t = {
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { uninterpreted_option }

  let rec stringify =
    fun { uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { uninterpreted_option }
end

and EnumOptions : sig
  type t = {
    allow_alias : bool;
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    allow_alias : bool;
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { allow_alias; deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 2 F'.Bool_t allow_alias o') >>= fun () ->
      (W'.serialize_field 3 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 2 F'.Bool_t m' >>= fun allow_alias ->
      W'.decode_field 3 F'.Bool_t m' >>= fun deprecated ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { allow_alias; deprecated; uninterpreted_option }

  let rec stringify =
    fun { allow_alias; deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "allow_alias" F'.Bool_t allow_alias o') >>= fun () ->
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "allow_alias" F'.Bool_t m' >>= fun allow_alias ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { allow_alias; deprecated; uninterpreted_option }
end

and EnumValueOptions : sig
  type t = {
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 1 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 1 F'.Bool_t m' >>= fun deprecated ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }

  let rec stringify =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }
end

and ServiceOptions : sig
  type t = {
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 33 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 33 F'.Bool_t m' >>= fun deprecated ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }

  let rec stringify =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }
end

and MethodOptions : sig
  type t = {
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  type t = {
    deprecated : bool;
    uninterpreted_option : UninterpretedOption.t list;
  }

  let rec serialize =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_field 33 F'.Bool_t deprecated o') >>= fun () ->
      (W'.serialize_repeated_user_field 999 UninterpretedOption.serialize uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      W'.decode_field 33 F'.Bool_t m' >>= fun deprecated ->
      (W'.decode_repeated_user_field 999 UninterpretedOption.deserialize m') >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }

  let rec stringify =
    fun { deprecated; uninterpreted_option } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_field "deprecated" F'.Bool_t deprecated o') >>= fun () ->
      (T'.serialize_repeated_user_field "uninterpreted_option" UninterpretedOption.stringify uninterpreted_option o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      T'.decode_field "deprecated" F'.Bool_t m' >>= fun deprecated ->
      (T'.decode_repeated_user_field "uninterpreted_option" UninterpretedOption.unstringify m') >>= fun uninterpreted_option ->
      Ok { deprecated; uninterpreted_option }
end

and UninterpretedOption : sig
  module rec NamePart : sig
    type t = {
      name_part : string;
      is_extension : bool;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    name : UninterpretedOption.NamePart.t list;
    identifier_value : string;
    positive_int_value : int;
    negative_int_value : int;
    double_value : float;
    string_value : string;
    aggregate_value : string;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec NamePart : sig
    type t = {
      name_part : string;
      is_extension : bool;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      name_part : string;
      is_extension : bool;
    }
  
    let rec serialize =
      fun { name_part; is_extension } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_field 1 F'.String_t name_part o') >>= fun () ->
        (W'.serialize_field 2 F'.Bool_t is_extension o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_field 1 F'.String_t m' >>= fun name_part ->
        W'.decode_field 2 F'.Bool_t m' >>= fun is_extension ->
        Ok { name_part; is_extension }
  
    let rec stringify =
      fun { name_part; is_extension } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_field "name_part" F'.String_t name_part o') >>= fun () ->
        (T'.serialize_field "is_extension" F'.Bool_t is_extension o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_field "name_part" F'.String_t m' >>= fun name_part ->
        T'.decode_field "is_extension" F'.Bool_t m' >>= fun is_extension ->
        Ok { name_part; is_extension }
  end

  type t = {
    name : UninterpretedOption.NamePart.t list;
    identifier_value : string;
    positive_int_value : int;
    negative_int_value : int;
    double_value : float;
    string_value : string;
    aggregate_value : string;
  }

  let rec serialize =
    fun { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_user_field 2 UninterpretedOption.NamePart.serialize name o') >>= fun () ->
      (W'.serialize_field 3 F'.String_t identifier_value o') >>= fun () ->
      (W'.serialize_field 4 F'.Uint64_t positive_int_value o') >>= fun () ->
      (W'.serialize_field 5 F'.Int64_t negative_int_value o') >>= fun () ->
      (W'.serialize_field 6 F'.Double_t double_value o') >>= fun () ->
      (W'.serialize_field 7 F'.Bytes_t string_value o') >>= fun () ->
      (W'.serialize_field 8 F'.String_t aggregate_value o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      (W'.decode_repeated_user_field 2 UninterpretedOption.NamePart.deserialize m') >>= fun name ->
      W'.decode_field 3 F'.String_t m' >>= fun identifier_value ->
      W'.decode_field 4 F'.Uint64_t m' >>= fun positive_int_value ->
      W'.decode_field 5 F'.Int64_t m' >>= fun negative_int_value ->
      W'.decode_field 6 F'.Double_t m' >>= fun double_value ->
      W'.decode_field 7 F'.Bytes_t m' >>= fun string_value ->
      W'.decode_field 8 F'.String_t m' >>= fun aggregate_value ->
      Ok { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value }

  let rec stringify =
    fun { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_user_field "name" UninterpretedOption.NamePart.stringify name o') >>= fun () ->
      (T'.serialize_field "identifier_value" F'.String_t identifier_value o') >>= fun () ->
      (T'.serialize_field "positive_int_value" F'.Uint64_t positive_int_value o') >>= fun () ->
      (T'.serialize_field "negative_int_value" F'.Int64_t negative_int_value o') >>= fun () ->
      (T'.serialize_field "double_value" F'.Double_t double_value o') >>= fun () ->
      (T'.serialize_field "string_value" F'.Bytes_t string_value o') >>= fun () ->
      (T'.serialize_field "aggregate_value" F'.String_t aggregate_value o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      (T'.decode_repeated_user_field "name" UninterpretedOption.NamePart.unstringify m') >>= fun name ->
      T'.decode_field "identifier_value" F'.String_t m' >>= fun identifier_value ->
      T'.decode_field "positive_int_value" F'.Uint64_t m' >>= fun positive_int_value ->
      T'.decode_field "negative_int_value" F'.Int64_t m' >>= fun negative_int_value ->
      T'.decode_field "double_value" F'.Double_t m' >>= fun double_value ->
      T'.decode_field "string_value" F'.Bytes_t m' >>= fun string_value ->
      T'.decode_field "aggregate_value" F'.String_t m' >>= fun aggregate_value ->
      Ok { name; identifier_value; positive_int_value; negative_int_value; double_value; string_value; aggregate_value }
end

and SourceCodeInfo : sig
  module rec Location : sig
    type t = {
      path : int list;
      span : int list;
      leading_comments : string;
      trailing_comments : string;
      leading_detached_comments : string list;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    location : SourceCodeInfo.Location.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Location : sig
    type t = {
      path : int list;
      span : int list;
      leading_comments : string;
      trailing_comments : string;
      leading_detached_comments : string list;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      path : int list;
      span : int list;
      leading_comments : string;
      trailing_comments : string;
      leading_detached_comments : string list;
    }
  
    let rec serialize =
      fun { path; span; leading_comments; trailing_comments; leading_detached_comments } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_repeated_field 1 F'.Int32_t path o') >>= fun () ->
        (W'.serialize_repeated_field 2 F'.Int32_t span o') >>= fun () ->
        (W'.serialize_field 3 F'.String_t leading_comments o') >>= fun () ->
        (W'.serialize_field 4 F'.String_t trailing_comments o') >>= fun () ->
        (W'.serialize_repeated_field 6 F'.String_t leading_detached_comments o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_repeated_field 1 F'.Int32_t m' >>= fun path ->
        W'.decode_repeated_field 2 F'.Int32_t m' >>= fun span ->
        W'.decode_field 3 F'.String_t m' >>= fun leading_comments ->
        W'.decode_field 4 F'.String_t m' >>= fun trailing_comments ->
        W'.decode_repeated_field 6 F'.String_t m' >>= fun leading_detached_comments ->
        Ok { path; span; leading_comments; trailing_comments; leading_detached_comments }
  
    let rec stringify =
      fun { path; span; leading_comments; trailing_comments; leading_detached_comments } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_repeated_field "path" F'.Int32_t path o') >>= fun () ->
        (T'.serialize_repeated_field "span" F'.Int32_t span o') >>= fun () ->
        (T'.serialize_field "leading_comments" F'.String_t leading_comments o') >>= fun () ->
        (T'.serialize_field "trailing_comments" F'.String_t trailing_comments o') >>= fun () ->
        (T'.serialize_repeated_field "leading_detached_comments" F'.String_t leading_detached_comments o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_repeated_field "path" F'.Int32_t m' >>= fun path ->
        T'.decode_repeated_field "span" F'.Int32_t m' >>= fun span ->
        T'.decode_field "leading_comments" F'.String_t m' >>= fun leading_comments ->
        T'.decode_field "trailing_comments" F'.String_t m' >>= fun trailing_comments ->
        T'.decode_repeated_field "leading_detached_comments" F'.String_t m' >>= fun leading_detached_comments ->
        Ok { path; span; leading_comments; trailing_comments; leading_detached_comments }
  end

  type t = {
    location : SourceCodeInfo.Location.t list;
  }

  let rec serialize =
    fun { location } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_user_field 1 SourceCodeInfo.Location.serialize location o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      (W'.decode_repeated_user_field 1 SourceCodeInfo.Location.deserialize m') >>= fun location ->
      Ok { location }

  let rec stringify =
    fun { location } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_user_field "location" SourceCodeInfo.Location.stringify location o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      (T'.decode_repeated_user_field "location" SourceCodeInfo.Location.unstringify m') >>= fun location ->
      Ok { location }
end

and GeneratedCodeInfo : sig
  module rec Annotation : sig
    type t = {
      path : int list;
      source_file : string;
      begin' : int;
      end' : int;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end

  type t = {
    annotation : GeneratedCodeInfo.Annotation.t list;
  }

  val serialize : t -> (string, [> W'.serialization_error]) result

  val deserialize : string -> (t, [> W'.deserialization_error]) result

  val stringify : t -> (string, [> T'.serialization_error]) result

  val unstringify : string -> (t, [> T'.deserialization_error]) result
end = struct
  module rec Annotation : sig
    type t = {
      path : int list;
      source_file : string;
      begin' : int;
      end' : int;
    }
  
    val serialize : t -> (string, [> W'.serialization_error]) result
  
    val deserialize : string -> (t, [> W'.deserialization_error]) result
  
    val stringify : t -> (string, [> T'.serialization_error]) result
  
    val unstringify : string -> (t, [> T'.deserialization_error]) result
  end = struct
    type t = {
      path : int list;
      source_file : string;
      begin' : int;
      end' : int;
    }
  
    let rec serialize =
      fun { path; source_file; begin'; end' } ->
        let o' = Runtime.Byte_output.create () in
        (W'.serialize_repeated_field 1 F'.Int32_t path o') >>= fun () ->
        (W'.serialize_field 2 F'.String_t source_file o') >>= fun () ->
        (W'.serialize_field 3 F'.Int32_t begin' o') >>= fun () ->
        (W'.serialize_field 4 F'.Int32_t end' o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec deserialize =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        W'.deserialize_message >>= fun m' ->
        W'.decode_repeated_field 1 F'.Int32_t m' >>= fun path ->
        W'.decode_field 2 F'.String_t m' >>= fun source_file ->
        W'.decode_field 3 F'.Int32_t m' >>= fun begin' ->
        W'.decode_field 4 F'.Int32_t m' >>= fun end' ->
        Ok { path; source_file; begin'; end' }
  
    let rec stringify =
      fun { path; source_file; begin'; end' } ->
        let o' = Runtime.Byte_output.create () in
        (T'.serialize_repeated_field "path" F'.Int32_t path o') >>= fun () ->
        (T'.serialize_field "source_file" F'.String_t source_file o') >>= fun () ->
        (T'.serialize_field "begin'" F'.Int32_t begin' o') >>= fun () ->
        (T'.serialize_field "end'" F'.Int32_t end' o') >>= fun () ->
        Ok (Runtime.Byte_output.contents o')
  
    let rec unstringify =
      fun input' ->
        Ok (Runtime.Byte_input.create input') >>=
        T'.deserialize_message >>= fun m' ->
        T'.decode_repeated_field "path" F'.Int32_t m' >>= fun path ->
        T'.decode_field "source_file" F'.String_t m' >>= fun source_file ->
        T'.decode_field "begin'" F'.Int32_t m' >>= fun begin' ->
        T'.decode_field "end'" F'.Int32_t m' >>= fun end' ->
        Ok { path; source_file; begin'; end' }
  end

  type t = {
    annotation : GeneratedCodeInfo.Annotation.t list;
  }

  let rec serialize =
    fun { annotation } ->
      let o' = Runtime.Byte_output.create () in
      (W'.serialize_repeated_user_field 1 GeneratedCodeInfo.Annotation.serialize annotation o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec deserialize =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      W'.deserialize_message >>= fun m' ->
      (W'.decode_repeated_user_field 1 GeneratedCodeInfo.Annotation.deserialize m') >>= fun annotation ->
      Ok { annotation }

  let rec stringify =
    fun { annotation } ->
      let o' = Runtime.Byte_output.create () in
      (T'.serialize_repeated_user_field "annotation" GeneratedCodeInfo.Annotation.stringify annotation o') >>= fun () ->
      Ok (Runtime.Byte_output.contents o')

  let rec unstringify =
    fun input' ->
      Ok (Runtime.Byte_input.create input') >>=
      T'.deserialize_message >>= fun m' ->
      (T'.decode_repeated_user_field "annotation" GeneratedCodeInfo.Annotation.unstringify m') >>= fun annotation ->
      Ok { annotation }
end