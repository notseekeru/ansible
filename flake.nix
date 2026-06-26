{
  description = "Ansible infra provisioning – Nix dev shell & tooling";

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
            # ── Ansible ecosystem ──────────────────────────────────
            ansible           # ansible, ansible-playbook, ansible-galaxy
            ansible-lint      # linting with modern rules
            molecule          # test framework

            # ── Python tooling ─────────────────────────────────────
            python3
            python3Packages.pip
            python3Packages.virtualenv

            # ── CLI helpers ────────────────────────────────────────
            yq
            jq
            tree
            gnugrep

            # ── SSH / connectivity ─────────────────────────────────
            openssh
            sshpass

            # ── Runtime dependencies ──────────────────────────────
            gnutar
            gzip
          ];

          # ── Environment ──────────────────────────────────────────
          shellHook = ''
            PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"

            export ANSIBLE_CONFIG="$PROJECT_ROOT/ansible.cfg"
            export ANSIBLE_ROLES_PATH="$PROJECT_ROOT/roles"
            export ANSIBLE_INVENTORY="$PROJECT_ROOT/inventories"
            export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_pass"

            # ── Pip install molecule Docker plugin ─────────────────
            VENV_DIR="$PROJECT_ROOT/.venv"
            if [ ! -d "$VENV_DIR" ]; then
              echo "📦 Creating .venv for molecule-plugins[docker] …"
              python3 -m venv "$VENV_DIR"
              "$VENV_DIR/bin/pip" install --quiet --upgrade pip
              "$VENV_DIR/bin/pip" install --quiet "molecule-plugins[docker]"
              echo "✅ Done"
            fi
            export PATH="$VENV_DIR/bin:$PATH"

            # ── Ansible Collections (install once) ─────────────────
            COLLECTION_DIR="$PROJECT_ROOT/collections"
            INSTALL_MARKER="$PROJECT_ROOT/.collections-installed"

            if [ ! -f "$INSTALL_MARKER" ]; then
              echo "📦 Installing Ansible collections …"
              ansible-galaxy collection install \
                community.general \
                ansible.posix \
                community.crypto \
                community.docker \
                --collections-path "$COLLECTION_DIR"
              echo "✅ Collections installed in $COLLECTION_DIR"
              touch "$INSTALL_MARKER"
            fi

            export ANSIBLE_COLLECTIONS_PATH="$COLLECTION_DIR"

            # ── Welcome ────────────────────────────────────────────
            echo ""
            echo "╔══════════════════════════════════════════════════╗"
            echo "║   🚀  Ansible Development Shell                 ║"
            echo "╠══════════════════════════════════════════════════╣"
            echo "║  $(ansible --version | head -1)"
            echo "║  $(ansible-lint --version)"
            echo "║  $(molecule --version | head -1)"
            echo "║                                                  "
            echo "║  Quick commands:                                 "
            echo "║    ansible-lint            # Lint all playbooks  "
            echo "║    molecule test -s default # Test a role        "
            echo "║    ansible-playbook ...    # Run a playbook      "
            echo "╚══════════════════════════════════════════════════╝"
            echo ""
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
