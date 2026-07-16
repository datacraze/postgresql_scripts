# PostgreSQL Scripts

Copyable PostgreSQL diagnostics and administration helpers. The canonical SQL
lives in [`tools/`](tools/); Docker is optional local infrastructure, not a
requirement for using a script.

## Tools

| Script | Purpose | Notes |
| --- | --- | --- |
| [`001_create_dba_advisor_schema.sql`](tools/001_create_dba_advisor_schema.sql) | Creates the schema used by the diagnostic views. | Run once before any numbered view. |
| [`010_v_active_sessions.sql`](tools/010_v_active_sessions.sql) | Lists active and idle sessions with wait and duration metadata. | Query text and identity metadata are omitted. |
| [`020_v_lock_waits.sql`](tools/020_v_lock_waits.sql) | Shows blocked and blocking sessions. | Uses `pg_blocking_pids()`; identity metadata is omitted. |
| [`030_v_duplicate_index_candidates.sql`](tools/030_v_duplicate_index_candidates.sql) | Finds equivalent non-constraint indexes. | Review candidates manually before removal. |
| [`040_v_unused_index_candidates.sql`](tools/040_v_unused_index_candidates.sql) | Shows index usage counters and statistics-reset time. | Low scans alone do not justify removal. |
| [`050_v_missing_fk_index_candidates.sql`](tools/050_v_missing_fk_index_candidates.sql) | Finds foreign keys lacking a suitable leading B-tree index. | A candidate is not an automatic index recommendation. |
| [`060_v_table_statistics.sql`](tools/060_v_table_statistics.sql) | Shows table size, scan, vacuum, and analyze metadata. | Interpret counters with workload context. |
| [`070_q_sequential_scan_candidates.sql`](tools/070_q_sequential_scan_candidates.sql) | Lists tables with observed sequential-read pressure. | Sequential scans are often correct. |
| [`080_q_table_cache_hit_ratio.sql`](tools/080_q_table_cache_hit_ratio.sql) | Shows table shared-buffer hit ratios. | Investigate workload before tuning. |
| [`090_q_index_cache_hit_ratio.sql`](tools/090_q_index_cache_hit_ratio.sql) | Shows index shared-buffer hit ratios. | Investigate workload before tuning. |
| [`100_q_xid_wraparound_risk.sql`](tools/100_q_xid_wraparound_risk.sql) | Reports database and table XID age. | Coordinate remediation with a DBA. |
| [`110_q_idle_in_transaction.sql`](tools/110_q_idle_in_transaction.sql) | Finds idle open transactions. | Query text and identity metadata are omitted. |
| [`120_q_autovacuum_recency.sql`](tools/120_q_autovacuum_recency.sql) | Lists maintenance timestamps for active tables. | Interpret with churn and autovacuum policy. |
| [`130_q_hot_update_ratio.sql`](tools/130_q_hot_update_ratio.sql) | Finds update-heavy tables with low HOT activity. | Not a direct fillfactor recommendation. |
| [`140_q_write_pattern.sql`](tools/140_q_write_pattern.sql) | Summarizes cumulative write patterns. | Counters are not bounded to a reporting period. |
| [`150_q_wait_event_summary.sql`](tools/150_q_wait_event_summary.sql) | Summarizes non-idle wait events. | Individual roles and query text are omitted. |
| [`160_q_database_statistics.sql`](tools/160_q_database_statistics.sql) | Shows database transaction, I/O, temp-file, and deadlock statistics. | Counters reset. |
| [`170_q_vacuum_progress.sql`](tools/170_q_vacuum_progress.sql) | Shows active VACUUM progress. | PostgreSQL 9.6+; empty when no visible job runs. |
| [`180_q_create_index_progress.sql`](tools/180_q_create_index_progress.sql) | Shows active index-build progress. | PostgreSQL 12+; empty when no visible job runs. |
| [`190_q_installed_extensions.sql`](tools/190_q_installed_extensions.sql) | Lists installed extensions and schemas. | Read-only metadata. |
| [`200_q_pg_stat_statements.sql`](tools/200_q_pg_stat_statements.sql) | Ranks statement fingerprints by total execution time. | Requires `pg_stat_statements`; SQL text is omitted. |
| [`210_q_table_bloat_pgstattuple.sql`](tools/210_q_table_bloat_pgstattuple.sql) | Inspects approximate table dead-tuple and free-space metrics. | Requires `pgstattuple`; target one table at a time. |
| [`220_q_btree_index_bloat_pgstattuple.sql`](tools/220_q_btree_index_bloat_pgstattuple.sql) | Inspects B-tree page density and fragmentation. | Requires `pgstattuple`; target one index at a time. |

Each file has its own purpose, required privileges, usage, and limitations.
The `001` to `060` scripts install reusable views; `070` onward are standalone
read-only queries. Read [`tools/README.md`](tools/README.md) before applying a
view or grant.

## Docker

[`docker/`](docker/) is an optional reproducible local PostgreSQL environment.
It is useful for testing and experimentation, but the SQL tools do not depend
on it. The image initializes only its database infrastructure; it does not
install any `tools/` script. Run the needed diagnostic explicitly.

Copy `docker/.env.example` to `docker/.env` and replace every password
placeholder with a unique value of at least 16 characters. Initialization is
one-time: remove the local Docker volume before changing the database or role
configuration. A failed bootstrap leaves no completion marker and is refused on
subsequent starts; remove the volume, correct the configuration, and retry.

## Project Docs

- [Specification](SPEC.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Code of conduct](CODE_OF_CONDUCT.md)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)
