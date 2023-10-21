{ webroot }: { config, lib, pkgs, ... }:
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."cybertrike.org" = {
    addSSL = true;
    enableACME = true;
    root = webroot;
  };
}
