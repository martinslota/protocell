[@@@ocaml.warning "-27-30-39"]


type code_generator_request = {
  file_to_generate : string list;
  parameter : string option;
  proto_file : Descriptor_types.file_descriptor_proto list;
}

type code_generator_response_file = {
  name : string option;
  insertion_point : string option;
  content : string option;
}

type code_generator_response = {
  error : string option;
  file : code_generator_response_file list;
}

let rec default_code_generator_request 
  ?file_to_generate:((file_to_generate:string list) = [])
  ?parameter:((parameter:string option) = None)
  ?proto_file:((proto_file:Descriptor_types.file_descriptor_proto list) = [])
  () : code_generator_request  = {
  file_to_generate;
  parameter;
  proto_file;
}

let rec default_code_generator_response_file 
  ?name:((name:string option) = None)
  ?insertion_point:((insertion_point:string option) = None)
  ?content:((content:string option) = None)
  () : code_generator_response_file  = {
  name;
  insertion_point;
  content;
}

let rec default_code_generator_response 
  ?error:((error:string option) = None)
  ?file:((file:code_generator_response_file list) = [])
  () : code_generator_response  = {
  error;
  file;
}
