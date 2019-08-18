[@@@ocaml.warning "-27-30-39"]

let rec pp_code_generator_request fmt (v:Plugin_types.code_generator_request) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "file_to_generate" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.Plugin_types.file_to_generate;
    Pbrt.Pp.pp_record_field "parameter" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.Plugin_types.parameter;
    Pbrt.Pp.pp_record_field "proto_file" (Pbrt.Pp.pp_list Descriptor_pp.pp_file_descriptor_proto) fmt v.Plugin_types.proto_file;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_code_generator_response_file fmt (v:Plugin_types.code_generator_response_file) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "name" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.Plugin_types.name;
    Pbrt.Pp.pp_record_field "insertion_point" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.Plugin_types.insertion_point;
    Pbrt.Pp.pp_record_field "content" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.Plugin_types.content;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_code_generator_response fmt (v:Plugin_types.code_generator_response) = 
  let pp_i fmt () =
    Format.pp_open_vbox fmt 1;
    Pbrt.Pp.pp_record_field "error" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.Plugin_types.error;
    Pbrt.Pp.pp_record_field "file" (Pbrt.Pp.pp_list pp_code_generator_response_file) fmt v.Plugin_types.file;
    Format.pp_close_box fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()
