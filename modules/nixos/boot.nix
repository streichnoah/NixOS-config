# Bootloader: systemd-boot auf einer EIGENEN EFI-Partition (/boot, 1 GB).
# Die Windows-ESP ist meist nur 100 MB groß, zu klein für mehrere NixOS-Generationen.
#
# Windows startest du über das Boot-Menü des Mainboards (F8/F11/F12 beim Einschalten).
# systemd-boot erkennt Windows nur auf der eigenen ESP, und ein Chainload über die
# EFI-Shell würde mit Secure Boot nicht funktionieren.
#
# Mit my.secureBoot.enable = true übernimmt Lanzaboote (siehe secure-boot.nix).
{ pkgs, ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 15; # alte Generationen im Menü und auf der ESP begrenzen
      editor = false; # keine Kernel-Parameter-Änderung im Bootmenü (wäre eine Sicherheitslücke)
    };
    # Menü 3 s anzeigen, darin sind ältere Generationen zum Zurückrollen
    timeout = 3;
  };

  # Aktueller Kernel - gut für neue AMD-Hardware (RDNA3)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Windows speichert die Hardware-Uhr in Lokalzeit -> sonst springt die Uhr
  # nach jedem OS-Wechsel um 1-2 Stunden.
  time.hardwareClockInLocalTime = true;

  # NTFS-Partitionen von Windows lesen/schreiben können
  boot.supportedFilesystems = [ "ntfs" ];

  # Komprimierter Swap im RAM statt Swap-Partition
  zramSwap.enable = true;
}
