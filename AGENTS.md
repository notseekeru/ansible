## Project Convention

- Before creating or modifying any code, ensure you have a clear understanding of the existing infrastructure, repo structure, dependencies, indentation, inspections, naming conventions, format,and coding style used in the current codebase.
- Do not commit any secrets, sensitive information, tokens, private keys, runner registration tokens, webhooks urls or environment credentials to the repository.

## Project Structure

```
├── AGENTS.md
├── ansible.cfg
├── docs
│   ├── IMPORTANT_NOTES.md
├── group_vars
│   ├── vault.yml
│   └── vault.yml.example
├── inventories
│   └── hosts.ini
├── makefile
├── playbooks
│   ├── deb-bootstrap.yml
│   ├── deb-hardening.yml
│   └── linux_neovim.yml
└── roles
    ├── docker_compose_personal
    ├── geerlingguy.docker
    ├── linux_neovim
    ├── linux_security
    └── tailscale
```

## Project Prompt

### Task

May 2026

You are an expert DevOps Engineer specializing in Ansible. Refactor the provided Ansible codebase according to the strict requirements below. Implement Molecule tests for each role and ensure all code adheres to Ansible best practices. CIS Level 1 compliance is a must. Update the CI pipeline to run these tests and ensure 100% Ansible Lint compliance. Document all changes in detail.

Additional tasks:

- Add zsh installation and configuration to the linux_neovim role for an improved shell experience.
- Fail2Ban: Insert to linux_security role and configure Fail2Ban for enhanced security.

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
