# Security Hardening

Baseline security hardening for Debian/Ubuntu nodes. Includes:

- Unattended upgrades and baseline packages
- Authorized keys management
- SSH hardening
- UFW rules (Tailscale-first SSH)

## Requirements

- community.general
- ansible.posix

## Role Variables

```yaml
security_enable_baseline: true
security_enable_authorized_keys: true
security_enable_sshd_hardening: true
security_enable_ufw: true
security_disable_cloud_init_ssh_override: true
security_disable_avahi: true

security_authorized_key_user: "{{ ansible_user_id | default(ansible_user) }}"
security_authorized_key_file: authorized_keys.pub

security_sshd_listen_address: "0.0.0.0"
security_sshd_allow_users:
  - "{{ ansible_user_id | default(ansible_user) }}"
security_sshd_permit_root_login: "no"
security_sshd_password_authentication: "no"
security_sshd_pubkey_authentication: "yes"
security_sshd_max_auth_tries: 3

security_ufw_ssh_port: "{{ ansible_port | default(22) }}"
security_ufw_allow_interfaces:
  - tailscale0
security_ufw_deny_interfaces:
  - eth0
  - wlan0
```

## Example Playbook

```yaml
- name: Debian Hardening
  hosts: tailscale_pi_nodes
  gather_facts: true
  roles:
    - role: security_hardening
```
