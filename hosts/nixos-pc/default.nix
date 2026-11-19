# Host-spezifische Konfiguration für den Desktop-PC (Dual Boot mit Windows)
{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/boot.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/amd-gpu.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/packages.nix
  ];

  networking.hostName = "nixos-pc";

  # NICHT ändern, nachdem das System installiert ist!
  # Muss zur Version des Installations-ISOs passen (siehe docs/INSTALL.md).
  system.stateVersion = "26.05";
}
