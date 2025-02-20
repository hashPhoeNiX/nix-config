{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = {
	url = "github:nixos/nixpkgs/release-24.05";
    };
    home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
 	inputs.nixpkgs.follows = "nixpkgs";
    };
    nixCats = {
	url = "github:BirdeeHub/nixCats-nvim";
    }; 
    #hyprland = {
    #    url = "github:hyprwm/Hyprland";
    #	inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixCats, ... }:
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
    };
}
