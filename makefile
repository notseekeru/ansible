ROLE_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ROLES     := $(shell find roles -maxdepth 3 -name molecule -exec dirname {} \;)

$(eval $(ROLE_NAME):;@:)

.PHONY: ping-droplet role neovim lint molecule checkboot checkharden

role:
	@if [ -z "$(ROLE_NAME)" ]; then echo "❌ Error: Specify a role name (e.g., make role my_role)"; exit 1; fi
	ansible-galaxy init ./roles/$(ROLE_NAME)

ping-droplet:
	ansible -i inventories/droplet.ini webservers -m ping

checkboot:
	ansible-playbook playbooks/deb_bootstrap.yml -i inventories/ --check --diff

checkharden:
	ansible-playbook playbooks/deb_hardening.yml -i inventories/ --check --diff

lint:
	@echo "🔍 Running Ansible Lint with auto-fix..."
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip ansible-lint
	.venv/bin/ansible-lint --fix all

molecule:
	@echo "📦 Creating python venv and installing Molecule..."
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip molecule "molecule-plugins[docker]"
	@echo "Found roles to test: $(ROLES)"
	@for role in $(ROLES); do \
		echo "=========================================="; \
		echo "🚀 Running Molecule test for: $$role"; \
		echo "=========================================="; \
		(cd "$$role" && $(CURDIR)/.venv/bin/molecule test -s default) || exit 1; \
	done