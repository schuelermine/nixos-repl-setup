{
  description =
    "Small utility to prepopulate nix repl variables for flake configurations";
  outputs = { self }: { repl-setup = import ./repl-setup.nix; };
}
