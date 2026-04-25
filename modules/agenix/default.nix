{ pkgs, lib, ... }:
let
  home = if pkgs.stdenv.isDarwin then "/Users/me" else "/home/me";
  userGroup = if pkgs.stdenv.isDarwin then "staff" else "users";

  maybeSecret =
    name: file: extra:
    lib.optionalAttrs (builtins.pathExists file) {
      ${name} = {
        inherit file;
        owner = "me";
        group = userGroup;
      }
      // extra;
    };
in
{
  age.identityPaths =
    if pkgs.stdenv.isDarwin then
      [
        "${home}/.config/age/keys-se.txt"
        "${home}/.config/age/keys.txt"
      ]
    else
      [
        "/run/age/keys.txt"
        "${home}/.config/age/keys.txt"
      ];

  age.secrets = lib.mkMerge [
    (maybeSecret "work-shell" ../../secrets/work-shell.age { })
    (maybeSecret "git-local-include" ../../secrets/git-local-include.age { })
    (maybeSecret "claude-routing" ../../secrets/claude-routing.age { })
    (maybeSecret "me-password" ../../secrets/me-password.age {
      owner = "root";
      group = "root";
    })
  ];

  environment.systemPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.age-plugin-se
  ];
}
