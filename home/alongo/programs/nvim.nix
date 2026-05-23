{ config, ... }:

{
  # Live-edit symlink: edit files in ~/.config/nix-config/nvim/ directly,
  # no rebuild needed for changes to take effect.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/nix-config/nvim";
}
