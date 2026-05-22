# Extract the role name from the command line arguments
ROLE_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Prevents make from confusing role name arguments with file targets
$(eval $(ROLE_NAME):;@:)

.PHONY: role wsl neovim lint checkwsl checkboot checkharden
role:
	ansible-galaxy init ./roles/$(ROLE_NAME)

wsl:
	ansible-playbook -i localhost, -c local playbooks/linux_neovim.yml --ask-become-pass

neovim:
	ansible-playbook playbooks/linux_neovim.yml -i inventories/hosts.ini -K

lint:
	ansible-lint --fix all .

molecule:
	molecule test -s default

checkwsl:
	ansible-playbook -i localhost, -c local playbooks/linux_neovim.yml --ask-become-pass --check --diff

checkboot:
	ansible-playbook playbooks/deb-bootstrap.yml -i inventories/hosts.ini --check --diff

checkharden:
	ansible-playbook playbooks/deb-hardening.yml -i inventories/hosts.ini --check --diff

