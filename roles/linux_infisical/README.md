# SPDX-License-Identifier: MIT-0
---
# Deploy the Infisical CLI and optionally authenticate a machine identity.

## Requirements
* Debian / Ubuntu node.
* Universal-auth machine identity. Put `infisical_client_id` /
  `infisical_client_secret` in `group_vars/vault.yml` (Ansible Vault encrypted)
  and run with `--ask-vault-pass`. **Never** inline plaintext credentials.

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `infisical_version` | `latest` | CLI release tag without leading `v`, resolved via GitHub API when `latest`. |
| `infisical_client_id` | `""` | Universal-auth machine identity client ID. Empty = install only. |
| `infisical_client_secret` | `""` | Universal-auth machine identity secret. |
| `infisical_remove` | `false` | `true` to log out and uninstall. |

The CLI is installed from the pinned `Infisical/cli` GitHub release asset
(`cli_<version>_linux_amd64.tar.gz` | `linux_arm64`) — reproducible and
immutable, unlike the unstable `infisical.com/install.sh` endpoint.

## Example Playbook

```yaml
- hosts: dev
  roles:
    - role: linux_infisical
      vars:
        infisical_version: 0.43.118
        infisical_client_id: "{{ vault_infisical_client_id }}"
        infisical_client_secret: "{{ vault_infisical_client_secret }}"
```
