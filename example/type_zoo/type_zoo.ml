open Base
module Exposition = Type_zoo_pc.Exposition
module Platypus = Type_zoo_pc.Platypus

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
      hest = [49; 50; 51];
      indri = 52;
      jellyfish = 53;
      kingfisher = 54.1;
      llama = 54.2;
      meerkat = true;
      nightingale = "56";
      octopus = "57";
      platypus = Platypus.Standing;
      cute = Some (Exposition.Cute.Quetzal "58");
      pavilion =
        [
          {
            alpaca = -42;
            bear = -43;
            cuckoo = -44;
            dolphin = -45;
            elephant = 46;
            fox = 0;
            giraffe = 0;
            hest = [0; 0; 0];
            indri = -52;
            jellyfish = -53;
            kingfisher = -54.1;
            llama = -54.2;
            meerkat = false;
            nightingale = "-56";
            octopus = "-57";
            platypus = Platypus.Lying;
            cute = Some (Exposition.Cute.Quetzal "-58");
            pavilion = [];
          };
        ];
    }

let () =
  let open Result.Let_syntax in
  message
  |> Exposition.to_binary
  >>= Exposition.of_binary
  >>| Exposition.show
  >>| Printf.sprintf "Here's the deserialized ZOO:\n%s"
  >>| Stdio.print_endline
  |> ignore
