# Linux Neovim

Installs Neovim via bob, applies developer shell configuration, and provisions GitHub CLI with optional PAT-based non-interactive auth.

## Requirements

None.

## Role Variables

```yaml
neovim_packages:
  - curl
  - git
  - unzip
  - build-essential
  - fd-find
  - ripgrep
  - lazygit
  - fzf
  - tree-sitter-cli
  - zsh
  - tmux
neovim_version: "0.11.2"
neovim_install_bob: true
neovim_install_dotfiles: true

dev_user: "{{ ansible_user_id | default(ansible_user) }}"
dev_set_shell: true
dev_install_gh: true
dev_gh_auth_hostname: github.com
dev_shell_aliases:
  - "alias ll='ls -alF'"
```

## Example Playbook

```yaml
- name: Developer tooling
  hosts: tailscale_pi_nodes
  gather_facts: true
  roles:
    - role: linux_neovim
```

## Templates

Make sure to update the `.j2` templates in the `templates/` directory to and modify the parsing from CRLF to LF if you are editing on Windows. Otherwise, the files will be rendered with CRLF line endings and may cause issues on Linux systems.
