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
      theme = "robbyrussell";
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

      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      cat = "bat --paging=never";
      k = "kubectl";
      tf = "terraform";
    };
  };

  # Bessere Werkzeuge mit zsh-Integration
  programs.fzf.enable = true; # STRG+R: History-Suche
  programs.zoxide.enable = true; # `z ordner` springt in oft genutzte Ordner
  programs.eza.enable = true;
  programs.bat.enable = true;
}
