{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  home.username = "lbondy";
  home.homeDirectory = "/Users/lbondy";
  xdg.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = "/Users/lbondy/.config/zsh";

    history = {
      # Set the history file path to follow the XDG standard
      path = "${config.xdg.dataHome}/zsh/history";
      # Other history options
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
    };

    envExtra = ''
      export NOSYSZSHRC=1
      export ZSH_COMPDUMP="${config.xdg.cacheHome}/zsh/.zcompcache"
    '';

    enableCompletion = false;

    initContent = ''
      # mkdir -p "$(dirname "$ZSH_COMPDUMP")"
      mkdir -p /Users/lbondy/.cache/zsh
      # autoload -U compinit && compinit -d "/Users/lbondy/.cache/zsh/.zcompdump"
      autoload -U compinit && compinit -d "$ZSH_COMPDUMP"

      # PROMPT='$(kube_ps1)'$PROMPT # or RPROMPT='$(kube_ps1)'

      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.xdg.configHome}/ohmyposh/config.toml)"

      kubetoggle() {
        if [[ -n "$SHOW_KUBE_PROMPT" ]]; then
          unset SHOW_KUBE_PROMPT
        else
          export SHOW_KUBE_PROMPT=true
        fi

	local precmd
        for precmd in $precmd_functions; do
          $precmd
        done

	zle .reset-prompt
      }

      zle -N kubetoggle

      bindkey "^[[107;6u" kubetoggle
      # ctrl+shift+k on kkp terminal emulators

      kcl() {
	kubectl config-cleanup --clusters --users --raw > ~/.kube/config.clean && mv ~/.kube/config.clean ~/.kube/config
      }

    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
	# "kube-ps1"
      ];
    };

  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };




  # programs.zsh.enable = true;
  # programs.zsh.dotDir = "/Users/lbondy/.config/zsh";
  # programs.zsh.history = {
    # Set the history file path to follow the XDG standard
    # path = "${config.xdg.dataHome}/zsh/history";
    # Other history options
    # size = 10000;
    # save = 10000;
    # share = true;
    # ignoreDups = true;
  # };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    pkgs.gnumake
    pkgs.lsd
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fd
    pkgs.zoxide
    pkgs.tmux

    pkgs.ghostty-bin
    pkgs.kitty
    pkgs.deno
    pkgs.zbar

    pkgs.podman
    pkgs.podman-tui
    pkgs.skopeo

    pkgs.openshift
    pkgs.kubectl
    pkgs.kubevirt
    pkgs.kubectx
    pkgs.krew

    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-diff
        helm-secrets
        helm-s3
      ];
    })
    pkgs.helmfile

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # ".config:/zsh/zshenv".source = ./zsh/zshenv;
    # ".config/zsh/zshrc".source = ./zsh/zshrc;
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/davish/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    ZDOTDIR = "${config.home.homeDirectory}/.config/zsh";
    
    FZF_DEFAULT_COMMAND="fd --type f --hidden --follow";
    FZF_DEFAULT_OPTS="--tmux";
    _ZO_FZF_OPTS="--tmux";

    # KUBE_PS1_BINARY="oc";

    GOOGLE_CLOUD_PROJECT="itpc-gcp-ai-eng-claude";
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    p = "podman";
    kc = "kubectx";
    kp = "kubens";
  };

  home.sessionPath = [ "$HOME/bin" "$HOME/.krew/bin" ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
