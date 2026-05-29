{
  description = "Polyglot devshell — node, python (uv), go, rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_22
          pnpm

          uv
          python312

          go
          gopls

          (rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "rust-analyzer" ];
          })

          postgresql_16
          redis
        ];

        shellHook = ''
          export DATABASE_URL=postgres://dev:dev@localhost:5432/postgres
          export REDIS_URL=redis://localhost:6379
          export SMTP_HOST=localhost
          export SMTP_PORT=1025
        '';
      };
    };
}
