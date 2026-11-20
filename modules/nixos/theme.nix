# Systemweites Theming mit Stylix (https://nix-community.github.io/stylix/)
#
# Ein Farbschema, eine Schriftfamilie, ein Wallpaper und ein Cursor werden hier EINMAL
# festgelegt. Stylix färbt damit automatisch System (TTY-Konsole) und, über Home Manager,
# fast alle Apps ein: Kitty, GTK, Waybar, Fuzzel, Mako, Hyprlock, Hyprpaper, VS Code ...
#
# Schema wechseln: base16Scheme ändern, z. B. "tokyo-night-dark.yaml" oder "gruvbox-dark-hard.yaml"
# (Liste: ls $(nix build --no-link --print-out-paths nixpkgs#base16-schemes)/share/themes)
{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Wallpaper aus dem offiziellen NixOS-Artwork (kein Bild im Repo nötig).
    # Schlichtere Alternative: nineish-catppuccin-mocha
    image = "${pkgs.nixos-artwork.wallpapers.catppuccin-mocha}/share/backgrounds/nixos/nixos-wallpaper-catppuccin-mocha.png";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 12;
        applications = 11;
        desktop = 11;
        popups = 11;
      };
    };

    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    # Etwas Transparenz für den "verspielten" Look (1.0 = deckend)
    opacity = {
      terminal = 0.85;
      desktop = 0.8; # Waybar
      popups = 0.9; # Fuzzel, Mako
    };
  };
}
