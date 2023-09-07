{ config, lib, pkgs, modulesPath, ... }:
{
  nix = {
    settings.trusted-users = [ "root" "John88" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # Set your time zone.
  time.timeZone = "Europe/London";

  #  Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 1108 22 ];
  services.openssh.permitRootLogin = lib.mkForce "no";
  services.openssh.passwordAuthentication = false;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 1108 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  # Configure keymap in X11
  services.xserver.layout = "gb";
  system.stateVersion = "22.11";
  services.openssh.ports = [ 22 ];
}
