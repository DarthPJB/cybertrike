{ config, pkgs, lib, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 22 1108 ];
  services.openssh.settings.PermitRootLogin = lib.mkForce "no";
  services.openssh.settings.PasswordAuthentication = false;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 1108 ];
  networking.firewall.allowedUDPPorts = [ ];
}
