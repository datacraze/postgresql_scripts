# PostgreSQL Diagnostic Tools

Read-only catalog views for PostgreSQL session, lock, table-statistics, and
index-candidate diagnostics. The package intentionally omits application row
data, query text, client addresses, role names, application names, hard-coded
owners, and automatic remedies.

The reusable diagnostic views (`010` through `060`) require PostgreSQL 15 or
later because they use `security_invoker`. Standalone queries document any
additional version requirements.

## Use One Tool Or Install The Set

Each numbered file creates one idempotent, security-invoker view in the
`dba_advisor` schema.
Run `001_create_dba_advisor_schema.sql` once, then run only the view needed for
the current investigation or install all views in numeric order.

Scripts numbered `070` and later are standalone read-only queries. They do not
require the `dba_advisor` schema and can be run individually.

`210` and `220` use PostgreSQL's supported `pgstattuple` extension rather than
legacy catalog heuristics. The extension must be installed by an authorized DBA,
and the diagnostic role normally needs membership in `pg_stat_scan_tables` or a
reviewed function grant. Target one relation per run because these functions
read relation pages and results can change during concurrent writes.

Run the files in numeric order as an authorized database owner or migration
role. The supplied views are idempotent; grants are intentionally separate and
must use an environment-specific role.

```bash
psql -v ON_ERROR_STOP=1 -f 001_create_dba_advisor_schema.sql
psql -v ON_ERROR_STOP=1 -f 010_v_active_sessions.sql
psql -v ON_ERROR_STOP=1 -f 020_v_lock_waits.sql
psql -v ON_ERROR_STOP=1 -f 030_v_duplicate_index_candidates.sql
psql -v ON_ERROR_STOP=1 -f 040_v_unused_index_candidates.sql
psql -v ON_ERROR_STOP=1 -f 050_v_missing_fk_index_candidates.sql
psql -v ON_ERROR_STOP=1 -f 060_v_table_statistics.sql
```

Review and adapt `grants.example.sql`; it is not safe to execute unchanged.

## Limitations

- Statistics counters are cumulative and can reset after a restart or explicit
  statistics reset.
- Candidate views do not prove an index should be created or removed. Review
  constraints, replica identity, workload history, query plans, and maintenance
  windows before any change.
- These views need catalog-statistics visibility. Grant the least privilege
  needed for the intended diagnostic role; the returned scope reflects that
  role's visibility.
- Query text is intentionally omitted. Use a separately reviewed and
  access-controlled workflow when query text is necessary for an incident.
