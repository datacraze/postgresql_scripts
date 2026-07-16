# PostgreSQL Scripts Specification

## Scope

This repository publishes reusable PostgreSQL diagnostics and a local Docker
environment for experimentation. The canonical diagnostics are the files in
[`tools/`](tools/); Docker does not install them automatically.

## Compatibility

- Reusable diagnostic views require PostgreSQL 15 or later. Standalone queries
  document their own version requirements.
- `200_q_pg_stat_statements.sql` requires PostgreSQL 13 or later with
  `pg_stat_statements`.
- `210_q_table_bloat_pgstattuple.sql` and
  `220_q_btree_index_bloat_pgstattuple.sql` require `pgstattuple` and must
  target one relation at a time.

## Safety Requirements

- Queries must be read-only. Reusable objects may only create or replace views
  in the `dba_advisor` schema.
- Do not include application row data, query text, client addresses, role names,
  application names, hard-coded owners, credentials, or automatic remediation.
- Every script documents its purpose, required privileges, usage, cost, and
  limitations where they are non-obvious.
- Index, bloat, and tuning output identifies candidates for DBA review; it must
  never prescribe destructive actions as automatic conclusions.
- Grants remain separate from diagnostic definitions and must use a reviewed,
  environment-specific role.

## Repository Structure

- `tools/`: canonical standalone SQL and diagnostic views.
- `docker/`: optional local PostgreSQL infrastructure only.

## Validation

Run before opening a pull request:

```bash
pre-commit run --all-files
sqlfluff lint --dialect postgres tools/*.sql
bash -n docker/db/init.sh docker/docker-entrypoint.sh
docker build --tag postgresql-scripts-validation:local docker
```
