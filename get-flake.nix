with builtins;
file: args@{ hostname ? null, passExtra ? [ [ "inputs" "nixpkgs" ] [ "nixpkgs" "lib" ] ], ... }:
let
  gk = import ./getKeysSafe.nix;
  flake = getFlake file;
  system =
    let systems = flake.nixosConfigurations; in
    if hostname == null
    then systems.${head (attrNames flake.nixosConfigurations)}
    else systems.${hostname};
in
{ inherit flake system; } //
gk flake [ "inputs" "outputs" "sourceInfo" ] //
gk flake passExtra //
gk system [ "pkgs" "config" "options" ]
