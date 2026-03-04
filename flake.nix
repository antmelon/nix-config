{
  description = "Ant's multi-machine NixOS and nix-darwin configurations";

  inputs = {
    # Use stable nixpkgs for Darwin
   # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix for secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, neovim-nightly-overlay, ... }@inputs: {
    # Mac configuration (Casper)
    darwinConfigurations."casper" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";  # Intel Mac
      specialArgs = { inherit inputs; };
      modules = [

        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];
        })
        ./hosts/casper/configuration.nix
        ./modules/common.nix

        # Home Manager integration (we'll set this up next)
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.alongo = import ./home/alongo;
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ];
    };

    # Future systems
    # Melchior - Home Server
    # nixosConfigurations.melchior = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   specialArgs = { inherit inputs; };
    #   modules = [
    #     ./hosts/melchior/configuration.nix
    #     ./modules/common.nix
    #     sops-nix.nixosModules.sops
    #     home-manager.nixosModules.home-manager
    #     {
    #       home-manager = {
    #         useGlobalPkgs = true;
    #         useUserPackages = true;
    #         users.ant = import ./home/alongo;
    #       };
    #     }
    #   ];
    # };

    # Balthasar - Desktop
    # nixosConfigurations.balthasar = ...
    homeConfigurations."balthasar" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ neovim-nightly-overlay.overlays.default ];  # Add overlay here
        };
  
        extraSpecialArgs = { inherit inputs; };  # Pass inputs through
  
        modules = [
            ./hosts/balthasar/configuration.nix
        ];
    };

  };
}
