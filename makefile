ROLE_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ROLES     := $(shell find roles -maxdepth 3 -name molecule -exec dirname {} \;)

$(eval $(ROLE_NAME):;@:)

.PHONY: role ping-droplet checkboot checkharden lint molecule strap-pi tailscale-pi tailscale-pi-neovim tailscale-pi-docker find

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

strap-pi:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_static.ini \
	playbooks/site.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
	--ask-vault-pass \
	-e "tailscale_force_reauth=true"

tailscale-pi:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_tailscale.ini \
	playbooks/site.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
	--ask-vault-pass \

tailscale-pi-neovim:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_tailscale.ini \
	playbooks/linux_neovim.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
	--ask-vault-pass \

tailscale-pi-docker:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_tailscale.ini \
	playbooks/linux_docker.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
	--ask-vault-pass \

find:
	find . -type f -exec cat {} +
