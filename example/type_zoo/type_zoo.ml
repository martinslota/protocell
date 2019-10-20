open Base
module Exposition = Type_zoo_pc.Exposition

let message =
  Exposition.
    {
      alpaca = 42;
      bear = 43;
      cuckoo = 44;
      dolphin = 45;
      elephant = 46;
      fox = 47;
      giraffe = 48;
      hest = [49L; 50L; 51L];
      indri = 52l;
      jellyfish = 53L;
      kingfisher = 54.1;
      llama = 55.2;
      meerkat = true;
      nightingale = "56";
      octopus = "57";
      platypus = Standing;
      cute = Some (Quetzal "58");
      sub_pavilions =
        [
          {
            alpaca = -42;
            bear = -43;
            cuckoo = -44;
            dolphin = -45;
            elephant = 0;
            fox = 0;
            giraffe = 0;
            hest = [0L; 0L; 0L];
            indri = -52l;
            jellyfish = -53L;
            kingfisher = -54.1;
            llama = -55.2;
            meerkat = false;
            nightingale = "-56";
            octopus = "-57";
            platypus = Lying;
            cute = Some (Quetzal "-58");
            sub_pavilions = [];
          };
        ];
    }

let () =
  let open Result.Let_syntax in
  message
  |> Exposition.to_binary
  >>= Exposition.of_binary
  >>| Exposition.show
  >>| Printf.sprintf "Here's the deserialized ZOO:\n\n%s"
  >>| Stdio.print_endline
  |> ignore
