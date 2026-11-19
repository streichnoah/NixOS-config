# Einstellungen für Nix selbst
{ ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
  };

  # Alte Generationen automatisch aufräumen
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # VS Code, Discord, Spotify, Terraform sind unfrei lizenziert
  nixpkgs.config.allowUnfree = true;

  # Erlaubt das Ausführen fremder, dynamisch gelinkter Binaries
  # (z. B. VS-Code-Extensions mit eigenen Binaries, npm-Pakete, Language Server)
  programs.nix-ld.enable = true;
}
