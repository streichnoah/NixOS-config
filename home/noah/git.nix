{ config, ... }:
{
  programs.git = {
    enable = true;

    # Commits/Tags mit dem SSH-Key signieren -> "Verified" auf GitHub.
    # Der private Key bleibt in ~/.ssh (nie ins Repo), der Agent (gcr) hält die Passphrase.
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
      # Öffentliche Keys, deren Signaturen `git log --show-signature` als gültig anzeigt
      # (öffentlicher Key = kein Geheimnis, darf ins Repo)
      allowedSigners = ''
        streich.noah@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwwq7KFHxEbVnK7HIZ+lmcLFulmuSPWN70jc4hIyMpb noah@nixos-pc
      '';
    };
    settings = {
      user = {
        name = "streichnoah";
        email = "streich.noah@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.gh.enable = true; # GitHub CLI: `gh auth login`
  programs.lazygit.enable = true;
}
