type field_data_type =
  | Int32
  | String

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
    fields : Field.t list;
  }
end

module File = struct
  type t = {
    name : string;
    messages : Message.t list;
  }
end

type t = {files : File.t list}
