# Hyprland-Konfiguration. Doku: https://wiki.hypr.land
# Mod-Taste ist SUPER (Windows-Taste).
#
# Ab Hyprland 0.57 gibt es nur noch Lua-Configs (hyprland.lua), das alte
# hyprland.conf-Format (hyprlang) wird nicht mehr gelesen. Home Manager erzeugt
# daraus ~/.config/hypr/hyprland.lua:
#   - settings.<name> = { ... }  wird zu  hl.<name>({ ... })
#   - extraConfig wird als Lua-Code unverändert angehängt (Keybinds, Autostart)
# Die API-Referenz liegt im Hyprland-Paket unter share/hypr/stubs/hl.meta.lua.
{ config, lib, ... }:
let
  # Farben aus dem Stylix-Schema (modules/nixos/theme.nix), z. B. base0D = Blau, base0E = Lila
  c = config.lib.stylix.colors;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Paket & Portal kommen vom NixOS-Modul (modules/nixos/hyprland.nix)
    package = null;
    portalPackage = null;
    systemd.enable = true;

    configType = "lua";

    settings = {
      # Monitore (Namen, Modi: `hyprctl monitors`). Fest eingetragen, damit die Anordnung
      # immer gleich bleibt. Der letzte Eintrag (output = "") gilt für jeden anderen
      # Monitor, z. B. einen Beamer.
      monitor = [
        {
          output = "DP-1"; # links
          mode = "1920x1080@239.96";
          position = "0x0";
          scale = 1;
        }
        {
          output = "DP-2"; # rechts, Hauptmonitor
          mode = "1920x1080@239.96";
          position = "1920x0";
          scale = 1;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      # Start: Workspace 1 auf dem Hauptmonitor (rechts), 2 links. Alle anderen
      # Workspaces öffnen dort, wo gerade der Fokus ist.
      workspace_rule = [
        {
          workspace = "1";
          monitor = "DP-2";
          default = true;
        }
        {
          workspace = "2";
          monitor = "DP-1";
          default = true;
        }
      ];

      # Alle normalen Optionen -> hl.config({ ... })
      config = {
        input = {
          kb_layout = "de";
          follow_mouse = 1;
          sensitivity = 0;
          accel_profile = "flat";
        };

        general = {
          gaps_in = 6;
          gaps_out = 14;
          border_size = 3;
          # Stylix setzt einfarbige Rahmen; wir überschreiben mit einem Verlauf Blau -> Lila.
          # mkForce = "dieser Wert gewinnt", auch gegen die Definition aus Stylix.
          "col.active_border" = lib.mkForce {
            colors = [
              "rgba(${c.base0D}ee)"
              "rgba(${c.base0E}ee)"
            ];
            angle = 45;
          };
          layout = "dwindle";
        };

        decoration = {
          rounding = 14;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 0.92;
          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            vibrancy = 0.17;
          };
          shadow = {
            enabled = true;
            range = 20;
            render_power = 3;
          };
        };

        animations.enabled = true;

        dwindle.preserve_split = true;

        cursor = {
          # Unsichtbarer Mauszeiger auf manchen GPU/Monitor-Kombis -> Software-Cursor nutzen
          no_hardware_cursors = true;
          # Mauszeiger startet auf dem Hauptmonitor
          default_monitor = "DP-2";
        };

        # Logo/Anime-Wallpaper aus; das Wallpaper zeigt hyprpaper (von Stylix eingerichtet)
        misc = {
          force_default_wallpaper = 0;
          # FreeSync/VRR: 2 = nur für Vollbild-Apps (Spiele), auf dem Desktop aus
          vrr = 2;
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

      ---- Animationen ("verspielt": federnd, mit Popin) ----
      hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
      hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
      hl.curve("overshot",     { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })
      hl.curve("bouncy",       { type = "spring", mass = 1, stiffness = 180, damping = 14 })

      hl.animation({ leaf = "global",     enabled = true, speed = 10,  bezier = "default" })
      hl.animation({ leaf = "border",     enabled = true, speed = 5,   bezier = "easeOutQuint" })
      hl.animation({ leaf = "borderangle", enabled = true, speed = 60, bezier = "almostLinear", style = "loop" })
      hl.animation({ leaf = "windows",    enabled = true, speed = 5,   spring = "bouncy" })
      hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4,   spring = "bouncy", style = "popin 70%" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,   bezier = "easeOutQuint", style = "popin 70%" })
      hl.animation({ leaf = "fade",       enabled = true, speed = 3,   bezier = "almostLinear" })
      hl.animation({ leaf = "layers",     enabled = true, speed = 4,   bezier = "overshot", style = "slide" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 4,   bezier = "overshot", style = "slidevert" })

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
