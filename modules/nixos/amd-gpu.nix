# AMD Radeon RX 7800 XT - Open-Source-Treiber (amdgpu + Mesa/RADV), kein Extra-Treiber nötig
{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # für 32-Bit-Anwendungen/Spiele
  };

  # amdgpu früh laden -> korrekte Auflösung schon bei der LUKS-Abfrage
  hardware.amdgpu.initrd.enable = true;

  environment.systemPackages = with pkgs; [
    lact # GUI für GPU-Infos, Lüfterkurven, Taktraten
    nvtopPackages.amd # GPU-Auslastung im Terminal
  ];
  systemd.packages = [ pkgs.lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
}
