{ config, pkgs, ... }:
{
  nix = {
    settings.trusted-users = [ "root" "commander" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
