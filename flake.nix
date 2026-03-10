# flake.nix (nixos)
{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tshmux = {
      url = "github:shmul95/tshmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    shmulvim.url = "github:shmul95/shmulvim";
    zshmul.url = "github:shmul95/zshmul";

    shmulistan = {
      url = "git+ssh://git@github.com/shmul95/shmulistan.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.default
          {
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };
    };
}
