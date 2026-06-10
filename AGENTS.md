## Project Convention

- Before creating or modifying any code, ensure you have a clear understanding of the existing infrastructure, repo structure, dependencies, indentation, inspections, naming conventions, format,and coding style used in the current codebase.
- Do not commit any secrets, sensitive information, tokens, private keys, runner registration tokens, webhooks urls or environment credentials to the repository.

## Project Structure

```
.
├── AGENTS.md
├── ansible.cfg
├── docs
│   └── IMPORTANT_NOTES.md
├── group_vars
│   ├── vault.yml
│   └── vault.yml.example
├── inventories
│   ├── home.ini.example
│   ├── home_static.ini
│   └── home_tailscale.ini
├── makefile
├── playbooks
│   ├── droplet-bootstrap.yml
│   ├── linux_docker.yml
│   ├── linux_neovim.yml
│   └── site.yml
├── roles
│   ├── geerlingguy.docker
│   │   ├── LICENSE
│   │   ├── README.md
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── molecule
│   │   │   └── default
│   │   │       ├── converge.yml
│   │   │       ├── molecule.yml
│   │   │       └── verify.yml
│   │   ├── tasks
│   │   │   ├── docker-compose.yml
│   │   │   ├── docker-users.yml
│   │   │   ├── main.yml
│   │   │   ├── setup-Debian.yml
│   │   │   ├── setup-RedHat.yml
│   │   │   └── setup-Suse.yml
│   │   └── vars
│   │       ├── Alpine.yml
│   │       ├── Archlinux.yml
│   │       ├── Debian.yml
│   │       ├── RedHat.yml
│   │       ├── Suse.yml
│   │       └── main.yml
│   ├── linux_neovim
│   │   ├── README.md
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── molecule
│   │   │   └── default
│   │   │       ├── converge.yml
│   │   │       ├── molecule.yml
│   │   │       └── verify.yml
│   │   ├── tasks
│   │   │   ├── bob.yml
│   │   │   ├── configs.yml
│   │   │   ├── main.yml
│   │   │   └── packages.yml
│   │   ├── tests
│   │   │   ├── inventory
│   │   │   └── test.yml
│   │   └── vars
│   │       └── main.yml
│   ├── linux_security
│   │   ├── README.md
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── files
│   │   │   └── authorized_keys.pub
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── molecule
│   │   │   └── default
│   │   │       ├── converge.yml
│   │   │       ├── molecule.yml
│   │   │       └── verify.yml
│   │   ├── tasks
│   │   │   ├── authorized_keys.yml
│   │   │   ├── baseline.yml
│   │   │   ├── main.yml
│   │   │   ├── sshd.yml
│   │   │   └── ufw.yml
│   │   ├── templates
│   │   │   └── sshd_config.j2
│   │   └── vars
│   │       └── main.yml
│   └── tailscale
│       ├── README.md
│       ├── defaults
│       │   └── main.yml
│       ├── handlers
│       │   └── main.yml
│       ├── meta
│       │   └── main.yml
│       ├── molecule
│       │   └── default
│       │       ├── converge.yml
│       │       ├── molecule.yml
│       │       └── verify.yml
│       ├── tasks
│       │   └── main.yml
│       ├── tests
│       │   ├── inventory
│       │   └── test.yml
│       └── vars
│           └── main.yml
└── venv.sh

42 directories, 73 files
```

## Project Prompt

### Task

### Environment Versions

- Ubuntu 26+
- Debian 13+
- Debian OS Families.

- Ansible: 2.21.0
- Python: 3.14.4 (Venv, up-to-date)
- Jinja2: 3.1.6
- Docker: 29.5.1
- pip: 25.1.1
- Molecule: 26.4.0

### Phase 1: Assessment & Clarification (Mandate)

1. Stop and analyze the existing codebase provided by the user.
2. Ask clarifying questions using only vscode popup question, regarding current infrastructure dependencies before writing code.
3. Confirm the target "Reference Date" or specific corporate standards required.
4. Do not output refactored code until the user confirms your initial analysis and answers your questions.

### Phase 2: Refactoring Requirements (Once Approved)

- **Structure**: Reorganize folder structures and rename roles to match modern Ansible best practices.
- **Clean Code**: Remove redundant, dead, or unnecessary code. Do not use deprecated modules.
- **Testing**: Implement a standard Molecule test suite inside every single role.
- **CI/CD**: Update the CI pipeline config to seamlessly run the new Molecule tests and linting.
- **Quality**: Ensure 100% compliance with Ansible Lint and YAML syntax validation. Zero warnings allowed.
- **Docs**: Generate detailed markdown documentation of all changes inside the `/docs` folder. Include future notes for scalability.

### Gotchas to Avoid

- Breaking existing playbook references due to folder renaming.
- Accidentally removing required variables during optimization.
- Scope creep (do not add undocumented features).
