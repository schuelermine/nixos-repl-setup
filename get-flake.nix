with builtins;
file: args@{ hostname ? null, passInputs ? [ "nixpkgs" [ "nixpkgs" "lib" ] ] }:
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
gk flake.inputs passInputs //
gk system [ "pkgs" "config" "options" ]
