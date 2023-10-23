{
  description = "Cybertrike.org";

  inputs = {
    nixinate.url = "github:matthewcroughan/nixinate";
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
  };

  outputs = inputs@{ self, nixpkgs, agenix, nixinate, simple-nixos-mailserver }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      webroot = "${self}/webroot";
    in
    {
      formatter.x86_64-linux = pkgs.nixpkgs-fmt;
      apps.x86_64-linux = (inputs.nixinate.nixinate.x86_64-linux inputs.self).nixinate;
      devShell.x86_64-linux =
        pkgs.mkShell {
          buildInputs = with pkgs; [ figlet tmux ];
          shellHook = ''
            # Session Name
            session="project-env-sh"

            # Check if the session exists, discarding output
            # We can check $? for the exit status (zero for success, non-zero for failure)
            tmux has-session -t $session 2>/dev/null

            if [ $? != 0 ]; then
                # Start New Session with our name
                tmux new-session -d -s $session

                # Name first Window and start zsh
                tmux rename-window -t 0 'Main'
                tmux send-keys -t 'Main' 'nix flake show' C-m
                tmux send-keys -t 'Main' 'clear' C-m

                # Create and setup pane for btop
                tmux split-window -h
                tmux rename-window 'btop'
                tmux send-keys -t 'btop' 'ssh -t commander@193.16.42.125 btop' C-m

                tmux select-pane -t 0

                # Create and setup pane for btop
                tmux split-window -v
                tmux rename-window 'ssh'
                tmux send-keys -t 'ssh' 'ssh commander@193.16.42.125' C-m

                tmux select-pane -t 0
            fi
            tmux attach-session -t $session'';
        };
      nixosConfigurations = {
        obs-box = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules = [
              ./config/users/commander.nix
              ./config/configuration.nix
              ./obs-box.nix
              ./config/environments/i3wm_darthpjb.nix
              ./config/environments/video_call_streaming.nix
              ./config/modifier_imports/zfs.nix
              {
                networking.firewall.allowedTCPPorts = [ 6666 8080 6669 ];
                networking.firewall.allowedUDPPorts = [ 6666 ];
                _module.args.nixinate = {
                  host = "192.168.0.186";
                  sshUser = "commander";
                  substituteOnTarget = true;
                  hermetic = true;
                  buildOn = "remote";
                };
              }
            ];
          };
        cybertrike-2 = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules = [
              ./config/users/commander.nix
              ./ethannet/configuration.nix
              ./config/configuration.nix
              {
                networking.firewall.allowedTCPPorts = [ 6666 8080 6669 ];
                networking.firewall.allowedUDPPorts = [ 6666 ];
                _module.args.nixinate = {
                  host = "149.5.115.135";
                  sshUser = "commander";
                  substituteOnTarget = true;
                  hermetic = true;
                  buildOn = "remote";
                };
              }
            ];
          };
        cybertrike-1 = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules = [
              simple-nixos-mailserver.nixosModule
              {
                mailserver = {
                  fqdn = "mail.cybertrike.org";
                  domains = [ "mail.cybertrike.org" "cybertrike.org" ];
                  enable = true;
                  # A list of all login accounts. To create the password hashes, use
                  # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
                  loginAccounts = {
                    "john.bargman@cybertrike.org" = {
                      hashedPasswordFile = "${self}/password.file";
                      aliases = [ "postmaster@mail.cybertrike.org" "postmaster@cybertrike.org" ];
                    };
                  };
                  certificateScheme = "acme-nginx";
                };
              }
              agenix.nixosModules.default
              ./config/machines/openstack/openstack.nix
              (import ./website.nix { inherit webroot; })
              ./config/users/commander.nix
              {
                security.acme = {
                  acceptTerms = true;
                  defaults.email = "security@mail.cybertrike.org";
                };
                environment.systemPackages = [
                  pkgs.btop
                  pkgs.tmux
                  pkgs.neovim
                ];
                imports = [
                  "${nixpkgs}/nixos/modules/virtualisation/openstack-config.nix"
                ];
                _module.args.nixinate = {
                  host = "193.16.42.125";
                  sshUser = "commander";
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
