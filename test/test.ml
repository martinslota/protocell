let () = Alcotest.run "Protocell test suite" @@ List.concat [Types.tests; Map_int.tests]
