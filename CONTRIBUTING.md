# Contributing

## Before You Start

Keep changes focused. Do not add credentials, production connection strings,
schema dumps containing application data, query text, client addresses, or
automatic remediation.

Read [SPEC.md](SPEC.md) before changing a diagnostic.

## Development Workflow

1. Create a focused branch.
2. Add or update the relevant script and its README table entry.
3. Run the required checks:

```bash
pre-commit run --all-files
sqlfluff lint --dialect postgres tools/*.sql
bash -n docker/db/init.sh docker/docker-entrypoint.sh
docker build --tag postgresql-scripts-validation:local docker
```

4. Test SQL against a disposable PostgreSQL instance. Do not test diagnostics
   against production data without appropriate authorization.
5. Update [CHANGELOG.md](CHANGELOG.md) for user-visible changes.

## Pull Requests

Describe the operational impact, PostgreSQL version requirements, required
privileges, and validation performed. A pull request must not include ignored
environment files or generated artifacts unrelated to the change.

## Security Issues

Do not disclose vulnerabilities in public issues. Follow
[SECURITY.md](SECURITY.md).
