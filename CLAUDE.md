# CLAUDE.md: Kontext für Claude Code in diesem Repo

Dieses Repo ist die **deklarative NixOS-Konfiguration** von Noahs Desktop-PC `nixos-pc`
(Dual Boot mit Windows auf derselben 2-TB-SSD). Noah lernt damit Linux und Infrastructure-as-Code.
Erkläre Änderungen kurz und verständlich (auf Deutsch), statt nur Befehle hinzuwerfen.

## Aufbau
- `flake.nix`: Inputs: nixpkgs (nixos-unstable), home-manager, lanzaboote (v1.2.0), zen-browser
- `hosts/nixos-pc/`: Host: Modul-Imports, Hostname, `my.secureBoot.enable`, stateVersion
- `hosts/nixos-pc/hardware-configuration.nix`: bei der Installation generiert, nur mit gutem Grund ändern
- `modules/nixos/*.nix`: Systemebene (Boot, Secure Boot, LUKS/TPM, AMD-GPU, Audio, Hyprland, Docker, User)
- `home/noah/*.nix`: Home Manager (Hyprland-Config, Waybar, Shell, Git, SSH, VS Code, Dev-Tools, Apps)
- `docs/INSTALL.md`: Installationsanleitung inkl. Teil D (Secure Boot + TPM)

## Workflow
- Neue Dateien **vor** dem Bauen mit `git add` tracken, sonst sieht die Flake sie nicht.
- Erst bauen/testen, dann aktivieren:
  - `nix flake check` / `nixos-rebuild build --flake .#nixos-pc` (baut nur, ändert nichts)
  - `sudo nixos-rebuild test --flake .#nixos-pc` (aktiv bis zum Neustart)
  - `sudo nixos-rebuild switch --flake .#nixos-pc` (Alias: `rebuild`)
- Formatieren: `nix fmt`
- Nach erfolgreichen Änderungen committen (kleine, beschreibende Commits). Pushen nur nach Rückfrage.
- Rollback: ältere Generation im systemd-boot-Menü oder `sudo nixos-rebuild switch --rollback`.

## Wichtige Fakten / Stolperfallen
- **Hyprland 0.57** liest **nur noch Lua** (`~/.config/hypr/hyprland.lua`); das alte `hyprland.conf`-Format
  (hyprlang) wird ignoriert, auch mit `--config`. In `home/noah/hyprland.nix` gilt daher `configType = "lua"`:
  Optionen in `settings.config` (→ `hl.config({...})`), Keybinds/Autostart als Lua in `extraConfig`.
  API-Referenz: `share/hypr/stubs/hl.meta.lua` im Hyprland-Paket, Wiki: https://wiki.hypr.land.
  Vor dem Aktivieren prüfen: `Hyprland --verify-config --config <erzeugte hyprland.lua>`; im laufenden
  System: `hyprctl configerrors`. Hypridle/Hyprlock nutzen weiterhin `.conf`.
- **Secure Boot** über Lanzaboote (`modules/nixos/secure-boot.nix`, Schalter `my.secureBoot.enable`).
  Schlüssel liegen in `/var/lib/sbctl` und gehören **niemals** ins Repo. Mainboard: Gigabyte,
  *Factory Key Provision* muss im BIOS auf Disabled bleiben. Windows wird über das Boot-Menü (F12)
  gestartet. Riot Vanguard braucht Secure Boot an.
- **LUKS** auf `/dev/nvme0n1p6` (`cryptroot`), Entsperren per TPM2 (`modules/nixos/disk-encryption.nix`,
  PCR 7). Neu binden: `sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p6`
- Windows-Partitionen `nvme0n1p1`–`p4` **nie anfassen**. NixOS-ESP ist `nvme0n1p5` (`/boot`).
- Option-Namen ändern sich auf unstable häufig. Bei Fehlern/Warnungen die aktuelle Doku prüfen
  (https://search.nixos.org/options, https://nix-community.github.io/home-manager/options.xhtml),
  nicht raten.

## Regeln
- Das Repo ist **öffentlich**: keine Secrets, privaten Keys, Passwörter, Tokens oder privaten IPs
  committen. Für Secrets später sops-nix/agenix. Ausnahme: Noahs Git-Identität in `home/noah/git.nix`
  (Name + E-Mail) steht bewusst im Repo; keine weiteren privaten Adressen hinzufügen.
- Nichts an Partitionen, Bootloader-Schlüsseln, BIOS-/EFI-Variablen oder LUKS-Slots ändern, ohne vorher
  zu erklären, was passiert, und Noahs ausdrückliches OK abzuwarten.
- Lieber deklarativ in der Config lösen als imperativ (`nix-env`, manuelle Dateien in `~/.config`).
