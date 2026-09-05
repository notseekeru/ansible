# Tailscale

Installs and configures Tailscale on Debian/Ubuntu.

## Requirements

- Debian-family systems

## Role Variables

```yaml
linux_tailscale_auth_key: "<value>"  # from Infisical (group_vars/secrets.yml)
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
