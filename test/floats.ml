open Core
module P = Floats_pc

let name = Caml.__MODULE__

let float_tests =
  Utils.suite (module P.Float) name "Float"
  @@ List.map [0.0; 1.1; -2.8; Float.atan 0.5] ~f:(fun field ->
         let field = field |> Int32.bits_of_float |> Int32.float_of_bits in
         P.Float.{field})

let double_tests =
  Utils.suite (module P.Double) name "Double"
  @@ List.map [0.0; 1.1; -2.8; Float.atan 0.5] ~f:(fun field -> P.Double.{field})
