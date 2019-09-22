type field_data_type =
  | String_t
  | Bytes_t
  | Int32_t
  | Int64_t
  | Sint32_t
  | Sint64_t
  | Uint32_t
  | Uint64_t
  | Fixed32_t
  | Fixed64_t
  | Sfixed32_t
  | Sfixed64_t
  | Float_t
  | Double_t
  | Bool_t
  | Message_t of string
  | Enum_t of string

module Enum = struct
  type t = {
    name : string;
    values : (string * int) list;
  }
end

module Field = struct
  type t = {
    name : string;
    number : int;
    data_type : field_data_type;
  }
end

module Message = struct
  type t = {
    name : string;
    enums : Enum.t list;
    messages : t list;
    fields : Field.t list;
  }
end

module File = struct
  type t = {
    name : string;
    package : string option;
    enums : Enum.t list;
    messages : Message.t list;
  }
end

type t = {files : File.t list}
