with builtins;
args@{ source ? "/etc/nixos", ... }:
let
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
  dir = if isDir then source else parentDir;
  dirContent = readDir dir;
  mkTarget = name: if isDir then "${source}/${name}" else source;
  checkedFile = mkTarget {
    flake = "flake.nix";
    legacy = if dir ? "configuration.nix" then "configuration.nix" else "default.nix";
  }.${type};
  type =
    if baseName == "default.nix" || baseName == "configuration.nix" then "legacy"
    else if dirContent ? "flake.nix" then "flake"
    else "legacy";
  targetFile = if type == "flake" then dirOf checkedFile else checkedFile;
in
import {
  flake = ./get-flake.nix;
  legacy = ./get-legacy.nix;
}.${type}
  targetFile
  args
