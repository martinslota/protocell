let () =
  Alcotest.run
    "Protocell test suite"
    [Sanity.Suite.tests; Integers.Serdes_int_32.tests; Integers.Serdes_int_64.tests]
