# Hyprland-Konfiguration. Doku: https://wiki.hypr.land
# Mod-Taste ist SUPER (Windows-Taste).
#
# Ab Hyprland 0.57 gibt es nur noch Lua-Configs (hyprland.lua), das alte
# hyprland.conf-Format (hyprlang) wird nicht mehr gelesen. Home Manager erzeugt
# daraus ~/.config/hypr/hyprland.lua:
#   - settings.<name> = { ... }  wird zu  hl.<name>({ ... })
#   - extraConfig wird als Lua-Code unverändert angehängt (Keybinds, Autostart)
# Die API-Referenz liegt im Hyprland-Paket unter share/hypr/stubs/hl.meta.lua.
{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Paket & Portal kommen vom NixOS-Modul (modules/nixos/hyprland.nix)
    package = null;
    portalPackage = null;
    systemd.enable = true;

    configType = "lua";

    settings = {
      # Monitor automatisch mit höchster Bildwiederholrate erkennen.
      # Später konkret, z. B. { output = "DP-1"; mode = "2560x1440@165"; position = "0x0"; }
      # (Namen via `hyprctl monitors`)
      monitor = {
        output = "";
        mode = "highrr";
        position = "auto";
        scale = 1;
      };

      # Alle normalen Optionen -> hl.config({ ... })
      config = {
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
          col = {
            active_border = {
              colors = [
                "rgba(89b4faee)"
                "rgba(cba6f7ee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(45475aaa)";
          };
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

        dwindle.preserve_split = true;

        # Unsichtbarer Mauszeiger auf manchen GPU/Monitor-Kombis -> Software-Cursor nutzen
        cursor.no_hardware_cursors = true;

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
        };
      };
    };

    extraConfig = ''
      ---- Programme ----
      local mod      = "SUPER"
      local terminal = "kitty"
      local launcher = "fuzzel"
      local files    = "thunar"
      local browser  = "zen-beta" -- so heißt der Befehl im zen-browser-Flake

      ---- Autostart ----
      hl.on("hyprland.start", function()
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("blueman-applet")
      end)

      ---- Keybinds ----
      local function bind(keys, dispatcher, opts)
        hl.bind(mod .. " + " .. keys, dispatcher, opts)
      end

      -- Programme
      bind("Return", hl.dsp.exec_cmd(terminal))
      bind("D", hl.dsp.exec_cmd(launcher))
      bind("E", hl.dsp.exec_cmd(files))
      bind("B", hl.dsp.exec_cmd(browser))
      bind("SHIFT + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

      -- Fenster
      bind("Q", hl.dsp.window.close())
      bind("F", hl.dsp.window.fullscreen())
      bind("V", hl.dsp.window.float({ action = "toggle" }))
      bind("P", hl.dsp.window.pseudo())
      bind("J", hl.dsp.layout("togglesplit"))

      -- Sitzung
      bind("L", hl.dsp.exec_cmd("hyprlock"))
      bind("SHIFT + E", hl.dsp.exit())

      -- Screenshots (Bereich / ganzer Bildschirm) -> Zwischenablage + ~/Pictures
      hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"))

      -- Fokus mit Pfeiltasten, mit SHIFT Fenster verschieben
      for _, dir in ipairs({ "left", "right", "up", "down" }) do
        bind(dir, hl.dsp.focus({ direction = dir }))
        bind("SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
      end

      -- Scratchpad
      bind("S", hl.dsp.workspace.toggle_special("magic"))
      bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

      -- Workspaces 1-9: SUPER+Zahl wechselt, SUPER+SHIFT+Zahl verschiebt Fenster
      for i = 1, 9 do
        bind(tostring(i), hl.dsp.focus({ workspace = i }))
        bind("SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
      end

      -- Maus: SUPER + Links ziehen = verschieben, SUPER + Rechts ziehen = Größe ändern
      bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
      bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Lautstärke/Medien (funktionieren auch im Lockscreen)
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

      -- Fensterregeln (z. B. Floating für pavucontrol) kommen später dazu:
      -- hl.window_rule({ match = { class = "pavucontrol" }, float = true })
      -- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
    '';
  };
}
