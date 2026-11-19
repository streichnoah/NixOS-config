# Projekt-Umgebungen mit Nix

Statt alles global zu installieren, bekommt jedes Projekt eine eigene `flake.nix`.
Darin stehen genau die Versionen, die das Projekt braucht. direnv aktiviert sie automatisch beim `cd`.

## Beispiel: Python + Node

`flake.nix` im Projektordner:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          python312
          uv
          nodejs_22
          pnpm
        ];
        shellHook = ''
          echo "Dev-Shell aktiv"
        '';
      };
    };
}
```

Dann:

```bash
echo "use flake" > .envrc
direnv allow
```

Ab jetzt sind die Tools da, sobald du in den Ordner wechselst, auch im VS-Code-Terminal
(dank der direnv-Extension). Commit `flake.nix` und `flake.lock` mit dem Projekt.

## Vorlagen

```bash
nix flake init -t github:the-nix-way/dev-templates#python
nix flake init -t github:the-nix-way/dev-templates#node
nix flake init -t github:the-nix-way/dev-templates#java
```
