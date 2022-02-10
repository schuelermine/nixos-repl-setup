file: args@{ ... }:
let
  module = import ./file;
  system =
    import /${
        let attempt = tryEval <nixos>; in
        if attempt.success then attempt.value else <nixpkgs>
      }/nixos
      { configuration = file; };
in
{
  inherit module system;
  inherit (system) pkgs config options;
}
