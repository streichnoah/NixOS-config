# Auftrag: Erst-Check, Fehlerbehebung und Personalisierung von nixos-pc

Du arbeitest auf Noahs frisch installiertem NixOS-Desktop direkt in seinem Config-Repo
(`~/NixOS-config`). Lies zuerst `CLAUDE.md`, `README.md` und `docs/INSTALL.md` vollständig. Dort
stehen Aufbau, Workflow, Stolperfallen und Sicherheitsregeln. Halte dich strikt daran.

Kommuniziere auf Deutsch. Noah will Linux und Infrastructure-as-Code **lernen**: Erkläre bei jeder
Änderung kurz *was* du machst und *warum* (1–3 Sätze), und nenne die relevante Nix-/NixOS-Idee
dahinter (z. B. Modul-System, Generationen, Home Manager vs. System). Keine langen Vorträge.

Arbeite in den folgenden Phasen und **warte am Ende jeder Phase auf Noahs OK**, bevor du weitermachst.

---

## Phase 1: Bestandsaufnahme (nur lesen, nichts ändern)

Sammle den Ist-Zustand. Führe nur lesende Befehle aus, z. B.:

**Repo & Build**
- `git status`, `git log --oneline -5`, `git diff`: Gibt es uncommittete Änderungen (z. B. die
  generierte `hardware-configuration.nix` oder `my.secureBoot.enable`)?
- `nix flake check` und `nixos-rebuild build --flake .#nixos-pc`: Fehler **und Warnungen**
  (Deprecations, umbenannte Optionen) notieren.

**System**
- `systemctl --failed`, `systemctl --user --failed`
- `journalctl -b -p warning --no-pager | tail -100` (Kernel, Firmware, Treiber)
- `bootctl status`, `sudo sbctl status`, `sudo sbctl verify`: Ist Secure Boot an (user mode)?
  Ist Lanzaboote aktiv? Sind alle Dateien signiert?
- `sudo systemd-cryptenroll /dev/nvme0n1p6`: Ist ein TPM2-Slot eingerichtet? `systemd-analyze has-tpm2`
- `lsblk -f`, `df -h`, `swapon --show`/`zramctl`

**Hardware**
- GPU: `lspci -k | grep -A3 -i vga`, `vulkaninfo --summary` bzw. `nix shell nixpkgs#vulkan-tools`,
  `glxinfo -B` (über `nix shell nixpkgs#mesa-demos`). Läuft RADV/amdgpu für die RX 7800 XT?
- Audio: `wpctl status`. Netzwerk/WLAN: `nmcli device`. Bluetooth: `bluetoothctl show`
- Monitor: `hyprctl monitors`. Richtige Auflösung und Hz?

**Desktop (Hyprland)**
- `hyprctl configerrors`, `~/.local/share/hyprland/hyprland.log` (bzw. `$XDG_RUNTIME_DIR/hypr/*/hyprland.log`)
- Laufen Waybar, Mako, Hypridle, Hyprpolkitagent, Cliphist? (`systemctl --user status ...`)
- Funktionieren die Keybinds aus `home/noah/hyprland.nix` (Terminal, Launcher, Screenshot, Lock)?
  Frag Noah gezielt, was er beim Testen bemerkt hat.
- Portale/Screensharing: `systemctl --user status xdg-desktop-portal-hyprland`

**Dev & Tools**
- `docker info` (läuft der Daemon, ist noah in der Gruppe?), `code --version`, `direnv version`
- Startet der Zen Browser, Discord, Spotify?

**Ergebnis:** Eine kompakte Tabelle: *Problem | Ursache (vermutet/bestätigt) | Schwere
(kritisch/mittel/kosmetisch) | Vorschlag*. Dazu eine Liste „funktioniert“. Dann auf OK warten.

---

## Phase 2: Fehler beheben

- Ein Problem nach dem anderen, kritische zuerst.
- Immer deklarativ in der Config lösen. Vor dem Ändern die **aktuelle** Doku der Option prüfen
  (search.nixos.org / Home-Manager-Optionen / Hyprland-Wiki), da nixos-unstable sich schnell ändert.
- Ablauf pro Fix: ändern → `git add` → `nixos-rebuild build` → bei Erfolg `sudo nixos-rebuild switch`
  (bzw. `test`, wenn riskant) → verifizieren → **einzeln committen** mit aussagekräftiger Nachricht.
- Vor dem ersten Commit `git config user.name/user.email` prüfen. Fehlt die E-Mail: Noah fragen und die
  GitHub-**noreply**-Adresse empfehlen (Repo ist öffentlich), dann in `home/noah/git.nix` eintragen.
- Nicht pushen, ohne zu fragen.

---

## Phase 3: Secure Boot & TPM abschließen (falls noch offen)

Prüfe anhand von Phase 1, wie weit `docs/INSTALL.md` Teil D ist (D1–D6). Falls etwas fehlt, führe
Noah **Schritt für Schritt** durch. Erkläre vor jedem Schritt, was passiert, und **warte auf sein OK**,
bevor du Befehle ausführst, die Schlüssel, EFI-Variablen oder LUKS-Slots ändern
(`sbctl create-keys`, `sbctl enroll-keys --microsoft`, `systemd-cryptenroll`).
- Mainboard: Gigabyte. *Factory Key Provision* muss Disabled sein, Setup Mode über
  *Expert Key Management*. `enroll-keys` **nur mit `--microsoft`** und nur, wenn `sbctl verify` sauber ist.
- Ziel: `bootctl status` zeigt *Secure Boot: enabled (user)*, Windows bootet (F12), Riot/Vanguard
  läuft, NixOS bootet ohne LUKS-Passwort (TPM2, PCR 7).

---

## Phase 4: Personalisierung (Interview, dann umsetzen)

Stelle Noah die Fragen **in kleinen Runden** (max. 4 Fragen pro Runde, mit sinnvollen Vorschlägen
als Antwortoptionen) und setze nach jeder Runde um, bevor die nächste kommt:

1. **Look & Feel:** Farbschema (z. B. Catppuccin, Gruvbox, Tokyo Night, Nord), systemweit
   einheitlich (Kitty, Waybar, Hyprland-Borders, GTK, VS Code, Fuzzel, Mako, Hyprlock)? Ein Theming-Tool
   wie **Stylix** vorschlagen und Vor-/Nachteile erklären. Wallpaper (hyprpaper/swww)? Schrift?
   Rundungen, Gaps, Animationen, Transparenz?
2. **Monitore:** Anzahl, Auflösung, Hz, Anordnung, Skalierung → feste `monitor`-Zeilen.
3. **Workflow & Keybinds:** Welche Tastenkürzel fehlen oder stören? Feste Workspaces für Apps
   (z. B. Browser auf 2, Discord auf 9)? Fensterregeln (Floating für pavucontrol etc., **neue Syntax**!).
   Autostart-Apps? Bildschirmsperre/Timeout-Zeiten?
4. **Waybar:** Welche Module (Media/Spotify, Bluetooth, GPU-Temp, Uhr-Format, Updates, Power-Menü)?
5. **Shell & Terminal:** oh-my-zsh-Theme oder Starship? Zusätzliche Aliases, Plugins, Tools
   (z. B. tmux/zellij, yazi, fastfetch)?
6. **Entwicklung:** Welche Sprachen/Versionen konkret? Projekt-Templates mit `nix flake init` + direnv
   zeigen (siehe `docs/DEVSHELLS.md`). VS Code: Theme, Settings, weitere Extensions? Git-Aliases,
   Commit-Signing mit SSH-Key?
7. **Server/SSH:** Neuen ed25519-Key erzeugen (Passphrase!), auf den Server bringen (`ssh-copy-id`),
   Host-Eintrag in `home/noah/ssh.nix`. Vorher fragen, ob IP/Hostname im **öffentlichen** Repo stehen
   darf, sonst eine Lösung ohne Klartext vorschlagen (z. B. `programs.ssh.includes` auf eine nicht
   versionierte Datei, oder später sops-nix).
8. **Apps & Gaming:** Weitere Programme? Steam/Proton unter Linux gewünscht? Office, Notizen,
   Passwort-Manager-Integration?

Halte die Struktur sauber: neue Themen in eigene Module (`home/noah/<thema>.nix` bzw.
`modules/nixos/<thema>.nix`), README aktualisieren (Tabelle, Keybinds).

---

## Phase 5: Abschluss

- Zusammenfassung: Was wurde behoben, was personalisiert, was ist offen?
- `nix fmt`, finaler `nixos-rebuild build`, sauberer `git status`, dann fragen, ob gepusht werden soll.
- 3–5 konkrete nächste Lernschritte vorschlagen (z. B. sops-nix für Secrets, den Server als zweiten
  Host in der Flake mit NixOS, `nixos-rebuild --target-host`, Terraform/Ansible gegen den Server,
  eigene kleine NixOS-Module mit Optionen schreiben).

## Grenzen
- Keine Änderungen an Partitionen, Windows (`nvme0n1p1`–`p4`), BIOS/EFI-Variablen oder LUKS ohne
  ausdrückliches OK.
- Keine Secrets ins Repo. Keine imperativen Installationen (`nix-env -i`, `curl | sh`), wenn es
  deklarativ geht.
- Wenn du dir bei einer Option oder einem Befehl unsicher bist: nachschlagen oder fragen, nicht raten.
