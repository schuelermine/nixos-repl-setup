# nix-repl-setup

This is a small utility that defines a payload, that, when loaded in your nix repl session, will prepopulate useful variables from your NixOS configuration

# Usage

The main function is under `repl-setup` if imported as a flake.

It takes these arguments:

- `source`: A URL or file path to the system configuration
- `isUrl`: Whether `source` is a flake URL  
  If this is unset, most URLs will fail
- `plainImport`: Whether to disregard `flake.nix` and always use import
- `passExtra`: A list of extra attributes to pass through  
  This uses a special format to navigate attrsets. A string will be interpreted as an attribute, a list of attributes as an attribute path, and a list of a string and another list as a renamed attribute path.  
  If you’re using a flake this is with respect to the flake itself. If not, with respect to the configuration (called `system`).

Flake-only arguments:

- `hostname`: What hostname the desired configuration is under. Otherwise it will select the first, alphabetically.

# Example

Save this as an easily accesible file (e.g. `~/repl.nix`):

```nix
let nix-repl-setup = builtins.getFlake "github:schuelermine/nix-repl-setup/88706a68afdf273eaa25b2626bf3f85db8427287";
in nix-repl-setup.repl-setup {
    hostname = "GigueMowHeadGrape";
    source = "git+file:///etc/nixos/";
    isUrl = true;
}
```