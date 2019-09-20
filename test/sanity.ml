open Core

let tests =
  Utils.suite
    (module Sanity_pc.Message_name)
    Caml.__MODULE__
    "Message_name"
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
