with builtins;
let
  self = args@{ configPath ? "/etc/nixos", inputName ? "nixpkgs"
    , system ? builtins.currentSystem, passInput ? true, passPkgs ? true
    , passExtra ? [ "lib" ] }:
    let
      extra = builtins.listToAttrs (map (k: {
        name = k;
        value = payload.${inputName};
      }) passExtra);
      payload = {
        repl-setup = { inherit args self payload extra; };
        seq-pkgs = seq payload.pkgs true;
        config = getFlake configPath;
        ${if passInput then inputName else null} =
          payload.config.inputs.${inputName};
        ${if passPkgs then "pkgs" else null} =
          payload.${inputName}.legacyPackages.${system};
      } // extra;
    in payload;
in self
