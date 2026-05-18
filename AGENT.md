## Requirements

- Libraries are in Python Venv and are up to date.
- Refactor the roles to improve readability and maintainability.
- Confirm Ansible Linting and YAML syntax validation for the refactored roles to ensure code quality and consistency. Ensure all changes meet the required Ansible Linting standards.
- Organize folder/rename structure to follow best practices and conventions.
- Ensure that the roles follow best practices and coding standards.
- Remove any redundant or unnecessary code from the roles.
- Implement molecule tests to verify the functionality of the roles after refactoring.
- Report and audit the changes to reflect any modifications made during the refactoring process.
- Ensure that the refactored roles are compatible with the existing infrastructure and do not introduce any breaking changes.
- Document the changes made to the roles, including any new features or improvements implemented during the refactoring process at the /docs folder.
- Suggest future notes for use to ensure that the refactored roles are maintainable and scalable in the long term.

## Dont's

- Do not use deprecated Ansible modules or features in the refactored roles.
- Do not ignore any linting or syntax errors during the refactoring process.

## Mandate

- Always ask question
- Use Up to date Ansible Configs
- Always utilize Search Engine to find the best practices and solutions for the refactoring process.
- Ask Reference Date for the Ansible version being used to ensure compatibility and adherence to modern best practices.
- Always confirm the requirements before proceeding with the refactoring process.
- Always ensure that the refactored roles are tested and validated.
- Molecule are present in every role to ensure that the refactored roles are functional and do not introduce any issues.

## Gotcha/Failure Cases

- Refactoring may introduce bugs or issues if not done carefully, so thorough testing is essential.
- Changes to the folder structure may break existing playbooks or roles if not properly updated.
- Removing redundant code may inadvertently remove necessary functionality if not carefully reviewed.
- Introducing new features during refactoring may lead to scope creep and delay the project timeline.
- Failure to adhere to Ansible Linting standards may result in code that is difficult to maintain and CI errors.

## Versions

- Ansible Version: 2.20.1
- Python Version: 3.14.4
- Jinx Version: 3.1.6
