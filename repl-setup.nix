with builtins;
let
  self = args@{ configPath ? "/etc/nixos", inputName ? "nixpkgs"
    , hostname ? null, system ? builtins.currentSystem, passInput ? true
    , passPkgs ? true, passExtra ? [ "lib" ] }:
    let
      extra = builtins.listToAttrs (map (k: {
        name = k;
        value = payload.${inputName};
      }) passExtra);
      payload = {
        repl-setup = { inherit args self payload extra; };
        seq-pkgs = seq payload.pkgs true;
        configFlake = getFlake configPath;
        configs = payload.configFlake.nixosConfigurations or { };
        hostname = if hostname != null then
          hostname
        else if payload.configs != { } then
          head (attrNames payload.configs)
        else
          null;
        ${
          if payload.hostname != null && payload.configs ? ${hostname} then
            "configuration"
          else
            null
        } = payload.configs.${hostname};
        ${if passInput then inputName else null} =
          payload.configFlake.inputs.${inputName};
        ${if passPkgs then "pkgs" else null} =
          payload.${inputName}.legacyPackages.${system};
      } // extra;
    in payload;
in self
