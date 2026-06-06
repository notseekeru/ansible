# Important Notes

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

## Falco Validation

```bash
falco --version
systemctl is-enabled falco
systemctl is-active falco
```

In Docker-based Molecule runs, use this as a smoke-test target. Falco startup may be skipped when the kernel driver path is not suitable.

## Molecule (Local)

- cd roles/<role_name>
- molecule test -s default

## System Requirements

- Venv:

python3 -m venv .venv
source .venv/bin/activate

- Dependencies:

sudo apt install -y python3-pip python3-venv git-core
pip install ansible-core molecule "molecule-plugins[docker]" ansible-lint
ansible-galaxy collection install community.general ansible.posix community.crypto community.docker
