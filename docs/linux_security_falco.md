# Linux Security Falco Addendum

Reference date: 2026-06-06.

## Scope

Falco is added as a minimal host intrusion detection layer inside `roles/linux_security`.

The role now:

- adds the official Falco Debian/Ubuntu apt repository using a signed keyring
- installs the `falco` package with non-interactive apt settings
- enables the `falco` systemd unit
- starts the service on real hosts, while Molecule containers only verify enablement and package state

## Implementation Notes

- No deprecated apt-key flow is used.
- The repository is configured with `signed-by` and a dedicated keyring under `/usr/share/keyrings/`.
- Automatic Falcoctl rules follow-up is disabled by default to keep the role deterministic.
- The role remains toggleable through `linux_security_enable_falco`.

## Validation

Recommended checks:

```bash
cd roles/linux_security
molecule test -s default
ansible-lint
```

Host-level verification:

```bash
falco --version
systemctl is-enabled falco
systemctl is-active falco
```

## Operational Note

Falco depends on kernel event visibility. In constrained container test environments, service startup may be skipped or only partially verifiable. The role therefore treats Molecule as a smoke-test harness, not a full driver-in-kernel integration test.
