{ pkgs, ... }:

# Nix compilers, for hosts without a system toolchain (casper, melchior).
# Not imported on balthasar: Nix's gcc wrapper links against Nix's glibc, and
# when a build also picks up libs from Arch's /usr/lib the binary ends up with
# Nix's ld.so loading Arch's libc.so.6 (symbol lookup errors at startup).
# balthasar uses Arch's gcc + rustup instead.
{
  home.packages = with pkgs; [
    gcc
    cmake
    ninja
    rustc
    cargo
  ];
}
