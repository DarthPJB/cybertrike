# This is the general configuration for all of my systems; anything in here will be found on every possible system I have.

{ inputs, config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./modifier_imports/flakes.nix
      ./users/commander.nix
      ./locale/en_gb.nix
      ./environments/sshd.nix
      ./environments/tools.nix
    ];
  nix.settings.trusted-users = [ "root" "commander" ];
  nixpkgs.config =
    {
      allowUnfree = true;
    };

}
