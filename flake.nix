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
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, ... }@inputs: {
    # Mac configuration
    darwinConfigurations."MacBook-Pro-4" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";  # Intel Mac
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/macbook/configuration.nix
        
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
    
    # Placeholder for future NixOS systems
    # nixosConfigurations.homeserver = ...
  };
}
