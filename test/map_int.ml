module P = Map_int_pc

let tests =
  [
    Utils.invariant_suite
      (module P.Integers)
      ~protobuf_file_name:"map_int.proto"
      ~protobuf_type_name:"Integers"
      [
        P.Integers.
          {
            int32' = 1;
            int64' = 2;
            sint32 = 3;
            sint64 = 4;
            uint32 = 5;
            uint64 = 6;
            fixed32 = 7;
            fixed64 = 8L;
            sfixed32 = 9l;
            sfixed64 = 10L;
          };
      ];
  ]
