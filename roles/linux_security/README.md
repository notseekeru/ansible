# Linux Security

Baseline security hardening for Debian/Ubuntu nodes. Includes:

- Unattended upgrades and baseline packages
- Local user creation (non-root, sudo, home dir, .ssh dir)
- Authorized keys management
- SSH hardening
- UFW rules (Tailscale-first SSH)
- Fail2Ban intrusion prevention
- Falco host intrusion detection
- Goss system validation

## Requirements

- community.general
- ansible.posix

## Role Variables

```yaml
# User creation
linux_security_enable_user_creation: true
linux_security_user_name: "seeker"
linux_security_user_comment: "System Administrator"
linux_security_user_groups:
  - sudo

# Baseline
linux_security_enable_baseline: true
linux_security_enable_authorized_keys: true
linux_security_enable_sshd_hardening: true
linux_security_enable_ufw: true
linux_security_enable_falco: true
linux_security_disable_cloud_init_ssh_override: true
linux_security_disable_avahi: true

linux_security_authorized_key_user: "seeker"
linux_security_authorized_key_file: authorized_keys.pub

linux_security_sshd_listen_address: "0.0.0.0"
linux_security_sshd_allow_users:
  - "seeker"
linux_security_sshd_permit_root_login: "no"
linux_security_sshd_password_authentication: "no"
linux_security_sshd_pubkey_authentication: "yes"
linux_security_sshd_max_auth_tries: 3

linux_security_ufw_ssh_port: "{{ ansible_port | default(22) }}"
linux_security_ufw_allow_interfaces:
  - tailscale0
linux_security_ufw_deny_interfaces:
  - eth0
  - wlan0
linux_security_ufw_default_incoming_policy: deny

# Fail2Ban
linux_security_enable_fail2ban: true
linux_security_fail2ban_ignore_ip:
  - 127.0.0.1/8
linux_security_fail2ban_bantime: 3600
linux_security_fail2ban_findtime: 600
linux_security_fail2ban_maxretry: 3

# Falco
linux_security_enable_falco: true
linux_security_falco_key_url: https://falco.org/repo/falcosecurity-packages.asc
linux_security_falco_package_name: falco
linux_security_falco_service_name: falco

# Goss
linux_security_enable_goss: true
linux_security_goss_version: "v0.4.9"
```

## Example Playbook

```yaml
- name: Debian Hardening
  hosts: tailscale_pi_nodes
  gather_facts: true
  roles:
    - role: linux_security
```
