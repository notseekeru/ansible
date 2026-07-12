ROLE_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ROLES     := $(shell find roles -maxdepth 3 -name molecule -exec dirname {} \;)

$(eval $(ROLE_NAME):;@:)

.PHONY: role venv lint molecule ping-droplet strap-pi tailscale-pi tailscale-pi-neovim tailscale-pi-docker find

VENV_BIN := .venv/bin

venv:
	python3 -m venv .venv
	$(VENV_BIN)/pip install --quiet --upgrade pip
	$(VENV_BIN)/pip install --quiet \
		ansible-core \
		ansible-lint \
		molecule \
		"molecule-plugins[docker]"
	$(VENV_BIN)/ansible-galaxy collection install \
		community.general \
		ansible.posix \
		community.crypto \
		community.docker \
		--collections-path collections \
		--force
	@rm -f .collections-installed 2>/dev/null; true

role:
	@if [ -z "$(ROLE_NAME)" ]; then echo "❌ Error: Specify a role name (e.g., make role my_role)"; exit 1; fi
	ansible-galaxy init ./roles/$(ROLE_NAME)

lint:
	@if [ ! -f "$(VENV_BIN)/ansible-lint" ]; then echo "❌ Run 'make venv' first"; exit 1; fi
	PATH="$(CURDIR)/$(VENV_BIN):$$PATH" $(VENV_BIN)/ansible-lint

molecule:
	@if [ ! -f "$(VENV_BIN)/molecule" ]; then echo "❌ Run 'make venv' first"; exit 1; fi
	@echo "Found roles to test: $(ROLES)"
	@for role in $(ROLES); do \
		echo "🚀 Running Molecule test for: $$role"; \
		cd "$(CURDIR)/$$role" && \
		PATH="$(CURDIR)/$(VENV_BIN):$$PATH" \
		ANSIBLE_COLLECTIONS_PATH="$(CURDIR)/collections" \
		$(CURDIR)/$(VENV_BIN)/molecule test -s default || exit 1; \
	done

ping-droplet:
	ansible -i inventories/droplets.ini droplets -m ping

strap-droplet:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/droplets.ini \
	playbooks/droplet.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-e "tailscale_force_reauth=true"

strap-pi:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_static.ini \
	playbooks/site.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
	-e "tailscale_force_reauth=true"

tailscale-pi:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_tailscale.ini \
	playbooks/site.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \

tailscale-pi-neovim:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_tailscale.ini \
	playbooks/linux_neovim.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \

tailscale-pi-docker:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home_tailscale.ini \
	playbooks/linux_docker.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
