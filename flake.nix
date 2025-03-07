{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = {
      #url = "github:nixos/nixpkgs/release-24.05";
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    home-manager = {
        #url = "github:nix-community/home-manager/release-24.05";
        url = "github:nix-community/home-manager";
 	      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixCats = {
	    url = "github:BirdeeHub/nixCats-nvim";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    hyprland = {
        url = "github:hyprwm/Hyprland";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixCats, nix-on-droid, nix-darwin, nix-homebrew, homebrew-core, homebrew-bundle, homebrew-cask, ... }:
     let
        system = "aarch64-linux";
        pkgs = import nixpkgs {
           inherit system;
           config.allowUnfree = true;
        };
        lib = nixpkgs.lib;
     in {
        nixosConfigurations = {
	        pelumi = lib.nixosSystem {
	          inherit system;
            specialArgs = { inherit lib inputs; };
	          modules = [ 
		          ./nixos/configuration.nix
	          ];
	        };
          test = lib.nixosSystem {
	          inherit system;
            specialArgs = { inherit lib inputs; };
	          modules = [ 
		          ./nixos/configuration.nix
		          home-manager.nixosModules.home-manager 
		          {
                home-manager = {
		              useGlobalPkgs = true;
                  useUserPackages = true;
		              #users.test = import ./home/home.nix;
		              users.test = {
		                 imports = [ 
			                 (import ./home/home.nix) 
			              ];
		              };
		                # Optionally, use home-manager.extraSpecialArgs to pass
                                # arguments to home.nix
                  extraSpecialArgs = {
                    inherit inputs;
                  };
		             };
		          }
	          ];
          #nixCats.homeModule.default = import ./home/nixcats.nix;

	        };
	      };
        darwinConfiguration."phoenix-mac" = nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./nix-darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.phoenix-mac = {
                  imports = [ 
                    (import ./home/home.nix)
                  ];
                };
                
                extraSpecialArgs = {
                  inherit inputs;
                };
              }; 
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = "oluwapelumiadeosun";

                # Optional: Declarative tap management
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };

                # Optional: Enable fully-declarative tap management
                #
                # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                mutableTaps = false;
              };
            }
          ];
        };
        nixOnDroidConfigurations = {
          default = nix-on-droid.lib.nixOnDroidConfiguration {
            modules = [
              ./nix-on-droid/nix-on-droid.nix

              # list of extra modules for Nix-on-Droid system
              { nix.registry.nixpkgs.flake = nixpkgs; }
              # ./path/to/module.nix

              # or import source out-of-tree modules like:
              # flake.nixOnDroidModules.module
            ];

            # list of extra special args for Nix-on-Droid modules
            extraSpecialArgs = {
              inherit inputs;
              # rootPath = ./.;
            };

            # set nixpkgs instance, it is recommended to apply `nix-on-droid.overlays.default`
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              #system.defaultShell = pkgs.fish;
              overlays = [
                nix-on-droid.overlays.default
                # add other overlays
              ];
            };

            # set path to home-manager flake
            home-manager-path = home-manager.outPath;
        };
      };
    };
}
