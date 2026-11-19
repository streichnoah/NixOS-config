{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Noah";
        # TODO: E-Mail eintragen (oder GitHub-noreply-Adresse:
        #   <id>+streichnoah@users.noreply.github.com, findest du unter
        #   GitHub -> Settings -> Emails)
        # email = "...";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.gh.enable = true; # GitHub CLI: `gh auth login`
  programs.lazygit.enable = true;
}
