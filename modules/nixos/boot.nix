# Bootloader: GRUB (UEFI) mit os-prober, damit Windows automatisch im Menü landet.
# NixOS bekommt eine EIGENE EFI-Partition (/boot, 1 GB), weil die Windows-ESP
# meist nur 100 MB groß ist - zu klein für mehrere NixOS-Generationen.
{ pkgs, ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true; # findet Windows Boot Manager auf der anderen ESP
      configurationLimit = 15; # alte Generationen im Menü begrenzen
      default = "saved"; # merkt sich den zuletzt gebooteten Eintrag
    };
    timeout = 5;
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
