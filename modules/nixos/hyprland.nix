# Systemseite von Hyprland. Die eigentliche Hyprland-Config (Keybinds etc.)
# liegt in home/noah/hyprland.nix (Home Manager).
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Login-Screen: schlanker TUI-Greeter, startet danach Hyprland über den
  # offiziellen Wrapper start-hyprland (direkter Start von `Hyprland` wird nicht empfohlen)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd start-hyprland";
      user = "greeter";
    };
  };

  # Hinweise für Electron/Chromium-Apps (VS Code, Discord, Spotify), nativ Wayland zu nutzen
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # hyprlock muss sich gegen PAM authentifizieren dürfen
  security.pam.services.hyprlock = { };

  # Schlüsselbund (z. B. für VS Code / GitHub-Login) und Automount für USB-Sticks
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Dateimanager
  programs.thunar.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];
}
