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
      terminal = "kitty";
      layer = "overlay";
    };
  };

  # Benachrichtigungen
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 12;
      border-size = 2;
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
      # Farben und Hintergrundbild kommen von Stylix
      background = {
        blur_passes = 3;
        blur_size = 6;
      };
      input-field = {
        size = "300, 50";
        position = "0, -80";
        halign = "center";
        valign = "center";
        rounding = 14;
        placeholder_text = "Passwort...";
      };
      label = {
        text = "$TIME";
        font_size = 64;
        position = "0, 80";
        halign = "center";
        valign = "center";
      };
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
      # Abstand zum Bildschirmrand -> Leiste "schwebt" passend zu den Fenster-Gaps
      margin-top = 8;
      margin-left = 14;
      margin-right = 14;
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
        format-icons.default = [
          ""
          ""
          ""
        ];
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
      /* Farben (@base00..@base0F) und Schrift setzt Stylix, hier nur Layout */
      window#waybar {
        border-radius: 14px;
      }
      #workspaces button {
        padding: 0 8px;
        border-radius: 10px;
      }
      #workspaces button.active {
        color: @base0D;
        border-bottom: 3px solid @base0D;
      }
      #clock, #cpu, #memory, #pulseaudio, #network, #tray {
        padding: 0 10px;
      }
    '';
  };

  # GTK-Theme, Icons (Papirus) und Cursor setzt Stylix (modules/nixos/theme.nix).
  # Cursor zusätzlich als hyprcursor, damit Hyprland ihn selbst zeichnet.
  home.pointerCursor.hyprcursor.enable = true;
}
