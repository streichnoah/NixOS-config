{ ... }:
{
  programs.kitty = {
    enable = true;
    # Schrift, Farben und Transparenz setzt Stylix (modules/nixos/theme.nix)
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      window_padding_width = 6;
    };
  };
}
