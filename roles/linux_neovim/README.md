# Linux Neovim

Installs Neovim via bob and applies developer shell configuration.

## Requirements

None.

## Role Variables

```yaml
linux_neovim_packages:
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
linux_neovim_version: "0.11.2"
linux_neovim_install_bob: true
linux_neovim_install_dotfiles: true

linux_neovim_dev_user: "{{ ansible_facts['user_id'] | default(ansible_facts['user']) }}"
linux_neovim_dev_set_shell: true
linux_neovim_dev_shell_alias_files:
  - .bash_aliases
  - .zsh_aliases
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
