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

      # TODO: Server eintragen, danach reicht `ssh homeserver`
      # "homeserver" = {
      #   HostName = "192.168.1.10"; # oder Domain / öffentliche IP
      #   User = "noah";
      #   Port = 22;
      # };
    };
  };
}
