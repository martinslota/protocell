open Core
module P = Integers_pc

module Serdes_int_32 = struct
  include P.Int32

  let name = Caml.__MODULE__

  let protobuf_type_name = "Int32"

  let values_to_test =
    [
      {field = 42};
      {field = 0};
      {field = 1};
      {field = -1};
      {field = Option.value_exn Int32.(to_int min_value)};
    ]
end

module Serdes_int_64 = struct
  include P.Int64

  let name = Caml.__MODULE__

  let protobuf_type_name = "Int64"

  let values_to_test =
    [
      {field = 42};
      {field = 0};
      {field = 1};
      {field = -1};
      {field = Option.value_exn Int32.(to_int min_value)};
    ]
end

module Serdes_sint_32 = struct
  include P.Sint32

  let name = Caml.__MODULE__

  let protobuf_type_name = "Sint32"

  let values_to_test =
    [
      {field = 42};
      {field = 0};
      {field = 1};
      {field = -1};
      {field = Option.value_exn Int32.(to_int min_value)};
    ]
end

module Serdes_sint_64 = struct
  include P.Sint64

  let name = Caml.__MODULE__

  let protobuf_type_name = "Sint64"

  let values_to_test =
    [
      {field = 42};
      {field = 0};
      {field = 1};
      {field = -1};
      {field = Option.value_exn Int32.(to_int min_value)};
    ]
end

let int_32_tests = Utils.suite (module Serdes_int_32)

let int_64_tests = Utils.suite (module Serdes_int_64)

let sint_32_tests = Utils.suite (module Serdes_sint_32)

let sint_64_tests = Utils.suite (module Serdes_sint_64)
