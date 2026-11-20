# Noahs oh-my-zsh-Theme. Eingebunden über programs.zsh.oh-my-zsh.custom (home/noah/shell.nix).
#
# Farben kommen aus der Terminal-Palette (Stylix: blue/magenta = Catppuccin Blue/Mauve).
# Zeile 1: aktueller Ordner (blau) + Git-Branch (lila, * = ungespeicherte Änderungen),
#          rechts die Uhrzeit
# Zeile 2: Pfeil (lila = letzter Befehl ok, rot = Fehler)

# Git (wird von git_prompt_info zusammengesetzt: PREFIX + branch + DIRTY/CLEAN + SUFFIX)
ZSH_THEME_GIT_PROMPT_PREFIX="  %F{magenta}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{magenta}%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%B%F{blue}%1~%f%b$(git_prompt_info)
%B%(?.%F{magenta}.%F{red})❯%f%b '

# Uhrzeit rechts in Zeile 1 (\e[1A = eine Zeile hoch, \e[1B = wieder runter)
RPROMPT=$'%{\e[1A%}%F{8} %T%f%{\e[1B%}'
