{ ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
      "@admin"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
