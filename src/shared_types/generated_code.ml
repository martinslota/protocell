module File = struct
  type t = {
    name : string;
    contents : string;
  }
end

type t = File.t list
