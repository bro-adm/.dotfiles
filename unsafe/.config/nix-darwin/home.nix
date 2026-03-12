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

      _omp_redraw-prompt() {
        local precmd
        for precmd in $precmd_functions; do
          "$precmd"
        done

        zle .reset-prompt
      }

      export POSH_VI_MODE="I"

      function zvm_after_select_vi_mode() {
        case $ZVM_MODE in
        $ZVM_MODE_NORMAL)
          POSH_VI_MODE="N"
        ;;
        $ZVM_MODE_INSERT)
          POSH_VI_MODE="I"
        ;;
        $ZVM_MODE_VISUAL)
          POSH_VI_MODE="V"
        ;;
        $ZVM_MODE_VISUAL_LINE)
          POSH_VI_MODE="V-L"
        ;;
        $ZVM_MODE_REPLACE)
          POSH_VI_MODE="R"
        ;;
        esac
        _omp_redraw-prompt
      }

      KEYTIMEOUT=1

      function zvm_after_lazy_keybindings() {
        # A. Register the widget using the plugin's wrapper
        # This replaces 'zle -N kubetoggle'
        zvm_define_widget kubetoggle

        # B. Bind the keys
        # syntax: zvm_bindkey <keymap> <key> <widget>
      
        # Bind for Normal Mode (vicmd)
        zvm_bindkey vicmd "^[[107;6u" kubetoggle

        # Bind for Insert Mode (viins) 
        # (So it works while you are typing too)
        zvm_bindkey viins "^[[107;6u" kubetoggle

        bindkey '^[' vi-cmd-mode
	
	# In Normal Mode: Escape -> Insert Mode
        # zvm_bindkey vicmd '^[' vi-insert
      
        # In Visual Mode: Escape -> Insert Mode (Dropping selection)
        # zvm_bindkey visual '^[' vi-insert
      }

      function zvm_config() {
        ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
      }

      bindkey -M vicmd h undefined-key
      bindkey -M vicmd j undefined-key
      bindkey -M vicmd k undefined-key
      bindkey -M vicmd l undefined-key

      kubetoggle_widget() {
        . kubetoggle
	_omp_redraw-prompt
      }

      zle -N kubetoggle_widget

      bindkey "^[[107;6u" kubetoggle_widget
      # ctrl+shift+k on kkp terminal emulators

      if [[ $(ps -p $PPID -o comm=) != "fish" && -z ''${ZSH_EXECUTION_STRING} && ''${SHLVL} == 1 ]]; then
        if [[ -o login ]]; then
          LOGIN_OPTION='--login'
        else
          LOGIN_OPTION=""
        fi
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    
    '';

    plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
	# "kube-ps1"
      ];
    };

  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        set fish_greeting # Disable greeting
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${config.xdg.configHome}/ohmyposh/config.toml | source

        function _omp_redraw_prompt --on-variable PWD
            # Fish doesn't need a for-loop for precmds; it handles them via events.
            # We call the internal OMP repaint and then the shell repaint.
            if functions -q omp_repaint_prompt
                omp_repaint_prompt
            end
            commandline -f repaint
        end

        # The "Browser MRU Toggle" logic
        function _toggle_last_dir
          # cd - is the fastest way to swap between the two most recent
          cd - 
          # Trigger your OMP redraw function we created earlier
          if functions -q _omp_redraw_prompt
              _omp_redraw_prompt
          end
        end

        # Bind Ctrl+Tab (Check fish_key_reader if this code differs for you)
        # Standard for many KKP terminals is \e[1;5I
        bind ctrl-tab _toggle_last_dir

        # 3. Your Keybinds
        bind ctrl-shift-']' nextd
        bind ctrl-shift-'[' prevd

        source ${pkgs.fishPlugins.forgit}/share/fish/vendor_conf.d/forgit.plugin.fish
    '';
    plugins = [
    {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
    }
    ];
    shellAbbrs = {
	jime = "jira issue list -a$(jira me)";
	jistat = ''jira issue list -q "project='RHAISTRAT' AND component in ('Model as a Service')"'';
    };
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # programs.direnv = {
  #   enable = true;
  #   enableZshIntegration = true; # see note on other shells below
  #   # enableFishIntegration = true;
  #   nix-direnv.enable = true;
  # };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    globalConfig = {
    #   plugins = {
    #     nix = "https://github.com/jbadeau/mise-nix.git";
    #   };
      settings = {
        experimental = true;
      };
    };
    # settings = {
    #   experimental = true;
    # };
  };

  programs.atuin = {
    enable = true;
    # flags = [ "--disable-up-arrow" ];
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
    pkgs.yq
    pkgs.lsd # file tree view
    pkgs.broot # file tree operations + preview
    pkgs.fzf # fuzzy find
    pkgs.ripgrep # grep replacment
    pkgs.fd # find replacement
    pkgs.bat # cat replacment
    pkgs.zoxide # smart cd + fzf
    pkgs.sad # replace + fzf + picker
    
    pkgs.difftastic # smart diff - code based instead of line based - fuck delta
    pkgs.diff-so-fancy # diff pager
    pkgs.watchexec
    pkgs.lazygit
    pkgs.graphite-cli
    
    pkgs.devbox
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
    pkgs.kubectx # fzf cluster + namespace picker
    pkgs.krew
    pkgs.k9s

    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-diff
        helm-secrets
        helm-s3
      ];
    })
    pkgs.helmfile

    pkgs.jira-cli-go
    pkgs.neomutt
    pkgs.gh
    pkgs.gh-dash

    pkgs.azure-cli

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

    MAKEFILES="$(echo ~/.dotfiles/scripts/makefiles/*.mk)";
    ZDOTDIR = "${config.home.homeDirectory}/.config/zsh";
    
    FZF_DEFAULT_COMMAND="fd --type f --follow";
    FZF_DEFAULT_OPTS="--tmux";
    _ZO_FZF_OPTS="--tmux";

    FORGIT_FZF_DEFAULT_OPTS="--height 100% --layout reverse --border=none";
    FORGIT_LOG_FZF_OPTS="--preview 'git difftool --no-prompt --ext-diff {}^!'";
    FORGIT_DIFF_TOOL="difft --color always";

    EDITOR = "nvim";

    ZVM_SYSTEM_CLIPBOARD_ENABLED="true";

    # KUBE_PS1_BINARY="oc";


  };

  home.shellAliases = {
    p = "podman";
    kc = "kubectx";
    kp = "kubens";
    kcl = "kubectl config-cleanup --clusters --users --raw > ~/.kube/config.clean && mv ~/.kube/config.clean ~/.kube/config";
  };

  home.sessionPath = [ "$HOME/bin" "$HOME/.krew/bin" ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
