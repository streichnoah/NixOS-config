{ ... }:
{
  programs.git = {
    enable = true;
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
