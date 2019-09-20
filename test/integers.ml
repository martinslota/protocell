open Core
module P = Integers_pc

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

let name = Caml.__MODULE__

let int32_tests =
  Utils.suite (module P.Int32) name "Int32"
  @@ List.map signed_32_bit_test_values ~f:(fun field -> P.Int32.{field})

let int64_tests =
  Utils.suite (module P.Int64) name "Int64"
  @@ List.map signed_64_bit_test_values ~f:(fun field -> P.Int64.{field})

let sint32_tests =
  Utils.suite (module P.Sint32) name "Sint32"
  @@ List.map signed_32_bit_test_values ~f:(fun field -> P.Sint32.{field})

let sint64_tests =
  Utils.suite (module P.Sint64) name "Sint64"
  @@ List.map signed_64_bit_test_values ~f:(fun field -> P.Sint64.{field})

let uint32_tests =
  Utils.suite (module P.Uint32) name "Uint32"
  @@ List.map unsigned_32_bit_test_values ~f:(fun field -> P.Uint32.{field})

let uint64_tests =
  Utils.suite (module P.Uint64) name "Uint64"
  @@ List.map unsigned_64_bit_test_values ~f:(fun field -> P.Uint64.{field})

let fixed32_tests =
  Utils.suite (module P.Fixed32) name "Fixed32"
  @@ List.map unsigned_32_bit_test_values ~f:(fun field -> P.Fixed32.{field})

let fixed64_tests =
  Utils.suite (module P.Fixed64) name "Fixed64"
  @@ List.map unsigned_64_bit_test_values ~f:(fun field -> P.Fixed64.{field})

let sfixed32_tests =
  Utils.suite (module P.Sfixed32) name "Sfixed32"
  @@ List.map signed_32_bit_test_values ~f:(fun field -> P.Sfixed32.{field})

let sfixed64_tests =
  Utils.suite (module P.Sfixed64) name "Sfixed64"
  @@ List.map signed_64_bit_test_values ~f:(fun field -> P.Sfixed64.{field})
