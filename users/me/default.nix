{
  config,
  pkgs,
  lib,
  inputs,
  isWsl ? false,
  ...
}:
let
  home = if pkgs.stdenv.isDarwin then "/Users/me" else "/home/me";
  claudeRoutingPath = "${home}/.local/share/agenix/claude-routing";
  gitLocalIncludePath = "${home}/.local/share/agenix/git-local-include";
  workAwsConfigPath = "${home}/.local/share/agenix/work-aws-config";
  workShellPath = "${home}/.local/share/agenix/work-shell";
  ssh-agent-op = pkgs.callPackage ./pkgs/ssh-agent-op { };
  quienPkg =
    let
      systemPackages = inputs.quien.packages.${pkgs.system};
    in
    if systemPackages ? default then systemPackages.default else systemPackages.quien;
in
{
  home.username = "me";
  home.homeDirectory = home;

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages =
    with pkgs;
    [
      vim
      oh-my-posh

      age

      bat
      dust
      eza
      fd
      fastfetch
      fzf
      gnumake
      jq
      just
      procs
      ripgrep
      wget
      xh
      zoxide

      claude-code
      codex
      gh
      ssh-agent-op

      awscli2
      awsume
      k9s
      kubectl
      quienPkg
    ]
    ++ lib.optionals isWsl [
      socat
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      _1password-cli
      _1password-gui
    ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlXrFja84HF+oaGnOBHwzgSow73owPreIwijwvuQjcr";
      signByDefault = true;
    }

    // lib.optionalAttrs isWsl {
      signer = "${config.home.homeDirectory}/.local/bin/op-ssh-sign-wsl";
    }

    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      signer = "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    includes = [
      { path = "~/.gitconfig.autossh"; }
      { path = "~/.gitconfig.local"; }
    ];

    settings = {
      user = {
        name = "QWp6t";
        email = "2104321+QWp6t@users.noreply.github.com";
      };

      core = {
        editor = "vim";
        excludesFile = "~/.gitignore";
      };

      init.defaultBranch = "main";
      pull.ff = "only";
      color.diff.whitespace = "red reverse";

      alias = {
        unstage = "reset HEAD --";
        purge = "!git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done";
        last = "log -1 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit HEAD";
        nah = "!git reset --hard;git clean -df";
        wip = "!git commit -m 'wip'";
        wipa = "!git add --all; git commit -m 'wip'";
        poke = "!git commit --allow-empty --allow-empty-message -m ''";
      };

      credential."https://github.com".helper = [
        ""
        "!gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        ""
        "!gh auth git-credential"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    enableCompletion = false;

    initContent = ''
      zmodload zsh/zprof
      bindkey -e

      if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh)
      fi

      # Source conf.d/*.zsh in alphabetical order.
      if [ -d "$ZDOTDIR/conf.d" ]; then
        for conf in "$ZDOTDIR"/conf.d/*.zsh; do
          [ -f "$conf" ] && source "$conf"
        done
        unset conf
      fi

      # ^X^E: edit current command line in $EDITOR.
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # compinit with once-a-day check (matches prior behavior).
      autoload -Uz compinit
      if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi
    '';
  };

  home.activation.linkWinhome = lib.mkIf isWsl (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Best-effort: NEVER fail the activation. Run wslpath unconditionally —
      # if cmd.exe returned junk, wslpath errors and we skip. The `-d` check
      # ensures the resolved path is an actual existing directory.
      win_userprofile=$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r') || true
      target=$(/sbin/wslpath -u "$win_userprofile" 2>/dev/null) || true

      if [ -z "$target" ] || [ ! -d "$target" ]; then
        echo "winhome: could not resolve %USERPROFILE% (got: '$win_userprofile' → '$target'); skipping ~/winhome link" >&2
      else
        link="$HOME/winhome"

        if [ -L "$link" ]; then
          current=$(readlink -- "$link")
          if [ "$current" != "$target" ]; then
            $DRY_RUN_CMD rm -- "$link"
            $DRY_RUN_CMD ln -s -- "$target" "$link"
          fi
        elif [ -e "$link" ]; then
          echo "winhome: $link exists but is not a symlink; refusing to overwrite" >&2
        else
          $DRY_RUN_CMD ln -s -- "$target" "$link"
        fi
      fi
    ''
  );

  xdg.configFile = {
    "ripgrep".text = "";
    "zsh/conf.d/01-env.zsh".source = ./zsh/conf.d/01-env.zsh;
    "zsh/conf.d/03-options.zsh".source = ./zsh/conf.d/03-options.zsh;
    "zsh/conf.d/04-ssh.zsh".source = ./zsh/conf.d/04-ssh.zsh;
    "zsh/conf.d/05-history.zsh".source = ./zsh/conf.d/05-history.zsh;
    "zsh/conf.d/10-completions.zsh".source = ./zsh/conf.d/10-completions.zsh;
    "zsh/conf.d/awsume.zsh".source = ./zsh/conf.d/awsume.zsh;
    "zsh/conf.d/composer.zsh".source = ./zsh/conf.d/composer.zsh;
    "zsh/conf.d/fly.zsh".source = ./zsh/conf.d/fly.zsh;
    "zsh/conf.d/git.zsh".source = ./zsh/conf.d/git.zsh;
    "zsh/conf.d/zoxide.zsh".source = ./zsh/conf.d/zoxide.zsh;

    "zsh/conf.d/99-aliases.zsh".text = lib.concatStringsSep "\n\n" (
      [ (builtins.readFile ./zsh/aliases/common.zsh) ]
      ++ lib.optional pkgs.stdenv.isDarwin (builtins.readFile ./zsh/aliases/darwin.zsh)
      ++ lib.optional isWsl (builtins.readFile ./zsh/aliases/wsl.zsh)
    );
  }
  // lib.optionalAttrs isWsl {
    "zsh/conf.d/02-omp.zsh".source = ./zsh/conf.d/02-omp.zsh;
  }
  // lib.optionalAttrs (!builtins.pathExists ../../secrets/claude-routing.age) {
    "zsh/conf.d/claude.zsh".source = ./zsh/conf.d/claude.zsh;
  }
  // lib.optionalAttrs (builtins.pathExists ../../secrets/work-shell.age) {
    "zsh/conf.d/99-work.zsh".source = config.lib.file.mkOutOfStoreSymlink workShellPath;
  }
  // lib.optionalAttrs (builtins.pathExists ../../secrets/claude-routing.age) {
    "zsh/conf.d/claude.zsh".source = config.lib.file.mkOutOfStoreSymlink claudeRoutingPath;
  };

  home.file =
    lib.optionalAttrs (builtins.pathExists ../../secrets/work-aws-config.age) {
      ".aws/config".source = config.lib.file.mkOutOfStoreSymlink workAwsConfigPath;
    }
    // lib.optionalAttrs (builtins.pathExists ../../secrets/git-local-include.age) {
      ".gitconfig.local".source = config.lib.file.mkOutOfStoreSymlink gitLocalIncludePath;
    }
    // lib.optionalAttrs isWsl {
      ".local/bin/op" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          exec op.exe "$@"
        '';
      };

      ".local/bin/op-ssh-sign-wsl" = {
        executable = true;
        source = ./bin/op-ssh-sign-wsl;
      };
    };
}
