{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    themeFile = "Catppuccin-Mocha";
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      window_padding_width = 6;
      background_opacity = "0.95";
    };
  };
}
