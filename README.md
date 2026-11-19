# NixOS-config

Deklarative NixOS-Konfiguration für meinen Desktop-PC (`nixos-pc`), Dual Boot neben Windows.
Ziel ist, Linux und Infrastructure-as-Code zu lernen, zu entwickeln und meinen Server per SSH zu steuern.

| Bereich | Wahl |
|---|---|
| Config-Stil | Flakes + Home Manager (nixos-unstable) |
| Hardware | AMD Radeon RX 7800 XT (amdgpu/Mesa), Kernel `linuxPackages_latest` |
| Boot | systemd-boot + Lanzaboote (Secure Boot an, für Riot Vanguard), eigene 1-GB-ESP; Windows über Mainboard-Bootmenü |
| Disk | LUKS-verschlüsselt mit TPM2-Auto-Unlock (kein Boot-Passwort), ext4, zram-Swap |
| Desktop | Hyprland (Wayland), greetd/tuigreet, Waybar, Fuzzel, Mako, Hyprlock |
| Shell | zsh + oh-my-zsh, Kitty |
| Dev | VS Code, Python, Node/TS, Java, .NET, direnv + nix-direnv |
| Infra | Docker, Terraform/OpenTofu, Ansible, kubectl/helm/k9s |
| Apps | Zen Browser, Discord, Spotify |

## Struktur

```
flake.nix                    # Einstiegspunkt: Inputs (nixpkgs, home-manager, zen) + Host-Definition
hosts/nixos-pc/
  default.nix                # Welche Module dieser Rechner nutzt, Hostname, stateVersion
  hardware-configuration.nix # Bei der Installation generiert (Disks, Kernelmodule)
modules/nixos/               # Systemebene (root): Boot/Secure Boot, GPU, Audio, Hyprland, Docker, User ...
home/noah/                   # Home Manager (User): Hyprland-Config, Shell, Git, SSH, VS Code, Tools
docs/
  INSTALL.md                 # Schritt-für-Schritt Dual-Boot-Installation
  DEVSHELLS.md               # Projekt-Umgebungen mit `nix develop` + direnv
```

## Täglicher Workflow

```bash
cd ~/NixOS-config
# Datei ändern, z. B. ein Paket in home/noah/dev.nix hinzufügen, dann:
rebuild          # = sudo nixos-rebuild switch --flake ~/NixOS-config#nixos-pc
git commit -am "add xyz" && git push

update && rebuild   # alle Pakete aktualisieren (flake.lock), dann bauen
```

Geht etwas kaputt: Im systemd-boot-Menü eine ältere Generation booten.
Oder `sudo nixos-rebuild switch --rollback`.

> Neue Dateien müssen vor dem `rebuild` mit `git add` getrackt werden, sonst sieht die Flake sie nicht.

## Keybinds (Hyprland)

| Taste | Aktion |
|---|---|
| `SUPER + Enter` | Terminal (Kitty) |
| `SUPER + D` | App-Launcher |
| `SUPER + B` / `E` | Browser / Dateimanager |
| `SUPER + Q` | Fenster schließen |
| `SUPER + F` / `V` | Vollbild / Floating |
| `SUPER + 1..9` | Workspace wechseln (`+ SHIFT`: Fenster verschieben) |
| `SUPER + Pfeile` | Fokus wechseln (`+ SHIFT`: Fenster verschieben) |
| `SUPER + S` | Scratchpad |
| `SUPER + SHIFT + V` | Zwischenablage-Verlauf |
| `SUPER + L` | Sperren |
| `SUPER + SHIFT + E` | Hyprland beenden |
| `Print` / `SHIFT + Print` | Screenshot Bereich / Bildschirm |

## Ideen für später (IaC-Lernpfad)

- **sops-nix / agenix**: Secrets verschlüsselt im Repo
- **disko**: Partitionierung ebenfalls deklarativ
- **Server mit NixOS**: zweiter Host in `flake.nix`, Deployment per `nixos-rebuild --target-host` oder `deploy-rs`/`colmena`
- **Terraform + Ansible** gegen den Server aus diesem Repo heraus
