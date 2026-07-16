-- Purpose: identify table relations with a low observed shared-buffer hit
-- ratio.
-- Requires: access to pg_statio_user_tables.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: a cache ratio is a workload signal, not a standalone tuning
-- target.

SELECT
    schemaname AS schema_name,
    relname AS table_name,
    heap_blks_hit,
    heap_blks_read,
    round(
        100.0 * heap_blks_hit / nullif(heap_blks_hit + heap_blks_read, 0),
        2
    ) AS cache_hit_pct
FROM pg_statio_user_tables
WHERE heap_blks_hit + heap_blks_read > 0
ORDER BY cache_hit_pct ASC
LIMIT 20;
