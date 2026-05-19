# Linux Neovim

Installs Neovim via bob and applies developer shell configuration.

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
