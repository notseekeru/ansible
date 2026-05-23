# Docker Compose Personal

Clones a personal Docker Compose repository and deploys a project.

## Requirements

- community.docker

## Role Variables

```yaml
docker_compose_personal_repo: "https://github.com/notseekeru/docker.git"
docker_compose_personal_project: "portfolio_website"
docker_compose_personal_manage_env: true
docker_compose_personal_cloudflare_token: "{{ CLOUDFLARE_TOKEN | default('') }}"
```

## Example Playbook

```yaml
- name: Deploy personal compose stack
  hosts: tailscale_pi_nodes
  gather_facts: true
  roles:
    - role: docker_compose_personal
```
