{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true; # RFC-style Nix formatter
    prettier.enable = true; # markdown, json, yaml
  };

  settings.global.excludes = [
    "*.lock"
    "LICENSE"
  ];

  settings.formatter.mago = {
    command = pkgs.mago;
    options = [ "format" ];
    includes = [ "*.php" ];
  };
}
