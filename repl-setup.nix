with builtins;
args@{ source ? "/etc/nixos", ... }:
let files = readDir source;
in import ./process-data.nix (import
  (if files ? "flake.nix" then ./get-data-flake.nix else ./get-data-legacy.nix)
  files args)
