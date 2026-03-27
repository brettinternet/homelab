# AGENTS.md

## Project

Homelab provisioning repo. Uses **Ansible** for host configuration and **Docker Compose** for services deployed remotely.

Project setup uses go-task @Taskfile.dist.yaml to setup and develop the project.
Dependencies used in this project are installed by `mise` and defined in `mise.toml`.

Secrets for each docker context are defined in a `sops.env` file that's encrypted with Sops. Don't read these files.

Make sure the checks passes after each change. Keep working until all checks pass.

## Lint

```sh
task check   # runs lint checks
```

## Structure

- `ansible/` — playbooks, roles, and host vars (some encrypted with SOPS)
- `docker/homelab/` — main homelab services compose files
- `docker/net/` — network utility services
- `Taskfile.dist.yaml` — primary entrypoint for all operations

## Conventions

- Secrets are encrypted with SOPS; never commit plaintext secrets
- Use `task` (go-task) to run operations, not raw `ansible-playbook` or `docker compose`
- Compose files follow the pattern `compose.<stack>.yaml`
- Host vars live in `ansible/inventory/host_vars/<hostname>.sops.yaml`

## Tools

### GitHub

- Always use `gh` CLI for all GitHub operations. Never construct raw API calls.
- For PRs: `gh pr view`, `gh pr diff`, `gh pr comment`
- For issues: `gh issue list`, `gh issue view`
- Never open GitHub browser URLs; use CLI output only

## What NOT to do

- Don't run `git push` without explicit instruction
- Don't open PRs without explicit instruction
- Don't edit files outside the current task scope
