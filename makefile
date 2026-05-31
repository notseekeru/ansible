ROLE_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ROLES := $(shell find roles -maxdepth 3 -name molecule -exec dirname {} \;)

$(eval $(ROLE_NAME):;@:)

.PHONY: 

ping-droplet:
	ansible -i inventories/droplet.ini webservers -m ping

role:
	ansible-galaxy init ./roles/$(ROLE_NAME)

neovim:
	ansible-playbook playbooks/linux_neovim.yml -i inventories/hosts.ini -K

lint:
	@echo "🔍 Running Ansible Lint with auto-fix..."\
	@ansible-lint --fix all

molecule:
	@echo "Creating python venv and installing Molecule..."
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip molecule molecule-plugins[docker]

	@echo "Found roles to test: $(ROLES)"
	@for role in $(ROLES); do \
		echo "=========================================="; \
		echo "🚀 Running Molecule test for: $$role"; \
		echo "=========================================="; \
		(cd $$role && ../../.venv/bin/molecule test -s default) || exit 1; \
	done

checkwsl:
	ansible-playbook -i localhost, -c local playbooks/linux_neovim.yml --ask-become-pass --check --diff

checkboot:
	ansible-playbook playbooks/deb_bootstrap.yml -i inventories/*.ini --check --diff

checkharden:
	ansible-playbook playbooks/deb_hardening.yml -i inventories/*.ini --check --diff

