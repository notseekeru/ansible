# Homelab Infrastructure as Code

Ansible automation for Debian-based homelab and VPS servers. Provisions bare-metal to hardened in one pass using a Tailscale connection-migration pattern — no open ports on public interfaces after bootstrap.

[![Ansible](https://img.shields.io/badge/ansible-2.21.1-blue?logo=ansible)](https://docs.ansible.com/)
[![Molecule](https://img.shields.io/badge/molecule-26.4.0-blueviolet?logo=docker)](https://github.com/ansible-community/molecule)
[![Ansible Lint](https://img.shields.io/badge/ansible--lint-26.4.0-green)](https://github.com/ansible/ansible-lint)
[![Python](https://img.shields.io/badge/python-3.13-blue?logo=python)](https://python.org)
[![CIS](https://img.shields.io/badge/CIS-Level%201-orange)](https://www.cisecurity.org/benchmark/operating_systems)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![CI](https://github.com/notseekeru/ansible/actions/workflows/ansible-ci.yml/badge.svg)](https://github.com/notseekeru/ansible/actions)

## Project Structure

```
.
├── ansible.cfg
├── makefile
├── flake.nix                   # Nix dev shell (optional)
├── .envrc                      # direnv — auto-sources venv + Nix
├── group_vars/
│   ├── vault.yml               # Encrypted (gitignored)
│   └── vault.yml.example
├── inventories/
│   ├── home.ini.example        # Template for local/Tailscale nodes
│   ├── droplets.ini            # DigitalOcean droplet IPs (gitignored)
│   └── droplets.ini.example    # Template
├── playbooks/
│   ├── site.yml                # Bootstrap homelab: Tailscale → linux_security
│   ├── droplet.yml             # Bootstrap droplet: same pattern, droplet-optimized
│   ├── linux_neovim.yml        # Dev environment
│   └── linux_docker.yml        # Docker CE
├── docs/
│   ├── IMPORTANT_NOTES.md
│   └── linux_security_falco.md
├── collections/                # Locally installed Galaxy collections (gitignored)
└── roles/
    ├── linux_security/         # CIS Level 1 hardening
    ├── linux_neovim/           # Neovim + dev tooling
    ├── tailscale/              # Tailscale mesh agent
    └── geerlingguy.docker/     # Docker CE (external)
```

## How It Works

The bootstrap playbook (`site.yml` / `droplet.yml`) solves the chicken-and-egg problem of securing a machine before you can safely expose it:

1. Connect via local IP / root SSH, install Tailscale, authenticate with pre-shared key
2. Capture the new Tailscale IPv4, switch `ansible_host` mid-run
3. Run `meta: clear_host_errors` + fresh `setup` to flush the connection cache
4. Apply `linux_security` — now safely inside the WireGuard tunnel

After this run, SSH port 22 is blocked on `eth0`/`wlan0` and only reachable through `tailscale0`. Droplet flow is identical but connects via root on the public IP and supports `bootstrap_tailscale_enabled: false` for nodes that don't need the mesh.

## Roles

### linux_security

CIS Level 1 hardening. All components toggleable via role defaults.

| Component          | What it does                                                             |
| ------------------ | ------------------------------------------------------------------------ |
| User creation      | Creates local non-root user with sudo, home dir, .ssh dir                |
| SSH hardening      | Key-only auth, no root, MaxAuthTries=3, no X11/forwarding                |
| UFW firewall       | Default deny, allow on tailscale0, deny on eth0/wlan0, mask avahi        |
| Automatic updates  | unattended-upgrades installed and enabled                                |
| Authorized keys    | Deploys from `files/authorized_keys.pub`                                 |
| Cloud-init cleanup | Removes SSH override configs                                             |
| Fail2Ban           | sshd jail with UFW ban action, configurable bantime/findtime/maxretry    |
| Falco              | Host intrusion detection from the upstream signed Debian/Ubuntu apt repo |
| Goss               | System validation binary (goss + dgoss) for ad-hoc and CI health checks  |

```yaml
# example overrides
linux_security_enable_ufw: false
linux_security_ufw_tailscale_enabled: true   # opens SSH only on tailscale0
linux_security_sshd_max_auth_tries: 3
```

### linux_neovim

Delivers a complete terminal dev environment on any target:

- Neovim 0.12.3 via [bob](https://github.com/MordechaiHadad/bob) version manager
- LazyVim dotfiles pulled from GitHub
- zsh shell with aliases, custom .zshrc
- tmux, lazygit, ripgrep, fzf, fd-find, tree-sitter
- Git config + GitHub CLI with vault-stored token

### tailscale

Installs and authenticates Tailscale. Supports `tailscale_force_reauth` for re-auth flows. Auth key comes from Ansible Vault.

### geerlingguy.docker

Community-standard Docker role. CE + CLI + containerd + Buildx + compose plugin.

## Playbooks

| Playbook           | What it does                                      | Run against          |
| ------------------ | ------------------------------------------------- | -------------------- |
| `site.yml`         | Bootstrap: Tailscale install → security lockdown  | `home_static.ini`    |
| `droplet.yml`      | Bootstrap: same pattern, tuned for DigitalOcean   | `droplets.ini`       |
| `linux_neovim.yml` | Dev environment                                   | Tailscale inventory  |
| `linux_docker.yml` | Docker CE                                         | Tailscale inventory  |

Both bootstrap playbooks support `bootstrap_tailscale_enabled: false` to skip mesh setup and use open SSH firewall rules instead.

## Security

### Principles

- No password auth, no root login, no X11 forwarding
- Default-deny firewall on public interfaces
- Falco on supported Debian/Ubuntu hosts through the official signed repo
- All secrets in Ansible Vault, never committed

### CIS Level 1 controls

- SSH PermitRootLogin: disabled
- SSH MaxAuthTries: 3
- SSH PubkeyAuthentication: yes, PasswordAuthentication: no
- UFW default incoming policy: deny
- Automatic updates: enabled
- Fail2Ban sshd jail: enabled (UFW ban action)
- Falco service: enabled on host

### Secrets template

```yaml
# group_vars/vault.yml
tailscale_auth_key: tskey-auth-...
tailscale_auth_key_droplet: tskey-auth-...-droplet
tailscale_molecule_auth_key: ...
github_token: ghp_...
CLOUDFLARE_TOKEN: ...
slack_webhook: ...
```

## Getting Started

### Option A — Nix + direnv (recommended)

```bash
git clone <repo> && cd ansible
direnv allow                         # drops into Nix dev shell + .venv
make venv                            # installs ansible-core, molecule, collections
cp group_vars/vault.yml.example group_vars/vault.yml
echo "${your-vault-pass}" > ~/.vault_pass && chmod 600 ~/.vault_pass

# Bootstrap a Pi
make strap-pi
# Bootstrap a DigitalOcean droplet
make ping-droplet                    # test connectivity first
make strap-droplet
```

### Option B — Manual (no Nix)

```bash
git clone <repo> && cd ansible
python3 -m venv .venv && source .venv/bin/activate
pip install ansible-core molecule "molecule-plugins[docker]" ansible-lint
ansible-galaxy collection install community.general ansible.posix community.crypto community.docker
cp group_vars/vault.yml.example group_vars/vault.yml
echo "${your-vault-pass}" > ~/.vault_pass && chmod 600 ~/.vault_pass
```

### Make targets

```bash
make venv             # Create venv + install deps + collections
make lint             # ansible-lint
make molecule         # Molecule test all roles (requires Docker)
make strap-pi         # Bootstrap Pi: local IP → Tailscale → harden
make tailscale-pi     # Post-bootstrap: security audit via Tailscale
make tailscale-pi-neovim  # Dev environment
make tailscale-pi-docker  # Docker
make ping-droplet     # Connectivity check for droplets
make strap-droplet    # Bootstrap droplet via root SSH
```

> **Inventory note:** `home_static.ini` and `home_tailscale.ini` are gitignored (`*.ini`). Use the example in `inventories/home.ini.example` to create them locally.

## Engineering Decisions

**Tailscale vs VPN.** Zero-config NAT traversal with built-in ACLs beats manual WireGuard key management for a homelab. Trade-off: Tailscale control plane dependency.

**CIS Level 1 not Level 2.** Level 2 kernel/filesystem hardening breaks Docker and ruins convenience for mixed-use servers. Level 1 is the pragmatic baseline.

**Dual inventory.** Static inventory is first-contact only. Everything else routes through the mesh. Prevents targeting an un-bootstrapped node.

**Connection migration.** `set_fact: ansible_host` + `meta: clear_host_errors` mid-playbook is unusual, but it's the cleanest way to join a mesh and route through it in a single idempotent run.

## Verification

```bash
ssh seeker@local_ip -p 22                      # should fail (UFW)
ssh seeker@<tailscale_ip> -p 22                # should succeed
ssh seeker@<ts_ip> -o PasswordAuthentication=yes  # should fail
sudo ufw status verbose                        # default deny, tailscale0 allow
sudo grep -E "^(PermitRootLogin|PasswordAuth|MaxAuthTries)" /etc/ssh/sshd_config
tailscale status                               # connected
```

Full runbook in `docs/IMPORTANT_NOTES.md`.

## Roadmap

- GitHub Actions CI for ansible-lint (✅ working)
- Molecule tests in CI (Docker-in-Docker complexity, pending)
- CD for one-click deploys from main branch (pending CI)

---

## License

MIT. See [LICENSE](LICENSE).

---
