# Englisches System, deutsche Formate & Tastatur
{ ... }:
{
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Tastatur in der TTY-Konsole (u. a. für die LUKS-Passwortabfrage beim Boot)
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";
}
