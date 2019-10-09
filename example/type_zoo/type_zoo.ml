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
            hest = [0; 0; 0];
            indri = -52;
            jellyfish = -53;
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
  >>| Printf.sprintf "Here's the deserialized ZOO:\n%s"
  >>| Stdio.print_endline
  |> ignore
