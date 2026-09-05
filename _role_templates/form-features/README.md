# SPDX-License-Identifier: MIT-0
---
# __role_name__

Multi-feature config/hardening role for Debian/Ubuntu nodes.
`tasks/main.yml` dispatches each concern to its own file behind an enable toggle.

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `__role_name___enable_feature_one` | `true` | Run feature_one tasks. |
| `__role_name___enable_feature_two` | `false` | Run feature_two tasks. |

> Rename/remove the placeholder features to match reality, then complete the table.

## Example Playbook

```yaml
- hosts: dev
  roles:
    - role: __role_name__
      vars:
        __role_name___enable_feature_two: true
```
