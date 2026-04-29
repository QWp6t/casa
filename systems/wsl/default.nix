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
    interop.register = false;
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
      shell = pkgs.zsh;
    };

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

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
    pkgs.git
  ];

  system.stateVersion = "25.11";
}
