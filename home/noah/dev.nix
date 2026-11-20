# Entwicklungs- und Infrastruktur-Tools.
#
# Tipp: Für echte Projekte besser pro Projekt eine flake.nix mit devShell anlegen
# (siehe docs/DEVSHELLS.md). direnv lädt die Umgebung dann automatisch beim `cd`.
# Die Pakete hier sind die "immer verfügbare" Grundausstattung.
{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # Nix-Tooling
    nixd
    nixfmt
    nix-tree

    # Sprachen
    python3
    uv
    nodejs
    pnpm
    jdk21
    maven
    gradle
    dotnet-sdk

    # Container / IaC / Kubernetes
    docker-compose
    terraform
    opentofu
    ansible
    kubectl
    kubernetes-helm
    k9s

    # KI-Assistent im Terminal (`claude`), Login beim ersten Start über den Browser
    claude-code

    # CLI-Allrounder
    ripgrep
    fd
    jq
    yq-go
    tree
    httpie
  ];
}
