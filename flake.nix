{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = {
      #url = "github:nixos/nixpkgs/release-24.05";
      url = "github:NixOS/nixpkgs/nixos-unstable";
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

    #hyprland = {
    #    url = "github:hyprwm/Hyprland";
    #	inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixCats, nix-on-droid, ... }:
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
      		    #./home/nixcats.nix
		          #./home/nixcats-home.nix
		          #nixCats.nixosModules.default
                  #nixCats.homeModule.default
	          ];
          #nixCats.homeModule.default = import ./home/nixcats.nix;

	        };
	      };
        nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
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
}
