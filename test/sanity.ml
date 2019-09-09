open Core
module Message_name = Sanity_pc.Message_name

module Suite = Utils.Suite (struct
  include Message_name

  let name = Caml.__MODULE__

  let protobuf_type_name = "Message_name"

  let values_to_test =
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
end)
