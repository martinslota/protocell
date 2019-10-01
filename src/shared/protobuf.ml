open Base

let reserved_words =
  let ocaml_keywords =
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
  in
  let output_format_words format =
    let names = Generated_code.names_of_output_format format in
    [names.serialize; names.deserialize]
  in
  List.concat [ocaml_keywords; output_format_words Binary; output_format_words Text]
  |> Hash_set.of_list (module String)

let is_lowercase_letter character = Char.between character ~low:'a' ~high:'z'

let is_uppercase_letter character = Char.between character ~low:'A' ~high:'Z'

let is_digit character = Char.between character ~low:'0' ~high:'9'

let is_valid_identifier = function
  | "" -> false
  | input ->
      input
      |> String.lowercase
      |> String.for_all ~f:(fun c ->
             is_lowercase_letter c || is_digit c || Char.equal c '_')

let camel_to_snake_case ~capitalize identifier =
  let buffer = Buffer.create (2 * String.length identifier) in
  let add_char = Buffer.add_char buffer in
  add_char
    (match capitalize with
    | true -> Char.uppercase identifier.[0]
    | false -> Char.lowercase identifier.[0]);
  String.iter (String.drop_prefix identifier 1) ~f:(fun character ->
      match is_uppercase_letter character with
      | true ->
          add_char '_';
          add_char (Char.lowercase character)
      | false -> add_char character);
  Buffer.contents buffer

let unreserve identifier =
  match identifier |> String.lowercase |> Hash_set.mem reserved_words with
  | true -> Some (Printf.sprintf "%s'" identifier)
  | false -> Some identifier

module type NAME = sig
  type t

  val of_string : string -> t option

  val to_string : t -> string

  val equal : t -> t -> bool

  val compare : t -> t -> int
end

module Make_capitalized_snake_case_name () : NAME = struct
  type t = string

  let of_string input =
    match is_valid_identifier input with
    | true -> (
      match String.equal (String.uppercase input) input with
      | true -> Some (input |> String.lowercase |> String.capitalize)
      | false -> input |> camel_to_snake_case ~capitalize:true |> unreserve)
    | false -> None

  let to_string = Fn.id

  let equal = String.equal

  let compare = String.compare
end

module Make_uncapitalized_snake_case_name () : NAME = struct
  type t = string

  let of_string input =
    match is_valid_identifier input with
    | true -> (
      match String.equal (String.uppercase input) input with
      | true -> Some (input |> String.lowercase)
      | false -> input |> camel_to_snake_case ~capitalize:false |> unreserve)
    | false -> None

  let to_string = Fn.id

  let equal = String.equal

  let compare = String.compare
end

module Module_name = Make_capitalized_snake_case_name ()

module Variant_name = Make_capitalized_snake_case_name ()

module Field_name = Make_uncapitalized_snake_case_name ()

module Module_path = struct
  type t = Module_name.t list

  let equal = List.equal Module_name.equal

  let compare = List.compare Module_name.compare

  let to_string name =
    name |> List.map ~f:Module_name.to_string |> String.concat ~sep:"."
end

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
  | Message_t of Module_path.t
  | Enum_t of Module_path.t

module Enum = struct
  type value = {
    original_name : string;
    id : int;
    variant_name : Variant_name.t;
  }

  type t = {
    module_name : Module_name.t;
    values : value list;
  }
end

module Oneof = struct
  type t = {
    module_name : Module_name.t;
    field_name : Field_name.t;
  }
end

module Field = struct
  type t = {
    field_name : Field_name.t;
    variant_name : Variant_name.t;
    number : int;
    data_type : field_data_type;
    repeated : bool;
    oneof_index : int option;
  }

  type group =
    | Single of t
    | Oneof of {
        module_name : Module_name.t;
        field_name : Field_name.t;
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
                let oneof = oneofs.(index) in
                let group =
                  Oneof
                    {
                      module_name = oneof.Oneof.module_name;
                      field_name = oneof.Oneof.field_name;
                      fields = Hashtbl.find_exn index_to_fields index |> List.rev;
                    }
                in
                index :: visited, group :: acc))
    in
    groups
end

module Message = struct
  type t = {
    module_name : Module_name.t;
    enums : Enum.t list;
    messages : t list;
    field_groups : Field.group list;
  }
end

module File = struct
  type t = {
    file_name : string;
    syntax : string;
    package : Module_path.t;
    module_name : Module_name.t;
    dependencies : t list;
    enums : Enum.t list;
    messages : Message.t list;
  }
end

type t = {files : File.t list}
