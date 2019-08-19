[@@@ocaml.warning "-27-30-39"]

type code_generator_request_mutable = {
  mutable file_to_generate : string list;
  mutable parameter : string option;
  mutable proto_file : Descriptor_types.file_descriptor_proto list;
}

let default_code_generator_request_mutable () : code_generator_request_mutable = {
  file_to_generate = [];
  parameter = None;
  proto_file = [];
}

type code_generator_response_file_mutable = {
  mutable name : string option;
  mutable insertion_point : string option;
  mutable content : string option;
}

let default_code_generator_response_file_mutable () : code_generator_response_file_mutable = {
  name = None;
  insertion_point = None;
  content = None;
}

type code_generator_response_mutable = {
  mutable error : string option;
  mutable file : Plugin_types.code_generator_response_file list;
}

let default_code_generator_response_mutable () : code_generator_response_mutable = {
  error = None;
  file = [];
}


let rec decode_code_generator_request d =
  let v = default_code_generator_request_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.proto_file <- List.rev v.proto_file;
      v.file_to_generate <- List.rev v.file_to_generate;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.file_to_generate <- (Pbrt.Decoder.string d) :: v.file_to_generate;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_request), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.parameter <- Some (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_request), field(2)" pk
    | Some (15, Pbrt.Bytes) -> begin
      v.proto_file <- (Descriptor_pb.decode_file_descriptor_proto (Pbrt.Decoder.nested d)) :: v.proto_file;
    end
    | Some (15, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_request), field(15)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Plugin_types.file_to_generate = v.file_to_generate;
    Plugin_types.parameter = v.parameter;
    Plugin_types.proto_file = v.proto_file;
  } : Plugin_types.code_generator_request)

let rec decode_code_generator_response_file d =
  let v = default_code_generator_response_file_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.name <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_response_file), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.insertion_point <- Some (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_response_file), field(2)" pk
    | Some (15, Pbrt.Bytes) -> begin
      v.content <- Some (Pbrt.Decoder.string d);
    end
    | Some (15, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_response_file), field(15)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Plugin_types.name = v.name;
    Plugin_types.insertion_point = v.insertion_point;
    Plugin_types.content = v.content;
  } : Plugin_types.code_generator_response_file)

let rec decode_code_generator_response d =
  let v = default_code_generator_response_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.file <- List.rev v.file;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.error <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_response), field(1)" pk
    | Some (15, Pbrt.Bytes) -> begin
      v.file <- (decode_code_generator_response_file (Pbrt.Decoder.nested d)) :: v.file;
    end
    | Some (15, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_generator_response), field(15)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    Plugin_types.error = v.error;
    Plugin_types.file = v.file;
  } : Plugin_types.code_generator_response)

let rec encode_code_generator_request (v:Plugin_types.code_generator_request) encoder = 
  List.iter (fun x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  ) v.Plugin_types.file_to_generate;
  begin match v.Plugin_types.parameter with
  | Some x -> 
    Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  List.iter (fun x -> 
    Pbrt.Encoder.key (15, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (Descriptor_pb.encode_file_descriptor_proto x) encoder;
  ) v.Plugin_types.proto_file;
  ()

let rec encode_code_generator_response_file (v:Plugin_types.code_generator_response_file) encoder = 
  begin match v.Plugin_types.name with
  | Some x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  begin match v.Plugin_types.insertion_point with
  | Some x -> 
    Pbrt.Encoder.key (2, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  begin match v.Plugin_types.content with
  | Some x -> 
    Pbrt.Encoder.key (15, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  ()

let rec encode_code_generator_response (v:Plugin_types.code_generator_response) encoder = 
  begin match v.Plugin_types.error with
  | Some x -> 
    Pbrt.Encoder.key (1, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.string x encoder;
  | None -> ();
  end;
  List.iter (fun x -> 
    Pbrt.Encoder.key (15, Pbrt.Bytes) encoder; 
    Pbrt.Encoder.nested (encode_code_generator_response_file x) encoder;
  ) v.Plugin_types.file;
  ()
