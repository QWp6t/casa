{
  description = "me's NixOS and nix-darwin configurations (casa)";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    # Package set. nixos-unstable tracks the latest package versions;
    # switch to `nixos-25.11` for the stable channel if you'd rather trade fresh
    # packages for fewer surprises.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # flake-parts lets us split the flake across multiple files and exposes
    # `perSystem` for per-architecture outputs (dev shells, formatters, checks).
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # macOS system configuration (/etc, launchd, system.defaults, etc.).
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative user environment (dotfiles, shell, editor, CLI tools).
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS module for running inside a WSL distro.
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Runs `nixfmt`, `prettier`, etc. under a single `nix fmt` entry point.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modern whois replacement used by the shell alias.
    quien = {
      url = "github:retlehs/quien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management: age-encrypted files decrypted at activation.
    # See secrets/README.md for the one-time bootstrap.
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
      };
    };

    # Auto-updated packages for AI coding agents (agent-browser, etc.).
    # Tracks upstream releases via numtide's 4x/day update workflow.
    # Deliberately does NOT follow our nixpkgs: building against llm-agents'
    # own pin is what lets cache.numtide.com serve pre-built binaries, so CI
    # (and local rebuilds) don't compile agent-browser/codex from source.
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      nix-darwin,
      home-manager,
      nixos-wsl,
      treefmt-nix,
      quien,
      agenix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        let
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          # `nix fmt` at the repo root.
          formatter = treefmtEval.config.build.wrapper;

          # `nix flake check` runs these. CI uses it to catch formatting regressions.
          checks.formatting = treefmtEval.config.build.check self;

          # `nix develop` — puts a consistent toolchain on PATH.
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.mago
              pkgs.nixd
              treefmtEval.config.build.wrapper
            ];
          };
        };

      flake = {
        # NixOS hosts. Apply with:  sudo nixos-rebuild switch --flake .#wsl
        nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            nixos-wsl.nixosModules.default
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ./systems/wsl
          ];
        };

        # macOS hosts. Apply with:  sudo darwin-rebuild switch --flake .#mac
        darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            agenix.darwinModules.default
            home-manager.darwinModules.home-manager
            ./systems/mac
          ];
        };
      };
    };
}
