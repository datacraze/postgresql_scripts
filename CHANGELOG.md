# Changelog

All notable changes to this project are documented in this file.

### Added

- Standalone, privacy-redacted PostgreSQL diagnostic tools.
- Public contribution, security, and project-specification documentation.
- Automated SQL, shell, Docker, whitespace, and secret checks.

### Changed

- Docker initialization now uses least-privilege roles and local-only port
  binding by default.
- Docker bootstrap no longer installs legacy diagnostic views.
- Diagnostic view installation pins `search_path` to `pg_catalog`.
- The Docker image preloads `pg_stat_statements`, and bootstrap installs the
  `pg_stat_statements` and `pgstattuple` extensions in the configured database.
- Docker data now lives in a named volume mounted at `/var/lib/postgresql`,
  matching the upstream image layout.
- `POSTGRES_PORT` defaults to `5433` in Docker Compose.
- CI executes every diagnostic script against a live PostgreSQL container.
- `160_q_database_statistics.sql` reports pretty-printed temporary file usage
  as `temp_size`.
- `100_q_xid_wraparound_risk.sql` includes TOAST tables.
- `110_q_idle_in_transaction.sql` includes aborted idle transactions and
  documents its cluster-wide scope.
- `grants.example.sql` documents default-privilege maintenance, the
  `pg_stat_scan_tables` requirement for `210`/`220`, and cross-session
  statistics visibility.
- Trimmed `.gitignore` to operating-system files and local credentials.

### Fixed

- `070_q_sequential_scan_candidates.sql` no longer excludes tables without
  indexes from sequential-scan candidates.
- Docker role and database existence checks interpolate psql variables, so
  re-initialization takes the intended maintenance paths.
- The Docker healthcheck resolves `POSTGRES_USER` instead of a shell process
  ID and allows a startup grace period.
- The Docker data volume no longer leaks an anonymous volume per container.
- Docker bootstrap runs as an executable script instead of being sourced by
  the entrypoint.
