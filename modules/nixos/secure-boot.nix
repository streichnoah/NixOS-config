# Secure Boot mit Lanzaboote (https://github.com/nix-community/lanzaboote)
#
# Warum: Riot Vanguard (Valorant, LoL) verlangt unter Windows 11 aktives Secure Boot.
# Damit Secure Boot dauerhaft an bleiben kann, muss auch NixOS signiert booten.
#
# Ablauf (Details in docs/INSTALL.md, Teil D):
#   1. sudo sbctl create-keys              -> Schlüssel in /var/lib/sbctl
#   2. my.secureBoot.enable = true; rebuild -> Lanzaboote signiert Bootloader + Kernel
#   3. sudo sbctl verify                   -> prüfen
#   4. BIOS: Secure Boot "Setup Mode"
#   5. sudo sbctl enroll-keys --microsoft  -> eigene + Microsoft-Schlüssel registrieren
#      (Microsoft-Schlüssel sind Pflicht: Windows-Bootloader und das Option-ROM der
#      Grafikkarte sind damit signiert. Ohne sie: Windows bootet nicht/schwarzer Bildschirm.)
{ config, lib, pkgs, ... }:
let
  cfg = config.my.secureBoot;
in
{
  options.my.secureBoot.enable = lib.mkEnableOption "Secure Boot über Lanzaboote";

  config = lib.mkMerge [
    {
      # sbctl immer verfügbar: Schlüssel erzeugen, Status prüfen (`sudo sbctl status`)
      environment.systemPackages = [ pkgs.sbctl ];
    }

    (lib.mkIf cfg.enable {
      # Lanzaboote ersetzt das systemd-boot-Modul
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        # configurationLimit wird von boot.loader.systemd-boot übernommen (15)
      };
    })
  ];
}
