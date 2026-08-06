# SPDX-License-Identifier: MIT-0
---
# Deploy the Infisical CLI.

## Requirements
* Debian / Ubuntu node.

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `linux_infisical_version` | `latest` | CLI release tag without leading `v`, resolved via GitHub API when `latest`. |
| `linux_infisical_remove` | `false` | `true` to uninstall the CLI. |

The CLI is installed from the pinned `Infisical/cli` GitHub release asset
(`cli_<version>_linux_amd64.tar.gz` | `linux_arm64`) — reproducible and
immutable. Install-only: no login, no persistent session, no credentials
deployed to the node. Authentication (e.g. via the `INFISICAL_TOKEN` /
universal-auth env vars) is left to the consumer, keeping the role idempotent
and side-effect-free.

## Example Playbook

```yaml
- hosts: dev
  roles:
    - role: linux_infisical
      vars:
        linux_infisical_version: 0.43.118
```
