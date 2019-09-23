open Base

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

module Oneof = struct
  type t = {name : string}
end

module Field = struct
  type t = {
    name : string;
    number : int;
    data_type : field_data_type;
    repeated : bool;
    oneof_index : int option;
  }

  type group =
    | Single of t
    | Oneof of {
        name : string;
        fields : t list;
      }

  let determine_groups fields oneofs =
    let oneofs = List.to_array oneofs in
    let index_to_fields =
      List.filter_map fields ~f:(fun ({oneof_index; _} as field) ->
          Option.map oneof_index ~f:(fun index -> index, field))
      |> Hashtbl.of_alist_multi (module Int)
    in
    let _, groups =
      List.fold_right
        fields
        ~init:([], [])
        ~f:(fun ({oneof_index; _} as field) (visited, acc) ->
          match oneof_index with
          | None -> visited, Single field :: acc
          | Some index -> (
            match List.mem visited index ~equal:Int.equal with
            | true -> visited, acc
            | false ->
                let group =
                  Oneof
                    {
                      name = oneofs.(index).Oneof.name;
                      fields = Hashtbl.find_exn index_to_fields index |> List.rev;
                    }
                in
                index :: visited, group :: acc))
    in
    groups
end

module Message = struct
  type t = {
    name : string;
    enums : Enum.t list;
    messages : t list;
    fields : Field.t list;
    field_groups : Field.group list;
  }
end

module File = struct
  type context = (string, string) List.Assoc.t

  type t = {
    name : string;
    package : string option;
    enums : Enum.t list;
    messages : Message.t list;
    context : context;
    dependencies : string list;
    syntax : string;
  }
end

type t = {files : File.t list}
