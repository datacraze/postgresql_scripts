-- Purpose: identify indexes with a low observed shared-buffer hit ratio.
-- Requires: access to pg_statio_user_indexes.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: investigate workload, memory, and query plans before tuning.

SELECT
    schemaname AS schema_name,
    relname AS table_name,
    indexrelname AS index_name,
    idx_blks_hit,
    idx_blks_read,
    round(
        100.0 * idx_blks_hit / nullif(idx_blks_hit + idx_blks_read, 0),
        2
    ) AS cache_hit_pct
FROM pg_statio_user_indexes
WHERE idx_blks_hit + idx_blks_read > 0
ORDER BY cache_hit_pct ASC
LIMIT 20;
