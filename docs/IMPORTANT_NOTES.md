# Important Notes

Theres 2 Playbooks, Because of Tailscale Constraint

## Quick Verification Checklist

Run these after provisioning a new node:

1. ansible-playbook -i inventories/hosts.ini playbooks/deb-bootstrap.yml --check --diff --limit <host>
2. ansible-playbook -i inventories/hosts.ini playbooks/deb-bootstrap.yml --limit <host>
3. ansible-playbook -i inventories/hosts.ini playbooks/deb-hardening.yml --check --diff --limit <host>
4. ansible-playbook -i inventories/hosts.ini playbooks/deb-hardening.yml --limit <host>

- Confirm SSH exposure:
  - local_ip:22 blocked
  - tailscale_ip:22 success

## Checklist for Post-Hardening Validation

```bash
# Check SSH authentication methods
ssh user@local_ip -p 22 -o PasswordAuthentication=yes # Should fail: No PasswordAuthentication, Tailscale only
ssh user@<tailscale_ip> -p 22 -o PasswordAuthentication=yes # Should fail: No PasswordAuthentication
# Check for open ports
sudo ss -tulpn
# Check UFW status and rules
sudo ufw status verbose
# Check SSHD config
sudo cat /etc/ssh/sshd_config
# Check SSHD override directory
ls -l /etc/ssh/sshd_config.d/
```

## Role Map (Post-Refactor)

- linux_security: merged auto-dbpkg, pubkey, tailscale-sshd-conf, tailscale-ufw
- linux_neovim: includes dev-configs
- docker-compose_personal: unchanged
- tailscale: unchanged

## Molecule (Local)

- cd roles/<role_name>
- molecule test -s default

## System Requirements

- Venv:

python3 -m venv .venv
source .venv/bin/activate

- Dependencies:

sudo apt install -y python3-pip python3-venv git-core
pip install ansible-core molecule "molecule-plugins[docker]" ansible-lint yamllint
ansible-galaxy collection install community.general ansible.posix community.crypto community.docker
