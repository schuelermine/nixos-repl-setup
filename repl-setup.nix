let self = with builtins;
args@{ source ? "/etc/nixos", isUrl ? false, plainImport ? false, ... }:
let vars = #Set up the target, depending on if it’s a flake URL or something else
  if !isUrl then rec {
    #If it’s a file, figure out if it’s a flake
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
      if baseName == "default.nix" || baseName == "configuration.nix" || plainImport then "legacy"
      else if dirContent ? "flake.nix" then "flake"
      else "legacy";
    target = if type == "flake" then dirOf checkedFile else checkedFile;
  }
  else rec {
    sourceType = "directory";
    isDir = true;
    type = "flake";
    target = source;
  };
in
with vars;
import {
  flake = ./get-flake.nix;
  legacy = ./get-legacy.nix;
}.${type} #Select the file depending on if it’s a flake
  target
  args // {
  setupVars = #Add the setup variables (why not?)
    { inherit self args; } // removeAttrs vars [ "parentDirContents" "mkTarget" "errors" ];
};
in self
