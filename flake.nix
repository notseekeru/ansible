{
  description = "Ansible infra provisioning – Nix dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "ansible-dev";

          packages = with pkgs; [
            # Python (needed on NixOS to create/manage .venv)
            python3
            python3Packages.pip
            python3Packages.virtualenv

            # System tools
            openssh
            sshpass
            gnutar
            gzip
            yq
            jq
            tree
          ];

          shellHook = ''
            PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
            export ANSIBLE_CONFIG="$PROJECT_ROOT/ansible.cfg"
            export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_pass"
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
