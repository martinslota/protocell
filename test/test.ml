open Core
module P = Test_pc

module Strings = struct
  let tests =
    Utils.suite (module P.String) "String"
    @@ List.map ["just a string"] ~f:(fun field -> P.String.{field})
end

module Bytes = struct
  let tests =
    Utils.suite (module P.Bytes) "Bytes"
    @@ List.map ["just some bytes"] ~f:(fun field -> P.Bytes.{field})
end

module Integers = struct
  let common_non_negative_test_values =
    [
      0;
      1;
      42;
      127;
      128;
      255;
      256;
      32767;
      32768;
      65535;
      65536;
      Int32.(to_int max_value) |> Option.value ~default:Int.max_value;
    ]

  let common_negative_test_values = [-1; -42; -32768; -32769; -2147483648]

  let signed_32_bit_test_values =
    List.concat [common_non_negative_test_values; common_negative_test_values]

  let unsigned_32_bit_test_values =
    List.concat
      [
        common_non_negative_test_values;
        [
          Int32.(to_int max_value)
          |> Option.map ~f:(fun i -> (2 * i) + 1)
          |> Option.value ~default:Int.max_value;
          3_000_000_000;
        ];
      ]

  let signed_64_bit_test_values =
    List.concat
      [
        common_non_negative_test_values;
        common_negative_test_values;
        [Int.max_value; Int.min_value];
      ]

  let unsigned_64_bit_test_values =
    List.concat [common_non_negative_test_values; [Int.max_value]]

  let int32_tests =
    Utils.suite (module P.Int32) "Int32"
    @@ List.map signed_32_bit_test_values ~f:(fun field -> P.Int32.{field})

  let int64_tests =
    Utils.suite (module P.Int64) "Int64"
    @@ List.map signed_64_bit_test_values ~f:(fun field -> P.Int64.{field})

  let sint32_tests =
    Utils.suite (module P.Sint32) "Sint32"
    @@ List.map signed_32_bit_test_values ~f:(fun field -> P.Sint32.{field})

  let sint64_tests =
    Utils.suite (module P.Sint64) "Sint64"
    @@ List.map signed_64_bit_test_values ~f:(fun field -> P.Sint64.{field})

  let uint32_tests =
    Utils.suite (module P.Uint32) "Uint32"
    @@ List.map unsigned_32_bit_test_values ~f:(fun field -> P.Uint32.{field})

  let uint64_tests =
    Utils.suite (module P.Uint64) "Uint64"
    @@ List.map unsigned_64_bit_test_values ~f:(fun field -> P.Uint64.{field})

  let fixed32_tests =
    Utils.suite (module P.Fixed32) "Fixed32"
    @@ List.map unsigned_32_bit_test_values ~f:(fun field -> P.Fixed32.{field})

  let fixed64_tests =
    Utils.suite (module P.Fixed64) "Fixed64"
    @@ List.map unsigned_64_bit_test_values ~f:(fun field -> P.Fixed64.{field})

  let sfixed32_tests =
    Utils.suite (module P.Sfixed32) "Sfixed32"
    @@ List.map signed_32_bit_test_values ~f:(fun field -> P.Sfixed32.{field})

  let sfixed64_tests =
    Utils.suite (module P.Sfixed64) "Sfixed64"
    @@ List.map signed_64_bit_test_values ~f:(fun field -> P.Sfixed64.{field})
end

module Floats = struct
  let common_test_values = [0.0; 1.1; -2.8; Float.atan 0.5; 1.234e7; -1.937465623e-6]

  let float_tests =
    Utils.suite (module P.Float) "Float"
    @@ List.map common_test_values ~f:(fun field ->
           let field = field |> Int32.bits_of_float |> Int32.float_of_bits in
           P.Float.{field})

  let double_tests =
    Utils.suite (module P.Double) "Double"
    @@ List.map common_test_values ~f:(fun field -> P.Double.{field})
end

module Bools = struct
  let tests =
    Utils.suite (module P.Bool) "Bool"
    @@ List.map [true; false] ~f:(fun field -> P.Bool.{field})
end

module Messages = struct
  let two_fields_tests =
    Utils.suite
      (module P.Two_fields)
      "TwoFields"
      [
        {int_field = 42; string_field = "hey there!"};
        {int_field = -1; string_field = ""};
        {
          int_field = 0;
          string_field =
            {|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
               "a rather problematic string"
              \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|};
        };
      ]

  let with_nested_submessage_tests =
    Utils.suite
      (module P.With_nested_submessage)
      "WithNestedSubmessage"
      [P.With_nested_submessage.{field = Some Nested.{field = "something"}}]

  let mutual_references_tests =
    Utils.suite
      (module P.Mutual_references)
      "MutualReferences"
      [
        P.Mutual_references.{field = Some Nested1.{field1 = None}};
        P.Mutual_references.
          {
            field =
              Some
                Nested1.{field1 = Some Nested2.{field2 = Some Nested1.{field1 = None}}};
          };
      ]
end

module Enums = struct
  let tests =
    Utils.suite
      (module P.With_enum)
      "WithEnum"
      [P.With_enum.{field = Day}; P.With_enum.{field = Night}]
end

module Repeated = struct
  let repeated_string_tests =
    Utils.suite
      (module P.Repeated_string)
      "RepeatedString"
      [P.Repeated_string.{field = ["aaa"; "bbb"]}]

  let repeated_int64_unpacked_tests =
    Utils.suite
      (module P.Repeated_int64_unpacked)
      "RepeatedInt64Unpacked"
      [P.Repeated_int64_unpacked.{field = [1; 2; 3]}]

  let repeated_int64_packed_tests =
    Utils.suite
      (module P.Repeated_int64_packed)
      "RepeatedInt64Packed"
      [P.Repeated_int64_packed.{field = [1; 2; 3]}]
end

module Oneof = struct
  let tests =
    Utils.suite
      (module P.With_one_of)
      "WithOneOf"
      [
        P.With_one_of.{choice = Some (Apples "42"); bananas = 47};
        P.With_one_of.{choice = Some (Oranges 42); bananas = 47};
      ]
end

let () =
  Alcotest.run
    "Protocell test suite"
    [
      Strings.tests;
      Bytes.tests;
      Integers.int32_tests;
      Integers.int64_tests;
      Integers.sint32_tests;
      Integers.sint64_tests;
      Integers.uint32_tests;
      Integers.uint64_tests;
      Integers.fixed32_tests;
      Integers.fixed64_tests;
      Integers.sfixed32_tests;
      Integers.sfixed64_tests;
      Floats.float_tests;
      Floats.double_tests;
      Bools.tests;
      Messages.two_fields_tests;
      Messages.with_nested_submessage_tests;
      Messages.mutual_references_tests;
      Enums.tests;
      Repeated.repeated_string_tests;
      Repeated.repeated_int64_unpacked_tests;
      Repeated.repeated_int64_packed_tests;
      Oneof.tests;
    ]
