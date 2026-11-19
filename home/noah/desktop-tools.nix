# Alles rund um Hyprland: Statusleiste, Launcher, Benachrichtigungen, Lockscreen, ...
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    hyprshot
    playerctl
    pavucontrol
    networkmanagerapplet
    brightnessctl
  ];

  # App-Launcher (SUPER+D)
  programs.fuzzel = {
    enable = true;
    settings.main = {
      font = "JetBrainsMono Nerd Font:size=12";
      terminal = "kitty";
      layer = "overlay";
    };
  };

  # Benachrichtigungen
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
      font = "JetBrainsMono Nerd Font 11";
    };
  };

  # Zwischenablage-Verlauf (SUPER+SHIFT+V)
  services.cliphist.enable = true;

  # Polkit-Agent: Passwortdialoge für GUI-Apps
  services.hyprpolkitagent.enable = true;

  # Lockscreen (SUPER+L)
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      background = [
        {
          color = "rgba(1e1e2eff)";
          blur_passes = 2;
        }
      ];
      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
          placeholder_text = "Passwort...";
        }
      ];
      label = [
        {
          text = "$TIME";
          font_size = 64;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Nach 10 min sperren, nach 15 min Bildschirm aus
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Statusleiste
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu"
        "memory"
        "pulseaudio"
        "network"
        "tray"
      ];
      clock = {
        format = "{:%a %d.%m.  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };
      cpu.format = "  {usage}%";
      memory.format = "  {percentage}%";
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
      };
      network = {
        format-ethernet = "󰈀 {ipaddr}";
        format-wifi = "  {essid}";
        format-disconnected = "󰖪 offline";
      };
      tray.spacing = 8;
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }
      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }
      #workspaces button {
        padding: 0 8px;
        color: #a6adc8;
      }
      #workspaces button.active {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
      }
      #clock, #cpu, #memory, #pulseaudio, #network, #tray {
        padding: 0 10px;
      }
    '';
  };

  # Einheitliches Dark-Theme für GTK-Apps
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };
}
