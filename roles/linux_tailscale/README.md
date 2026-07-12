# Tailscale

Installs and configures Tailscale on Debian/Ubuntu.

## Requirements

- Debian-family systems

## Role Variables

```yaml
tailscale_auth_key: "<vault>"
tailscale_run_up: true
tailscale_force_reauth: false
tailscale_state_file: /var/lib/tailscale/tailscaled.state
tailscale_up_args: []
```

## Example Playbook

```yaml
- name: Bootstrap Tailscale
  hosts: local_pi_nodes
  gather_facts: true
  roles:
    - role: linux_tailscale
```
