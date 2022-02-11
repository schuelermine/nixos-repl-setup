let self = with builtins;
args@{ source ? "/etc/nixos", ... }:
let vars = rec {
  errors = mapAttrs (k: v: throw v) {
    sourceDoesNotExist =
      "The source file or directory '${source}' does not exist.";
    symlinksNotSupported = ''
      While attempting to evaluate if '${source}' is a directory, it was found to be a symlink.
      Unfortunately, Nix does not yet support inspecting a symlink's target.
    '';
  };
  baseName = baseNameOf source;
  parentDir = dirOf source;
  parentDirContent = readDir parentDir;
  sourceType = parentDirContent.${baseName} or errors.sourceDoesNotExist;
  isDir =
    if sourceType == "symlink" then
      errors.symlinksNotSupported
    else
      sourceType == "directory";
  directory = if isDir then source else parentDir;
  dirContent = readDir directory;
  mkTarget = name: if isDir then "${source}/${name}" else source;
  checkedFile = mkTarget {
    flake = "flake.nix";
    legacy = if directory ? "configuration.nix" then "configuration.nix" else "default.nix";
  }.${type};
  type =
    if baseName == "default.nix" || baseName == "configuration.nix" then "legacy"
    else if dirContent ? "flake.nix" then "flake"
    else "legacy";
  targetFile = if type == "flake" then dirOf checkedFile else checkedFile;
};
in
with vars;
import {
  flake = ./get-flake.nix;
  legacy = ./get-legacy.nix;
}.${type}
  targetFile
  args // { setupVars = { inherit self args; } // removeAttrs vars [ "errors" "parentDirContent" ]; };
in self
