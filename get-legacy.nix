with builtins;
file: args@{ passExtra ? [ [ "pkgs" "lib" ] ], ... }:
let
  gk = import ./getKeysSafe.nix;
  module = import file;
  system =
    import /${
        let attempt = tryEval <nixos>; in
        if attempt.success then attempt.value else <nixpkgs>
      }/nixos
      { configuration = file; };
in
{ inherit module system; } //
gk system passExtra //
gk system [ "pkgs" "config" "options" ]
