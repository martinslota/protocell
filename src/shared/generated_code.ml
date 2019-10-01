module File = struct
  type t = {
    file_name : string;
    contents : string;
  }
end

type t = File.t list

type generated_names = {
  runtime_module_name : string;
  module_alias : string;
  serialize : string;
  deserialize : string;
}

type output_format =
  | Binary
  | Text

let names_of_output_format = function
  | Binary ->
      {
        runtime_module_name = "Binary_format";
        module_alias = "B'";
        serialize = "serialize";
        deserialize = "deserialize";
      }
  | Text ->
      {
        runtime_module_name = "Text_format";
        module_alias = "T'";
        serialize = "stringify";
        deserialize = "unstringify";
      }
