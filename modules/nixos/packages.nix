# Systemweite Basis-Tools. Persönliche Programme stehen in home/noah/.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    unzip
    pciutils
    usbutils
    htop
  ];
}
