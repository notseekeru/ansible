# -- args / helpers ---------------------------------------------------
ROLES := $(filter-out roles/geerlingguy.docker,$(shell find roles -maxdepth 3 -name molecule -exec dirname {} \;))

# new-role accepts NAME= and optional FORM=install|features via the command line.
NAME  ?=
FORM  ?= install

.PHONY: new-role venv lint molecule strap-pi tailscale-pi tailscale-pi-dev tailscale-pi-docker

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

new-role:
	@if [ -z "$(NAME)" ]; then echo "❌ Usage: make new-role NAME=linux_foo [FORM=install|features]"; exit 1; fi
	@./scripts/new-role.sh "$(NAME)" "form=$(FORM)"

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

INVENTORY ?= inventories/home.ini

strap-pi:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i $(INVENTORY) \
	playbooks/site.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v \
	-e "linux_tailscale_force_reauth=true"

tailscale-pi:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home.ini \
	playbooks/site.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v

tailscale-pi-dev:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home.ini \
	playbooks/linux_dev_configs.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v

tailscale-pi-docker:
	infisical run --env=dev -- \
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
	-i inventories/home.ini \
	playbooks/linux_docker.yml \
	--private-key=~/.ssh/id_ed25519 \
	--diff \
	-K \
	-v
