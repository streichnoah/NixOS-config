# zsh + oh-my-zsh und ein paar moderne CLI-Helfer
{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 50000;
      ignoreDups = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      # Eigenes Theme aus home/noah/zsh/themes/noah.zsh-theme
      custom = "${./zsh}";
      theme = "noah";
      plugins = [
        "git"
        "sudo" # 2x ESC -> letzten Befehl mit sudo wiederholen
        "docker"
        "kubectl"
        "terraform"
        "ansible"
      ];
    };

    shellAliases = {
      # NixOS-Workflow (Repo liegt unter ~/NixOS-config)
      rebuild = "sudo nixos-rebuild switch --flake ~/NixOS-config#nixos-pc";
      rebuild-test = "sudo nixos-rebuild test --flake ~/NixOS-config#nixos-pc";
      update = "nix flake update --flake ~/NixOS-config";
      cleanup = "sudo nix-collect-garbage --delete-older-than 14d";
      # Die .zshrc wird von Home Manager erzeugt (schreibgeschützt) -> hier bearbeiten
      zshrc = "code ~/NixOS-config/home/noah/shell.nix";
      r = "omz reload";

      # Git
      gdev = "git checkout develop && git pull origin develop";
      gs = "git status -sb";
      gl = "git log --oneline";
      ga = "git add .";
      gc = "git commit -m";
      grh = "git reset HEAD~";
      fgd = "git diff --name-only | fzf --preview 'git diff --color=always -w {}' --preview-window 'right:60%'";

      # Docker
      dps = "docker ps";
      dpa = "docker ps -a";
      dcu = "docker-compose up -d";
      dcub = "docker-compose up -d --build";
      dl = "docker logs -f";
      dcd = "docker-compose down";

      # Dateien (eza statt ls, bat statt cat; Farben von Stylix)
      ls = "eza --icons=auto";
      ll = "eza --long --all --group-directories-first --git --icons=auto";
      l = "eza --long --group-directories-first --git --icons=auto";
      la = "eza --all --group-directories-first --icons=auto";
      tree2 = "eza --tree --level=2 --icons=auto";
      tree3 = "eza --tree --level=3 --icons=auto";
      cat = "bat --paging=never";
      fs = "fzf --preview 'bat --color=always {}' --preview-window 'right:60%'";
      ".." = "cd ..";
      "..." = "cd ../..";

      # Sonstiges
      c = "code";
      py = "python3";
      k = "kubectl";
      tf = "terraform";
      now = "date '+%Y-%m-%d %H:%M:%S'";
      week = "date '+%V'";
      mem = "free -h";
      pingtest = "ping -c 5 google.com";
      shellinfo = "printf 'Shell: %s\\nVersion: %s\\n' \"$SHELL\" \"$ZSH_VERSION\"";
    };

    # Eigene Shell-Funktionen
    initContent = ''
      # In Ordner wechseln und Inhalt anzeigen
      cl() {
        cd "$@" && l
      }

      # Ordner anlegen und hineinwechseln
      mkcd() {
        if [ "$#" -ne 1 ]; then
          printf 'Usage: mkcd <directory>\n' >&2
          return 2
        fi
        mkdir -p -- "$1" && cd -- "$1"
      }
    '';
  };

  # Bessere Werkzeuge mit zsh-Integration
  programs.fzf.enable = true; # STRG+R: History-Suche
  programs.zoxide.enable = true; # `z ordner` springt in oft genutzte Ordner
  programs.eza.enable = true;
  programs.bat.enable = true;

  # Terminal-Dateimanager mit Vorschau. `y` startet ihn; beim Beenden (q) landet die
  # Shell im zuletzt geöffneten Ordner.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  # Ressourcen-Monitor (Farben von Stylix)
  programs.btop.enable = true;

  # Systeminfo mit NixOS-Logo: `fastfetch`
  programs.fastfetch.enable = true;

  # Terminal-Multiplexer: Sitzungen/Fenster/Splits in einem Terminal, überleben SSH-Abbrüche.
  # Präfix ist STRG+B (Standard), danach z. B. % = vertikal teilen, " = horizontal,
  # c = neues Fenster, d = abkoppeln (`tmux attach` holt die Sitzung zurück).
  programs.tmux = {
    enable = true;
    mouse = true; # Panes per Maus wählen/Größe ändern, scrollen
    baseIndex = 1; # Fenster ab 1 zählen, passt zur Tastatur
    escapeTime = 0; # keine Verzögerung nach ESC (wichtig für Vim)
    historyLimit = 50000;
    terminal = "tmux-256color";
  };
}
