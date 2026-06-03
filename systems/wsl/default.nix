{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  hasPassword = builtins.pathExists ../../secrets/me-password.age;
  npiperelay = "/mnt/d/Tech/bin/npiperelay.exe";
in
{
  imports = [
    ../../modules/common
    ../../modules/nixos
    ../../modules/agenix
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
          isWsl = true;
        };
        users.me =
          { ... }:
          {
            imports = [ ../../users/me ];
            systemd.user.enable = false;
          };
      };
    }
  ];

  wsl = {
    enable = true;
    defaultUser = "me";
    interop.register = true;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = hasPassword;
  };
  services.resolved.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "wsl";

  users.users.me =
    lib.optionalAttrs hasPassword {
      hashedPasswordFile = config.age.secrets.me-password.path;
    }
    // {
      # Native WSL systemd does not reliably start per-user managers for shell
      # logins. Keep the user bus available so nixos-rebuild can reload user
      # units without noisy D-Bus activation failures.
      linger = true;
      shell = pkgs.zsh;
    };
  users.users.root.linger = true;

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

  # Codex Desktop's Windows/WSL launcher currently expects this FHS path.
  # NixOS does not expose it by default, so provide a narrow compatibility shim.
  systemd.tmpfiles.rules = [
    "d /usr 0755 root root - -"
    "d /usr/bin 0755 root root - -"
    "L+ /usr/bin/bash - - - - ${pkgs.bashInteractive}/bin/bash"
    "L+ /usr/bin/google-chrome - - - - ${pkgs.google-chrome}/bin/google-chrome"
    "L+ /usr/bin/google-chrome-stable - - - - ${pkgs.google-chrome}/bin/google-chrome-stable"
  ];

  systemd.services.win-ssh-agent-bridge = {
    description = "Bridge WSL SSH_AUTH_SOCK to Windows OpenSSH agent (via npiperelay)";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    unitConfig.ConditionPathExists = npiperelay;
    serviceConfig = {
      Type = "simple";
      User = "me";
      Group = "users";
      Environment = "SSH_AUTH_SOCK=/home/me/.ssh/agent.sock";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/me/.ssh";
      ExecStart = ''${pkgs.socat}/bin/socat UNIX-LISTEN:/home/me/.ssh/agent.sock,fork,unlink-early,mode=0600,user=me,group=users EXEC:"${npiperelay} -ei -s //./pipe/openssh-ssh-agent",nofork'';
      Restart = "always";
      RestartSec = 5;
    };
  };

  environment.systemPackages = [
    pkgs.bubblewrap
    pkgs.git
  ];

  system.stateVersion = "25.11";
}
