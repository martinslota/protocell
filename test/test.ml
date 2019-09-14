let () =
  Alcotest.run
    "Protocell test suite"
    [Sanity.tests; Integers.int_32_tests; Integers.int_64_tests]
