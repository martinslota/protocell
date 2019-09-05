open Core
module P = Integers_pc

module Suite = Utils.Suite (struct
  include P.Int32

  let name = Caml.__MODULE__

  let protobuf_type_name = "Int32"

  let values_to_test =
    P.Int32.
      [
        {field = 42};
        {field = 0};
        {field = 1};
        {field = -1};
        {field = Option.value_exn Int32.(to_int min_value)};
      ]
end)
