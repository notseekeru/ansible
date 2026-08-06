# Tailscale

Installs and configures Tailscale on Debian/Ubuntu.

## Requirements

- Debian-family systems

## Role Variables

```yaml
tailscale_auth_key: "<vault>"  # unprefixed: defined in group_vars/vault.yml
linux_tailscale_run_up: true
linux_tailscale_force_reauth: false
linux_tailscale_state_file: /var/lib/tailscale/tailscaled.state
linux_tailscale_up_args: []
```

## Example Playbook

```yaml
- name: Bootstrap Tailscale
  hosts: local_pi_nodes
  gather_facts: true
  roles:
    - role: linux_tailscale
```
