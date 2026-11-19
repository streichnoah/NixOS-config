# LUKS-Verschlüsselung mit automatischem Entsperren über den TPM-Chip.
#
# Ergebnis: kein Passwort beim Booten. Du loggst dich nur mit deinem User-Passwort ein.
# Die SSD bleibt trotzdem verschlüsselt: Der TPM gibt den Schlüssel nur heraus, wenn
# der Bootvorgang unverändert ist (PCR 7 = Secure-Boot-Zustand). Ausgebaute SSD,
# fremder Live-Stick oder abgeschaltetes Secure Boot -> Abfrage des LUKS-Passworts.
#
# Das LUKS-Passwort aus der Installation bleibt als Notfall-Schlüssel erhalten.
# Einrichtung nach Teil D (Secure Boot) - siehe docs/INSTALL.md, Schritt D6:
#   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p6
{ pkgs, ... }:
{
  # Die initrd nutzt in aktuellem NixOS immer systemd (systemd-cryptsetup),
  # das kann TPM2 von Haus aus, dafür ist keine Extra-Option nötig.

  # Name muss zum Eintrag in hardware-configuration.nix passen ("cryptroot",
  # weil wir die Partition bei der Installation als cryptroot geöffnet haben).
  # Ohne eingerichteten TPM-Schlüssel fragt der Boot einfach nach dem Passwort.
  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];

  # TPM-Werkzeuge und Zugriff für Diagnose (`systemd-analyze has-tpm2`)
  security.tpm2.enable = true;
  environment.systemPackages = [ pkgs.tpm2-tools ];
}
