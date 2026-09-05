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
│   ├── vault.yml               # Infisical-managed secret vars (gitignored)
│   └── vault.yml.example
├── inventories/
│   ├── home.ini.example        # Template for local/Tailscale nodes
│   ├── droplets.ini            # DigitalOcean droplet IPs (gitignored)
│   └── droplets.ini.example    # Template
├── playbooks/
│   ├── site.yml                # Bootstrap homelab: Tailscale → linux_security
│   ├── linux_dev_configs.yml   # Dev environment
│   └── linux_docker.yml        # Docker CE (Infisical CLI runs via site.yml)
├── docs/
│   ├── IMPORTANT_NOTES.md
│   └── linux_security_falco.md
├── collections/                # Locally installed Galaxy collections (gitignored)
└── roles/
    ├── linux_security/         # CIS Level 1 hardening
    ├── linux_dev_configs/       # Neovim + dev tooling
    ├── linux_tailscale/       # Tailscale mesh agent
    ├── linux_infisical/        # Infisical CLI (install-only)
    ├── linux_nix/              # Nix package manager + flakes
    └── geerlingguy.docker/     # Docker CE (external)
```

## How It Works

The bootstrap playbook (`site.yml`) solves the chicken-and-egg problem of securing a machine before you can safely expose it:

1. Connect via local IP / root SSH, install Tailscale, authenticate with pre-shared key
2. Capture the new Tailscale IPv4, switch `ansible_host` mid-run
3. Run `meta: clear_host_errors` + fresh `setup` to flush the connection cache
4. Apply `linux_security` — now safely inside the WireGuard tunnel

After this run, SSH port 22 is blocked on `eth0`/`wlan0` and only reachable through `tailscale0`. Droplet flow is identical but connects via root on the public IP and supports `bootstrap_tailscale_enabled: false` for nodes that don't need the mesh.

## Roles

### linux_security

CIS Level 1 hardening. All components toggleable via role defaults.

| Component          | What it does                                                                                   |
| ------------------ | ---------------------------------------------------------------------------------------------- |
| User creation      | Creates local non-root user with sudo, home dir, .ssh dir                                      |
| SSH hardening      | Key-only auth, no root, MaxAuthTries=3, no X11/forwarding                                      |
| UFW firewall       | Default deny, allow on tailscale0, deny on eth0/wlan0, mask avahi                              |
| Automatic updates  | unattended-upgrades installed and enabled                                                      |
| Authorized keys    | Deploys from `files/authorized_keys.pub`                                                       |
| Cloud-init cleanup | Removes SSH override configs                                                                   |
| Fail2Ban           | sshd jail with UFW ban action, configurable bantime/findtime/maxretry                          |
| Falco              | Host intrusion detection (disabled by default — overkill for tailscale-only single-user nodes) |
| Goss               | System validation binary (goss + dgoss) for ad-hoc and CI health checks                        |

```yaml
# example overrides
linux_security_enable_ufw: false
linux_security_ufw_tailscale_enabled: true # opens SSH only on tailscale0
linux_security_sshd_max_auth_tries: 3
```

### linux_dev_configs

Delivers a complete terminal dev environment on any target:

- Neovim 0.12.3 via [bob](https://github.com/MordechaiHadad/bob) version manager
- LazyVim dotfiles pulled from GitHub
- zsh shell with aliases, custom .zshrc
- tmux, lazygit, ripgrep, fzf, fd-find, tree-sitter
- Git config + github token from Infisical env (`GITHUB_TOKEN`)

### linux_tailscale

Installs and authenticates Tailscale. Supports `linux_tailscale_force_reauth` for re-auth flows. Auth key comes from Infisical (secret vars).

### geerlingguy.docker

Community-standard Docker role. CE + CLI + containerd + Buildx + compose plugin.

### linux_infisical

Deploys the [Infisical](https://infisical.com) CLI from the pinned release tarball (`Infisical/cli` GitHub assets). Idempotent install-only — no login, no persistent session, no credentials deployed to the node.

```yaml
# example override
linux_infisical_version: latest # or pinned like 0.43.118
```

### linux_nix

Installs [Nix](https://nixos.org) via the official multi-user (daemon) installer and
enables Flakes + `nix-command` system-wide at `/etc/nix/nix.conf`. System-only — no
per-user group or profile setup. Supports uninstall (`linux_nix_remove`).

## Playbooks

| Playbook                | What it does                                     | Run against         |
| ----------------------- | ------------------------------------------------ | ------------------- |
| `site.yml`              | Bootstrap: Tailscale install → security lockdown | `home.ini`          |
| `linux_dev_configs.yml` | Dev environment                                  | Tailscale inventory |
| `linux_docker.yml`      | Docker CE                                        | Tailscale inventory |

Both bootstrap playbooks support `bootstrap_tailscale_enabled: false` to skip mesh setup and use open SSH firewall rules instead.

## Security

### Principles

- No password auth, no root login, no X11 forwarding
- Default-deny firewall on public interfaces
- No secrets committed — values live in Infisical, injected at deploy

### CIS Level 1 controls

- SSH PermitRootLogin: disabled
- SSH MaxAuthTries: 3
- SSH PubkeyAuthentication: yes, PasswordAuthentication: no
- UFW default incoming policy: deny
- Automatic updates: enabled
- Fail2Ban sshd jail: enabled (UFW ban action)

### Secret variables

`group_vars/*.yml` hold plain (non-encrypted) Ansible variables. The secret
_values_ are never committed — Infisical exports them as environment variables at
deploy time (`infisical run --env=dev`), and vars files/role defaults read them
via `lookup('env', ...)`.

The gitignored `group_vars/vault.yml` is a vars-file that binds secret values
into Ansible variables used across playbooks. (Name is historical — it is not
Ansible Vault.)
Per-host-group grouping lives in tracked vars, e.g. `group_vars/droplets.yml`
composes the droplet-specific key var-of-var:

```yaml
linux_tailscale_auth_key: "{{ linux_tailscale_auth_key_droplet }}"
```

Role defaults source secret values from the environment at runtime, e.g.:

```yaml
linux_dev_configs_github_token: "{{ lookup('env', 'GITHUB_TOKEN') | default('') }}"
```

## Getting Started

### Option A — Nix + direnv (recommended)

```bash
git clone <repo> && cd ansible
direnv allow                         # drops into Nix dev shell + .venv
make venv                            # installs ansible-core, molecule, collections
# Point direnv/ansible at Infisical for secret env vars (no ansible-vault used)
# infisical login && infisical init  # one-time, per project

# Bootstrap a Pi
make strap-pi
# Bootstrap a DigitalOcean droplet (same playbook, droplets inventory)
make strap-pi INVENTORY=inventories/droplets.ini
```

### Option B — Manual (no Nix)

```bash
git clone <repo> && cd ansible
python3 -m venv .venv && source .venv/bin/activate
pip install ansible-core molecule "molecule-plugins[docker]" ansible-lint
ansible-galaxy collection install community.general ansible.posix community.crypto community.docker
# infisical login && infisical init   # one-time; secrets come from Infisical env
```

### Make targets

```bash
make venv             # Create venv + install deps + collections
make new-role NAME=linux_foo [FORM=install|features]  # scaffold a role
make lint             # ansible-lint
make molecule         # Molecule test all roles (requires Docker)
make strap-pi         # Bootstrap Pi: local IP → Tailscale → harden
make tailscale-pi     # Post-bootstrap: security audit via Tailscale
make tailscale-pi-dev    # Dev environment
make tailscale-pi-docker  # Docker
make strap-pi INVENTORY=inventories/droplets.ini  # Bootstrap droplet via site.yml
```

### Creating a new role

Scaffold a role from the committed house template (excluded from lint/molecule):

```bash
make new-role NAME=linux_topgrade             # install/uninstall split
make new-role NAME=linux_mymod FORM=features  # multi-feature / hardening split
```

Then fill `tasks/`, tighten `defaults/`, update `meta` tags + this README, and
make `molecule/verify.yml` assert the role's real effect. For scaffold tweaks,
edit `_role_templates/` so future roles stay current.

> **Inventory note:** `home.ini` is the bootstrap inventory. Use the example
> in `inventories/home.ini.example` to create it locally.

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
