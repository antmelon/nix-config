{
  description = "Ant's multi-machine NixOS and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DM Assistant — static SPA served on melchior over the tailnet.
    # TODO: point at the default branch once the refactor PR merges.
    dm-assistant = {
      url = "github:antmelon/dm-assistant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hermes Agent — personal agent service on melchior. Not following our
    # nixpkgs: its Python lock pins an interpreter family that our unstable
    # may not match. Bump deliberately (`nix flake update hermes-agent`);
    # upstream treats Nix as best-effort and main can break.
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, neovim-nightly-overlay, foundryvtt, ... }@inputs:
  let
    overlays = [
      neovim-nightly-overlay.overlays.default
      # The nightly neovim's functional test suite currently fails to build
      # under nixpkgs 26.11 (missing make target functionaltest__treesitter).
      # We only install the binary and manage nvim config outside Nix, so skip
      # the test phase. The nightly overlay binds `neovim` directly to the
      # nightly derivation (not a wrapper over `neovim-unwrapped`), so both
      # attrs must be patched. Drop once the nightly checkPhase builds again.
      (final: prev: {
        neovim = prev.neovim.overrideAttrs (_: { doCheck = false; });
        neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (_: { doCheck = false; });
      })
    ];
  in {

    # casper — MacBook Pro (M1, nix-darwin)
    darwinConfigurations."casper" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }
        ./hosts/casper/configuration.nix
        ./modules/common.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs   = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.alongo = { imports = [ ./home/alongo/base.nix ./home/alongo/dev-toolchain.nix ./home/alongo/darwin.nix ./home/alongo/programs/syncthing.nix ]; };
          };
        }
      ];
    };

    # melchior — home server (NixOS)
    nixosConfigurations."melchior" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }
        ./hosts/melchior/configuration.nix
        sops-nix.nixosModules.sops
        foundryvtt.nixosModules.foundryvtt
        inputs.hermes-agent.nixosModules.default
      ];
    };

    # balthasar — Arch desktop (home-manager only)
    homeConfigurations."balthasar" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system   = "x86_64-linux";
        overlays = overlays;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./hosts/balthasar/configuration.nix ];
    };

  };
}
