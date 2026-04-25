{ inputs, pkgs, ... }:
{
  imports = [
    ../../modules/common
    ../../modules/darwin
    ../../modules/agenix
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
          isWsl = false;
        };
        users.me = import ../../users/me;
      };
    }
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "mac";

  users.users.me.home = "/Users/me";

  programs.zsh.enable = true;

  environment.systemPackages = [
    pkgs.git
  ];

  system.stateVersion = 6;
}
