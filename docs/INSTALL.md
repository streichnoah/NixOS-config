# Installation: NixOS neben Windows (gleiche 2-TB-SSD)

Geschätzte Dauer: 1–2 Stunden (+ 20 min für Secure Boot). Lies die Anleitung einmal komplett, bevor du loslegst.

**Überblick:** Windows vorbereiten (A) → NixOS mit **vorübergehend ausgeschaltetem** Secure Boot
installieren (B, C) → Secure Boot mit eigenen Schlüsseln für NixOS **wieder einschalten** und
die SSD per TPM automatisch entsperren lassen (D).
Riot-Spiele (Vanguard) laufen erst wieder, wenn Teil D erledigt ist. Bis D6 fragt NixOS beim
Booten nach dem LUKS-Passwort, danach nicht mehr.

---

## Teil A: Vorbereitung unter Windows

### A1. Backup
Sichere wichtige Daten extern. Beim Partitionieren kann ein Tippfehler Windows löschen.

### A2. BitLocker prüfen (wichtig!)
PowerShell **als Administrator**:
```powershell
manage-bde -status C:
```
- Steht dort **Protection On / Schutz aktiviert**: Recovery-Key sichern unter
  https://aka.ms/myrecoverykey (Microsoft-Konto) **oder** mit
  `manage-bde -protectors -get C:` abschreiben/fotografieren.
  Windows fragt sehr wahrscheinlich nach diesem Key, sobald du Secure Boot ausschaltest bzw. in
  Teil D neue Schlüssel registrierst.
- Optional, aber am stressfreisten: `manage-bde -off C:` (entschlüsselt, dauert eine Weile).

### A3. Secure-Boot-Status nachsehen
`Win + R` → `msinfo32` → **Sicherer Startzustand / Secure Boot State**.
Das NixOS-Installationsmedium ist nicht signiert, also muss Secure Boot **während der Installation**
aus sein. In Teil D schalten wir es mit *Lanzaboote* dauerhaft wieder ein (für Riot Vanguard nötig).

Schau dir bei der Gelegenheit im BIOS an, wo die Secure-Boot-Optionen liegen (meist unter
*Boot → Secure Boot* oder *Security*), und ob es **Key Management / Setup Mode / Clear Secure Boot Keys**
gibt. Die brauchst du in Teil D.

### A4. Schnellstart deaktivieren
Sonst bleibt die Windows-Partition „halb gemountet“ und der Bootloader kann zicken.
```powershell
powercfg /h off
```

### A5. Platz für NixOS schaffen
`Win + X` → **Datenträgerverwaltung** → Rechtsklick auf `C:` → **Volume verkleinern**.
Empfehlung: **500–800 GB** (Eingabe in MB, z. B. `614400` für 600 GB).
Den Bereich als **Nicht zugeordnet** lassen. Keine Partition anlegen!

> Klappt das Verkleinern nicht weit genug, liegen unverschiebbare Dateien am Ende. Dann vorübergehend
> Ruhezustand (A4), Auslagerungsdatei und Systemwiederherstellung abschalten.

### A6. USB-Stick erstellen
1. ISO laden: https://nixos.org/download → **NixOS** → *Graphical ISO image* (64-bit Intel/AMD),
   aktuelle stabile Version (z. B. 26.05). Der grafische Installer bietet einen Browser, damit du
   diese Anleitung offen haben kannst.
2. Mit **Rufus** (im **DD-Modus**, wenn gefragt) oder **Ventoy** auf einen USB-Stick schreiben.

> **Notiere die NixOS-Version des ISOs.** Steht sie nicht auf `26.05`, passe `system.stateVersion`
> in `hosts/nixos-pc/default.nix` und `home.stateVersion` in `home/noah/default.nix` an (Schritt B6).

### A7. BIOS/UEFI
Neustart → BIOS (meist `Entf` oder `F2`):
- **Secure Boot: Disabled**
- vom USB-Stick booten (Boot-Menü meist `F8`/`F11`/`F12`), den **UEFI**-Eintrag des Sticks wählen

---

## Teil B: Installation im Live-System

Im Live-System ein Terminal (Konsole) öffnen. Den grafischen Installer (Calamares) **nicht** benutzen,
wir installieren direkt aus diesem Repo.

### B1. Root-Shell, Tastatur, Internet
```bash
sudo -i
loadkeys de            # nur nötig, wenn du in einer reinen TTY bist
ping -c 2 nixos.org    # LAN geht sofort; WLAN über das Netzwerk-Icon oben rechts bzw. `nmtui`
```

### B2. SSD und freien Bereich finden
```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL
```
Die 2-TB-SSD ist vermutlich `/dev/nvme0n1`. Du siehst die Windows-Partitionen
(eine ~100 MB `vfat` = Windows-EFI, eine große `ntfs` = C:, eine kleine Recovery).

> **Ab hier ganz genau auf die Gerätenamen achten!** Im Folgenden sind `DISK`, `BOOT` und `ROOT`
> Platzhalter. Ersetze sie durch deine echten Namen.

### B3. Zwei neue Partitionen im freien Bereich anlegen
```bash
cfdisk /dev/nvme0n1
```
1. Pfeiltasten auf **Free space** → **New** → `1G` → **Type** → `EFI System`
2. Wieder **Free space** → **New** → Enter (Rest) → Type `Linux filesystem`
3. **Write** → `yes` eintippen → **Quit**

**Vorhandene Partitionen nicht anfassen!** Danach nochmal `lsblk`, um die neuen Namen zu sehen,
z. B. `nvme0n1p5` (1G = BOOT) und `nvme0n1p6` (Rest = ROOT).

### B4. Formatieren und verschlüsseln
```bash
BOOT=/dev/nvme0n1p5     # <- ANPASSEN
ROOT=/dev/nvme0n1p6     # <- ANPASSEN

mkfs.fat -F 32 -n NIXBOOT $BOOT

cryptsetup luksFormat --label NIXCRYPT $ROOT    # YES groß schreiben, dann Passwort setzen
cryptsetup open $ROOT cryptroot
mkfs.ext4 -L nixos /dev/mapper/cryptroot
```
> Das LUKS-Passwort ist dein **Notfall-Schlüssel**. Nach Schritt D6 entsperrt der TPM-Chip die SSD
> automatisch, bis dahin (und wenn z. B. Secure Boot aus ist) fragt NixOS beim Booten danach.
> Im Passwort-Manager speichern! Die Tastatur beim Booten ist **deutsch** eingestellt. Prüfe,
> dass das Live-System beim Eintippen auch deutsch ist, sonst passt das Passwort später nicht.

### B5. Mounten
```bash
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount -o umask=077 $BOOT /mnt/boot
```

### B6. Hardware-Config erzeugen und Repo holen
```bash
nixos-generate-config --root /mnt

nix-shell -p git
mkdir -p /mnt/home/noah
git clone https://github.com/streichnoah/NixOS-config /mnt/home/noah/NixOS-config
cd /mnt/home/noah/NixOS-config

cp /mnt/etc/nixos/hardware-configuration.nix hosts/nixos-pc/hardware-configuration.nix
git add -A    # wichtig: Flakes sehen nur Dateien, die git kennt!
```
Kurz prüfen, dass die generierte Datei einen `boot.initrd.luks.devices."cryptroot"`-Eintrag
und `fileSystems."/boot"` enthält:
```bash
grep -E 'luks|fileSystems' hosts/nixos-pc/hardware-configuration.nix
```
Bei Bedarf jetzt die stateVersion anpassen (siehe A6): `nano hosts/nixos-pc/default.nix`

### B7. Installieren
```bash
nixos-install --flake .#nixos-pc
```
Das lädt alles herunter und baut das System (10–30 min). Am Ende wirst du nach dem
**root-Passwort** gefragt. Danach das Passwort für deinen User setzen:
```bash
nixos-enter --root /mnt -c 'passwd noah'
```

### B8. Neustart
```bash
reboot
```
USB-Stick abziehen. Falls direkt Windows startet: im BIOS die Boot-Reihenfolge ändern, sodass
**Linux Boot Manager** (systemd-boot) an erster Stelle steht und **Windows Boot Manager** dahinter.

> **Windows starten:** beim Einschalten die Boot-Menü-Taste des Mainboards drücken
> (meist `F8` bei ASUS, `F11` bei MSI/ASRock, `F12` bei Gigabyte) → **Windows Boot Manager**.
> NixOS ist der Standard, wenn du nichts drückst.

---

## Teil C: Erster Start

1. systemd-boot-Menü → **NixOS** → LUKS-Passwort (nur bis D6) → Login in **tuigreet** als `noah` → Hyprland startet.
2. `SUPER + Enter` öffnet ein Terminal.

### C1. Repo übernehmen
Das Repo wurde als root geklont, also gehört es dir noch nicht:
```bash
sudo chown -R noah:users ~/NixOS-config
cd ~/NixOS-config
rebuild
```

### C2. Git & GitHub einrichten
```bash
ssh-keygen -t ed25519 -C "noah@nixos-pc"   # Passphrase setzen!
gh auth login                              # GitHub.com → SSH → den neuen Key hochladen
git remote set-url origin git@github.com:streichnoah/NixOS-config.git
```
E-Mail in `home/noah/git.nix` eintragen, dann:
```bash
rebuild
git add -A && git commit -m "nixos-pc: hardware-configuration + git email" && git push
```

### C3. Server per SSH
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub <user>@<server-ip>
```
Dann in `home/noah/ssh.nix` den `homeserver`-Block unter `programs.ssh.settings` einkommentieren und ausfüllen → `rebuild` →
ab jetzt reicht `ssh homeserver`. In VS Code: *Remote-SSH: Connect to Host* → `homeserver`.

### C4. Monitor feinjustieren
```bash
hyprctl monitors
```
Name, Auflösung und Hz in `home/noah/hyprland.nix` bei `monitor` eintragen, z. B.
`"DP-1, 2560x1440@165, 0x0, 1"`.

---

## Teil D: Secure Boot mit Lanzaboote einschalten

Danach bootet NixOS signiert mit **deinen** Schlüsseln, Windows weiter mit den Microsoft-Schlüsseln,
und Secure Boot bleibt dauerhaft an.

### D1. Schlüssel erzeugen
```bash
sudo sbctl create-keys
sudo sbctl status        # "Setup Mode: Disabled", "Secure Boot: Disabled" ist hier normal
```
Die Schlüssel liegen in `/var/lib/sbctl` und gehören **nicht** ins Repo. Sichere sie am besten
zusätzlich verschlüsselt (z. B. auf einem USB-Stick).

### D2. Lanzaboote aktivieren
In `hosts/nixos-pc/default.nix`:
```nix
my.secureBoot.enable = true;
```
Dann:
```bash
rebuild
sudo sbctl verify
```
Alles unter `/boot/EFI/` sollte als **signed** erscheinen. Ausnahme: Dateien mit `kernel-`
bzw. `-bzImage.efi` im Namen. Die werden indirekt geprüft, `not signed` ist dort normal.

Einmal neu starten und prüfen, dass NixOS noch normal bootet (Secure Boot ist noch aus).
Committen: `git commit -am "nixos-pc: enable lanzaboote"`.

### D3. BIOS: Setup Mode
Neustart ins BIOS (`systemctl reboot --firmware-setup` geht direkt dorthin):
1. **Secure Boot** auf *Enabled* bzw. Modus *Custom* stellen
2. **Setup Mode** aktivieren. Je nach Hersteller heißt das *Reset to Setup Mode*,
   *Clear Secure Boot Keys* oder *Delete Platform Key (PK)*.
   ASUS: *OS Type* = *Windows UEFI Mode*, dann *Key Management → Clear Secure Boot Keys*.
3. **Nicht** „Erase all Secure Boot Settings“ wählen, falls das auch die *dbx* (Sperrliste) löscht.
4. Speichern (`F10`) → bootet NixOS.

### D4. Schlüssel registrieren
```bash
sudo sbctl status                     # muss "Setup Mode: ✓ Enabled" zeigen
sudo sbctl enroll-keys --microsoft --firmware-builtin
# --microsoft ist PFLICHT (Windows + Grafikkarten-ROM),
# --firmware-builtin behält zusätzlich die Hersteller-Schlüssel des Mainboards
```
> Meldet sbctl `File is immutable: /sys/firmware/efi/efivars/KEK-…` bzw. `db-…`: Der Kernel
> schützt vorhandene EFI-Variablen. Schutz für genau die genannten Dateien aufheben und erneut
> ausführen: `sudo chattr -i /sys/firmware/efi/efivars/KEK-<…> /sys/firmware/efi/efivars/db-<…>`.
> Nicht `--yes-this-might-brick-my-machine` verwenden.
>
> War die Firmware schon im Setup Mode (`sbctl status` → `Setup Mode: Enabled`), entfällt D3.
Neustart. Danach:
```bash
bootctl status | grep -i "secure boot"    # -> enabled (user)
```

### D5. Windows prüfen
Über das Boot-Menü (`F8`/`F11`/`F12`) **Windows Boot Manager** starten.
- Fragt BitLocker nach dem Recovery-Key: Key aus A2 eingeben. Das passiert nur einmal.
- `msinfo32` → *Sicherer Startzustand: Ein*
- Riot Client starten. Vanguard sollte jetzt ohne VAN-9003-Fehler laufen.

> Spinnt Windows nach dem Registrieren: im BIOS *Restore Factory Keys* wählen. Dann bootet Windows
> wieder normal, NixOS aber erst nach erneutem Setup Mode + D4 (oder mit Secure Boot aus).

### D6. SSD automatisch per TPM entsperren
Erst jetzt, mit **aktivem Secure Boot**, weil der TPM-Schlüssel an den Secure-Boot-Zustand
(PCR 7) gebunden wird. Davor eingerichtet, würde er nach Teil D sowieso nicht mehr passen.
```bash
systemd-analyze has-tpm2      # sollte "yes" melden (fTPM im BIOS an, wie für Windows 11)
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p6
```
Einmal das LUKS-Passwort eingeben, das war's. Beim nächsten Start: **kein** Passwort mehr, direkt
der Login-Bildschirm. Prüfen:
```bash
sudo systemd-cryptenroll /dev/nvme0n1p6   # listet "password" und "tpm2"
```

> **Fragt NixOS doch wieder nach dem LUKS-Passwort** (z. B. nach BIOS-Update oder neuen
> Secure-Boot-Schlüsseln): Passwort eingeben und TPM neu binden:
> `sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p6`

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| Nach Änderung bootet nichts mehr | Im systemd-boot-Menü eine ältere Generation wählen (Menü erscheint 3 s; sonst beim Booten `Leertaste` halten) |
| Windows will BitLocker-Recovery-Key | Key aus A2 eingeben; tritt einmalig nach Secure-Boot-Änderung auf |
| Riot: VAN 9003 | Secure Boot ist aus → Teil D erledigen; `msinfo32` prüfen |
| Boot fragt plötzlich nach LUKS-Passwort | TPM-Bindung passt nicht mehr (BIOS-Update, Secure Boot geändert): Passwort eingeben, D6 mit `--wipe-slot=tpm2` wiederholen |
| NixOS: „Security violation“ beim Boot | Signatur passt nicht: Secure Boot im BIOS kurz aus, booten, `sudo sbctl verify`, `rebuild` |
| Uhrzeit in Windows falsch | Ist mit `time.hardwareClockInLocalTime` abgedeckt; sonst `timedatectl` prüfen |
| `rebuild` findet neue Datei nicht | `git add <datei>`, weil Flakes nur getrackte Dateien sehen |
| Schwarzer Bildschirm nach Login | `STRG+ALT+F2` → TTY → `journalctl --user -b -u hyprland*` bzw. `~/.local/share/hyprland/hyprland.log` |
| Kein WLAN | `nmtui` |
