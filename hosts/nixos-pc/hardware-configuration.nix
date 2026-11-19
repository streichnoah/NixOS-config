# PLATZHALTER - wird bei der Installation ersetzt!
#
# Im NixOS-Installer erzeugst du die echte Datei mit:
#   sudo nixos-generate-config --root /mnt
# und kopierst /mnt/etc/nixos/hardware-configuration.nix hierher
# (siehe docs/INSTALL.md, Schritt 6).
#
# Die Werte unten sind nur Dummies, damit `nix flake check` schon vorher läuft.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
