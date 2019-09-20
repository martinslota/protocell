let () =
  Alcotest.run
    "Protocell test suite"
    [
      Sanity.tests;
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
    ]
