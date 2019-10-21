open Base

module Flags : sig
  type t = (string * string list) list

  type error = [`Argument_without_flag of string]

  val show_error : error -> string

  val of_parameter_string : string -> (t, [> error]) Result.t
end = struct
  type t = (string * string list) list

  type error = [`Argument_without_flag of string]

  let show_error = function
    | `Argument_without_flag argument ->
        Printf.sprintf "Missing flag for argument '%s'" argument

  type token =
    | Flag of string
    | Argument of string

  let token_of_string input =
    match String.chop_prefix input ~prefix:"-" with
    | None -> (
      match String.is_prefix ~prefix:"'" input, String.is_suffix ~suffix:"'" input with
      | true, true -> Argument (String.sub input ~pos:1 ~len:(String.length input - 2))
      | _ -> Argument input)
    | Some flag -> Flag flag

  let tokenize : string -> token list =
   fun input ->
    input
    (* first separate out quoted tokens *)
    |> String.split ~on:'\''
    (* even-numbered components were not quoted, so split those on spaces *)
    |> List.concat_mapi ~f:(fun index piece ->
           match index % 2 = 0 with
           | true -> String.split piece ~on:' '
           | false -> [piece])
    |> List.filter ~f:(Fn.non String.is_empty)
    |> List.map ~f:token_of_string

  let to_flags : token list -> (t, _) Result.t = function
    | [] -> Ok []
    | Argument argument :: _ -> Error (`Argument_without_flag argument)
    | Flag flag :: rest ->
        let current_flag, arguments, flags =
          List.fold
            rest
            ~init:(flag, [], [])
            ~f:(fun (current_flag, arguments, flags) token ->
              match token with
              | Flag flag -> flag, [], (current_flag, List.rev arguments) :: flags
              | Argument argument -> current_flag, argument :: arguments, flags)
        in
        Ok ((current_flag, List.rev arguments) :: flags)

  let of_parameter_string input = input |> tokenize |> to_flags
end

module Options : sig
  type t = Shared.Protobuf.Options.t

  type error =
    [ `Unknown_flag of string
    | `Equals_sign_missing_in_int_mapping of string
    | `Unknown_integer_type of string
    | `Invalid_32_bit_integer_type of string
    | `Invalid_64_bit_integer_type of string ]

  val show_error : error -> string

  val apply_flags : init:t -> Flags.t -> (t, [> error]) Result.t
end = struct
  type t = Shared.Protobuf.Options.t

  type int32_typ = Shared.Protobuf.Options.int32_typ

  type int64_typ = Shared.Protobuf.Options.int64_typ

  type error =
    [ `Unknown_flag of string
    | `Equals_sign_missing_in_int_mapping of string
    | `Unknown_integer_type of string
    | `Invalid_32_bit_integer_type of string
    | `Invalid_64_bit_integer_type of string ]

  let show_error = function
    | `Equals_sign_missing_in_int_mapping mapping ->
        Printf.sprintf "Equals sign is missing in the int mapping '%s'" mapping
    | `Invalid_32_bit_integer_type typ ->
        Printf.sprintf "Invalid 32-bit integer type '%s'" typ
    | `Invalid_64_bit_integer_type typ ->
        Printf.sprintf "Invalid 64-bit integer type '%s'" typ
    | `Unknown_integer_type input -> Printf.sprintf "Unknown integer type '%s'" input
    | `Unknown_flag flag -> Printf.sprintf "Unknown flag '%s'" flag

  module Integer_type_mapping = struct
    type pattern =
      | Exact of string
      | Suffix of string

    let pattern_of_string input =
      match String.chop_prefix ~prefix:"*" input with
      | None -> Exact input
      | Some suffix -> Suffix suffix

    type mapped_type =
      | Int_typ
      | Int32_typ
      | Int64_typ

    let mapped_type_of_string = function
      | "int" -> Some Int_typ
      | "int32" -> Some Int32_typ
      | "int64" -> Some Int64_typ
      | _ -> None

    let mapped_type_to_string = function
      | Int_typ -> "int"
      | Int32_typ -> "int32"
      | Int64_typ -> "int64"

    type t = pattern * mapped_type

    let matches type_name = function
      | Exact full_name -> String.equal type_name full_name
      | Suffix suffix -> String.is_suffix type_name ~suffix

    let of_string input =
      match String.lsplit2 input ~on:'=' with
      | None -> Error (`Equals_sign_missing_in_int_mapping input)
      | Some (pattern, mapped_type) -> (
          let pattern = pattern_of_string pattern in
          match mapped_type_of_string mapped_type with
          | None -> Error (`Unknown_integer_type mapped_type)
          | Some mapped_type -> Ok (pattern, mapped_type))

    let apply_32_bit : string -> int32_typ -> t -> (int32_typ, _) Result.t =
     fun type_name typ (pattern, mapped_type) ->
      match matches type_name pattern with
      | false -> Ok typ
      | true -> (
        match mapped_type with
        | Int_typ -> Ok As_int
        | Int32_typ -> Ok As_int32
        | Int64_typ as typ ->
            Error (`Invalid_32_bit_integer_type (mapped_type_to_string typ)))

    let apply_64_bit : string -> int64_typ -> t -> (int64_typ, _) Result.t =
     fun type_name typ (pattern, mapped_type) ->
      match matches type_name pattern with
      | false -> Ok typ
      | true -> (
        match mapped_type with
        | Int_typ -> Ok As_int
        | Int32_typ as typ ->
            Error (`Invalid_64_bit_integer_type (mapped_type_to_string typ))
        | Int64_typ -> Ok As_int64)
  end

  let map_32
      : string -> int32_typ -> Integer_type_mapping.t list -> (int32_typ, _) Result.t
    =
   fun type_name init ->
    List.fold_result ~init ~f:(Integer_type_mapping.apply_32_bit type_name)

  let map_64
      : string -> int64_typ -> Integer_type_mapping.t list -> (int64_typ, _) Result.t
    =
   fun integer_type_name init ->
    List.fold_result ~init ~f:(Integer_type_mapping.apply_64_bit integer_type_name)

  let apply_flag options (flag, arguments) =
    match flag with
    | "with-derivers" -> Ok Shared.Protobuf.Options.{options with derivers = arguments}
    | "map-int" -> (
      match arguments |> List.map ~f:Integer_type_mapping.of_string |> Result.all with
      | Error _ as error -> error
      | Ok mappings ->
          let open Result.Let_syntax in
          map_32 "int32" options.int32_typ mappings >>= fun int32_typ ->
          map_64 "int64" options.int64_typ mappings >>= fun int64_typ ->
          map_32 "sint32" options.sint32_typ mappings >>= fun sint32_typ ->
          map_64 "sint64" options.sint64_typ mappings >>= fun sint64_typ ->
          map_32 "uint32" options.uint32_typ mappings >>= fun uint32_typ ->
          map_64 "uint64" options.uint64_typ mappings >>= fun uint64_typ ->
          map_32 "fixed32" options.fixed32_typ mappings >>= fun fixed32_typ ->
          map_64 "fixed64" options.fixed64_typ mappings >>= fun fixed64_typ ->
          map_32 "sfixed32" options.sfixed32_typ mappings >>= fun sfixed32_typ ->
          map_64 "sfixed64" options.sfixed64_typ mappings >>= fun sfixed64_typ ->
          Ok
            {
              options with
              int32_typ;
              int64_typ;
              sint32_typ;
              sint64_typ;
              uint32_typ;
              uint64_typ;
              fixed32_typ;
              fixed64_typ;
              sfixed32_typ;
              sfixed64_typ;
            })
    | "no-automatic-well-known-types" -> Ok {options with well_known_types = On_request}
    | flag -> Error (`Unknown_flag flag)

  let apply_flags ~init flags = List.fold_result flags ~init ~f:apply_flag
end

let apply : Options.t -> string option -> (Options.t, _) Result.t =
 fun init parameter ->
  let open Result.Let_syntax in
  match parameter with
  | None -> Ok init
  | Some input -> input |> Flags.of_parameter_string >>= Options.apply_flags ~init
