{ webroot }: { config, lib, pkgs, ... }:
{
    imports = [ ./openstack.nix ];
  services.nginx.enable = true;
  services.nginx.virtualHosts."cybertrike.org" = {
    addSSL = true;
    enableACME = true;
    root = webroot;
  };
}
