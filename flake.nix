{
  description = "Noahs NixOS-Config (Desktop: nixos-pc)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser ist (noch) nicht in nixpkgs -> Community-Flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "noah";
    in
    {
      nixosConfigurations.nixos-pc = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/nixos-pc

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs username; };
              users.${username} = import ./home/${username};
            };
          }
        ];
      };

      # `nix fmt` formatiert alle .nix-Dateien
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
