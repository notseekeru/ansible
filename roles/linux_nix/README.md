# SPDX-License-Identifier: MIT-0
---
# Deploy the Nix package manager.

## Requirements
* Debian / Ubuntu node with systemd (for multi-user/daemon install).

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `linux_nix_remove` | `false` | `true` to uninstall Nix. |
| `linux_nix_enable_flakes` | `true` | Write `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`. |
| `linux_nix_install_url` | `https://nixos.org/nix/install` | Official Nix install script. |
| `linux_nix_daemon` | `true` | `true` = multi-user (`--daemon`); `false` = single-user (`--no-daemon`). |
| `linux_nix_remove_store` | `false` | During an uninstall, also remove the `/nix` store (destructive). |

Uses the **official** [`nix-install`](https://nixos.org/nix/install) script.
For a fresh node the installer is bootstrapped via the currently ssh'd user and
self-elevates with `sudo` as needed. System-only: no per-user group membership or
`nix profile` setup is done — consumers handle those.

## Example Playbook

```yaml
- hosts: dev
  roles:
    - role: linux_nix
      vars:
        linux_nix_enable_flakes: true
```
