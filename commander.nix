{ config, pkgs, ... }:
{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.ssh.enableAskPassword = false;
  programs.gnupg.agent =
    {
      pinentryFlavor = "tty";
      enable = true;
      enableSSHSupport = true;
    };
  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.commander = {
    isNormalUser = true;
    uid = 1009;
    name = "commander";
    description = "system administration";
    createHome = true;
    home = "/home/commander";
    hashedPassword = "$6$irFKKFRDPP$H5EaeHornoVvWcKtUBj.29tPvw.SspaSi/vOPGc3GG2bW//M.ld3E7E3XCevJ6vn175A/raHvNIotXayvMqzz0";
    openssh.authorizedKeys.keys =
      [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGcZrafX+y1V7Q1lSZUSSR6R0ouIPuYL1KCAZw6kOsqe l33@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhzz/CAb74rLQkDF2weTCb0DICw1oyXNv6XmdLfEsT5 darthpjb@gmail.com"
      ];
    extraGroups = [ "wheel" "libvirtd" "vboxusers" "dialout" "disk" "networkManager" ]; # Enable ‘sudo’ for the user.
  };
}
