# SSH-Client-Config. Den Key erzeugst du nach der Installation mit:
#   ssh-keygen -t ed25519 -C "noah@nixos-pc"
# und kopierst ihn auf den Server mit:
#   ssh-copy-id -i ~/.ssh/id_ed25519.pub <user>@<server>
# Private Keys gehören NIE ins Repo - nur diese Config.
#
# Den SSH-Agent stellt gnome-keyring bereit (modules/nixos/hyprland.nix);
# dank addKeysToAgent musst du die Passphrase nur einmal pro Sitzung eingeben.
{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Private Ergänzungen, die NICHT ins öffentliche Repo gehören (z. B. Server-Adressen).
    # Die Dateien legst du von Hand an, sie werden nicht versioniert.
    includes = [ "~/.ssh/config.d/*" ];

    # Freiform: Schlüssel = Host-Pattern, Werte = OpenSSH-Direktiven (siehe `man ssh_config`)
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "github.com" = {
        User = "git";
      };

      # Eigener Server: `ssh server`. Die Adresse (HostName) steht privat in
      # ~/.ssh/config.d/server, damit sie nicht im öffentlichen Repo landet:
      #   Host server
      #     HostName <IP oder Domain>
      "server" = {
        User = "noah";
      };
    };
  };
}
