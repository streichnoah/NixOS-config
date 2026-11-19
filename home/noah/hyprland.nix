# Hyprland-Konfiguration. Doku: https://wiki.hypr.land
# Mod-Taste ist SUPER (Windows-Taste).
{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Paket & Portal kommen vom NixOS-Modul (modules/nixos/hyprland.nix)
    package = null;
    portalPackage = null;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$launcher" = "fuzzel";
      "$files" = "thunar";
      "$browser" = "zen";

      # Monitor automatisch mit höchster Bildwiederholrate erkennen.
      # Später konkret, z. B.: "DP-1, 2560x1440@165, 0x0, 1"  (Namen via `hyprctl monitors`)
      monitor = [ ", highrr, auto, 1" ];

      exec-once = [
        "nm-applet --indicator"
        "blueman-applet"
      ];

      input = {
        kb_layout = "de";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(45475aaa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };

      animations.enabled = true;

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        force_default_wallpaper = 0;
      };

      bind = [
        # Programme
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $launcher"
        "$mod, E, exec, $files"
        "$mod, B, exec, $browser"
        "$mod SHIFT, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

        # Fenster
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        # Sitzung
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, E, exit"

        # Screenshots (Bereich / ganzer Bildschirm) -> Zwischenablage + ~/Pictures
        ", Print, exec, hyprshot -m region -o ~/Pictures/Screenshots"
        "SHIFT, Print, exec, hyprshot -m output -o ~/Pictures/Screenshots"

        # Fokus mit Pfeiltasten
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Fenster verschieben
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Scratchpad
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
      ]
      # Workspaces 1-9: SUPER+Zahl wechselt, SUPER+SHIFT+Zahl verschiebt Fenster
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = toString (i + 1);
          in
          [
            "$mod, ${ws}, workspace, ${ws}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
          ]
        ) 9
      ));

      # Maus: SUPER + Links ziehen = verschieben, SUPER + Rechts ziehen = Größe ändern
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Lautstärke/Medien (funktionieren auch im Lockscreen, mit Wiederholung)
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
      ];
    };
  };
}
