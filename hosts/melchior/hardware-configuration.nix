{ ... }:

# Placeholder — replace this entire file with the output of:
#   sudo nixos-generate-config --show-hardware-config
# Run that on the melchior machine once NixOS is booted from the installer.
{
  boot.loader.grub.devices = [ "/dev/sda" ]; # TODO: update to actual disk
  fileSystems."/" = {
    device = "/dev/sda1"; # TODO: update to actual partition
    fsType = "ext4";
  };
}
