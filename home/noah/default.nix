# Home Manager: alles, was zum Benutzer "noah" gehört (Dotfiles, User-Programme)
{ username, ... }:
{
  imports = [
    ./hyprland.nix
    ./desktop-tools.nix
    ./terminal.nix
    ./shell.nix
    ./git.nix
    ./ssh.nix
    ./vscode.nix
    ./dev.nix
    ./apps.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    # NICHT ändern nach der Installation (gleicher Wert wie system.stateVersion)
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
