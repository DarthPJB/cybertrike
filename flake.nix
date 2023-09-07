{
  description = "Cybertrike.org";

  inputs = {
    nixinate.url = "github:matthewcroughan/nixinate";
    agenix.url = "github:ryantm/agenix";
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
  };

  outputs = inputs@{ self, nixpkgs, agenix, nixinate, nixpkgs_unstable, simple-nixos-mailserver}: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    apps.x86_64-linux = (inputs.nixinate.nixinate.x86_64-linux inputs.self).nixinate;
    nixosConfigurations = {
      RemoteWorker-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          simple-nixos-mailserver.nixosModule
          {
            mailserver = {
              fqdn = "mail.cybertrike.org";
              domains = [ "mail.cybertrike.org" ];
              enable = true;
              # A list of all login accounts. To create the password hashes, use
            # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
            loginAccounts = {
            "John88@mail.cybertrike.org" = {
                hashedPasswordFile = ./password.file;
                aliases = ["postmaster@mail.cybertrike.org"];
            };
            };

            # Use Let's Encrypt certificates. Note that this needs to set up a stripped
            # down nginx and opens port 80.
            certificateScheme = "acme-nginx";
        };
          }
          agenix.nixosModules.default
          ./openstack.nix
          ./darthpjb.nix
          {
            security.acme.acceptTerms = true;
            security.acme.defaults.email = "security@mail.cybertrike.org";
            environment.systemPackages = [
                nixpkgs.legacyPackages.x86_64-linux.btop
                nixpkgs.legacyPackages.x86_64-linux.tmux
                nixpkgs.legacyPackages.x86_64-linux.neovim
            ];
            imports = [
              "${nixpkgs}/nixos/modules/virtualisation/openstack-config.nix"
            ];
            _module.args.nixinate = {
              host = "193.16.42.125";
              sshUser = "John88";
              substituteOnTarget = true;
              hermetic = true;
              buildOn = "local";
            };
          }
        ];
      };
    };
  };
}
