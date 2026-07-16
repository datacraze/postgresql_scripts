-- Purpose: show large tables with their latest vacuum and analyze timestamps.
-- Requires: access to pg_stat_user_tables.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: timestamps must be interpreted with table churn and autovacuum
-- policy.

SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    greatest(last_vacuum, last_autovacuum) AS last_vacuum_at,
    greatest(last_analyze, last_autoanalyze) AS last_analyze_at
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY greatest(last_vacuum, last_autovacuum) ASC NULLS FIRST
LIMIT 20;
