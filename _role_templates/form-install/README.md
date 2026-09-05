# SPDX-License-Identifier: MIT-0
---
# __role_name__

Install/uninstall __role_name__ on Debian/Ubuntu nodes.

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `__role_name___remove` | `false` | `true` to uninstall __role_name__. |

> Complete the table with real knobs (version, install URL, feature toggles),
> then finish this README after you fill in `tasks/install.yml`.

## Example Playbook

```yaml
- hosts: dev
  roles:
    - role: __role_name__
```
