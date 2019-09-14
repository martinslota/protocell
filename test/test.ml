let () =
  Alcotest.run
    "Protocell test suite"
    [
      Sanity.tests;
      Integers.int_32_tests;
      Integers.int_64_tests;
      Integers.sint_32_tests;
      Integers.sint_64_tests;
    ]
