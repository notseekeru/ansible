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

## Future Enhancements and Best Practices

How this would look in your flowchart:

Add “Molecule/Testinfra” after every role change.
Add “Deploy to Staging” before “Deploy to Prod.”
Add “Drift Detection/Monitoring” as a feedback loop after prod.
Add “Backup/Restore” as a parallel flow.
Add “Secrets Management” as a prerequisite for all sensitive tasks.
