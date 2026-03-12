{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      nix = {
        enable = true;
        settings.experimental-features = [ "nix-command" "flakes" ];
      };
      
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.neovim
          pkgs.neovim-remote
          pkgs.git
          pkgs.jujutsu
          pkgs.stow
          pkgs.htop
          pkgs.nix-tree
          pkgs.mise

          pkgs.wezterm
          pkgs.aerospace
          pkgs.slack
          pkgs.raycast

          pkgs.claude-code
          pkgs.google-cloud-sdk
          pkgs.awscli2
          pkgs.rosa
          
	  # pkgs.whatsapp-for-mac
          # pkgs.karabiner-elements
        ];


      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      
      security.pam.services.sudo_local.touchIdAuth = true;

      environment.shells = [
      	pkgs.fish
      ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#lbondy-mac
    darwinConfigurations."lbondy-mac" = nix-darwin.lib.darwinSystem {
      modules = [ 
	configuration
        home-manager.darwinModules.home-manager
  	{
    	  home-manager.useGlobalPkgs = true;
    	  home-manager.useUserPackages = true;
    	  home-manager.users.lbondy = import ./home.nix;
	  users.users.lbondy.home = "/Users/lbondy";
  	}
      ];
    };
  };
}
