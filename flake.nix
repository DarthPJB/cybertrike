{
  description = "Cybertrike.org";

  inputs = {
    nixinate.url = "github:matthewcroughan/nixinate";
    agenix.url = "github:ryantm/agenix";
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = inputs@{ self, nixpkgs, agenix, nixinate, nixpkgs_unstable }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    apps.x86_64-linux = (inputs.nixinate.nixinate.x86_64-linux inputs.self).nixinate;
    nixosConfigurations = {
      RemoteWorker-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          ./openstack.nix
          {
            imports = [
              "${nixpkgs}/nixos/modules/virtualisation/openstack-config.nix"
            ];
            _module.args.nixinate = {
              host = "193.16.42.125";
              sshUser = "John88";
              substituteOnTarget = true;
              hermetic = true;
              buildOn = "remote";
            };
          }
        ];
      };
    };
  };
}
