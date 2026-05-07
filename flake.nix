# flake.nix (nixos)
{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-cabanashmul = {
      url = "git+ssh://git@github.com/shmul95/my-cabanashmul.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, my-cabanashmul, ... }@inputs:
    let
      username = "shmul95";
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.default
        ];
      };

      homeConfigurations.${username} =
        my-cabanashmul.homeConfigurations."${username}-personal";
    };
}
