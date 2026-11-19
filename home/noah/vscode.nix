# VS Code mit deklarativ verwalteten Extensions.
# Weitere Extensions kannst du zusätzlich ganz normal in VS Code installieren.
{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Nix
        jnoortheen.nix-ide
        mkhl.direnv

        # Python
        ms-python.python
        ms-python.debugpy

        # JS/TS
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode

        # Java / C#
        redhat.java
        ms-dotnettools.csharp

        # Infra / IaC
        hashicorp.terraform
        redhat.ansible
        redhat.vscode-yaml
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools

        # Remote-Entwicklung direkt auf dem Server
        ms-vscode-remote.remote-ssh
      ];

      userSettings = {
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
        "editor.fontLigatures" = true;
        "editor.formatOnSave" = true;
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "window.titleBarStyle" = "custom";

        # Nix Language Server
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings".nixd.formatting.command = [ "nixfmt" ];
      };
    };
  };
}
