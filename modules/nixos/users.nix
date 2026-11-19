{ pkgs, username, ... }:
{
  # zsh systemweit aktivieren (nötig, damit sie Login-Shell sein kann).
  # Die eigentliche Konfiguration (oh-my-zsh) macht Home Manager.
  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Noah";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # Passwort wird bei der Installation per `nixos-install` bzw. `passwd` gesetzt.
  };
}
