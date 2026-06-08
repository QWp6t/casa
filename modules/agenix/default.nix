{ pkgs, lib, ... }:
let
  home = if pkgs.stdenv.isDarwin then "/Users/me" else "/home/me";
  claudeRoutingPath = "${home}/.local/share/agenix/claude-routing";
  claudeWorkBriefingPath = "${home}/.local/share/agenix/claude-work-briefing";
  claudeWorkInstallPath = "${home}/.local/share/agenix/claude-work-install";
  claudeWorkSettingsPath = "${home}/.local/share/agenix/claude-work-settings";
  codexSentryAuthTokenPath = "${home}/.local/share/agenix/codex-sentry-auth-token";
  gitClientIncludePath = "${home}/.local/share/agenix/git-client-include";
  gitLocalIncludePath = "${home}/.local/share/agenix/git-local-include";
  gitWorkIncludePath = "${home}/.local/share/agenix/git-work-include";
  workAwsConfigPath = "${home}/.local/share/agenix/work-aws-config";
  workShellPath = "${home}/.local/share/agenix/work-shell";
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
    (maybeSecret "work-aws-config" ../../secrets/work-aws-config.age {
      path = workAwsConfigPath;
      symlink = false;
    })
    (maybeSecret "work-shell" ../../secrets/work-shell.age {
      path = workShellPath;
      symlink = false;
    })
    (maybeSecret "git-local-include" ../../secrets/git-local-include.age {
      path = gitLocalIncludePath;
      symlink = false;
    })
    (maybeSecret "git-client-include" ../../secrets/git-client-include.age {
      path = gitClientIncludePath;
      symlink = false;
    })
    (maybeSecret "git-work-include" ../../secrets/git-work-include.age {
      path = gitWorkIncludePath;
      symlink = false;
    })
    (maybeSecret "claude-routing" ../../secrets/claude-routing.age {
      path = claudeRoutingPath;
      symlink = false;
    })
    (maybeSecret "claude-work-settings" ../../secrets/claude-work-settings.age {
      path = claudeWorkSettingsPath;
      symlink = false;
    })
    (maybeSecret "claude-work-briefing" ../../secrets/claude-work-briefing.age {
      path = claudeWorkBriefingPath;
      symlink = false;
    })
    (maybeSecret "claude-work-install" ../../secrets/claude-work-install.age {
      path = claudeWorkInstallPath;
      mode = "0500";
      symlink = false;
    })
    (maybeSecret "codex-sentry-auth-token" ../../secrets/codex-sentry-auth-token.age {
      path = codexSentryAuthTokenPath;
      mode = "0400";
      symlink = false;
    })
    (maybeSecret "me-password" ../../secrets/me-password.age {
      owner = "root";
      group = "root";
    })
  ];

  environment.systemPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.age-plugin-se
  ];
}
