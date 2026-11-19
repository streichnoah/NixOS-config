{ ... }:
{
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
