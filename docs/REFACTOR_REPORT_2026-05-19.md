# Refactor Report (2026-05-19)

## Scope

- Consolidated hardening roles into a single security role.
- Merged developer shell config into the Neovim role.
- Added Molecule suites per in-house role.
- Hardened CI to run lint, syntax, and Molecule.
- Parameterized personal values to avoid hard-coded identities.

## Role Map

- security_hardening: merged auto-dbpkg, pubkey, tailscale-sshd-conf, tailscale-ufw
- linux_neovim: includes dev-configs tasks and variables
- docker-compose-personal: unchanged name; now variable-driven
- tailscale: retained as install/bootstrap role
- geerlingguy.docker: vendor role untouched

## Key Changes

- playbooks now use roles blocks instead of import tasks for clarity.
- tailscale role now avoids re-authing when state exists and supports skipping `tailscale up` for tests.
- security_hardening exposes interface allow/deny lists for UFW and SSH allow users.
- linux_neovim now has toggles for bob install, dotfiles, and developer identity config.
- docker-compose-personal now asserts token presence when managing .env.
- Deprecated role shims remain to avoid breaking legacy references.

## CI and Tests

- GitHub Actions runs `yamllint`, `ansible-lint`, and syntax checks.
- Molecule runs for `linux_neovim` and `docker-compose-personal` only; tailscale-related roles are skipped in CI.
- Local Molecule runs are available for all roles.

## Future Scalability Notes

- Split security_hardening into subroles if more OS families or CIS profiles are added.
- Add a distro matrix for Debian 12, Ubuntu 24.04, and Debian Trixie once CI images are validated.
- Consider an internal collection for role versioning and release management.
