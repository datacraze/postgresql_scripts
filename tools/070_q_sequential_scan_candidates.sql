-- Purpose: find tables where sequential reads dominate observed scan activity.
-- Requires: access to pg_stat_user_tables.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: statistics are cumulative and a sequential scan is often correct.

SELECT
    schemaname AS schema_name,
    relname AS table_name,
    seq_scan,
    idx_scan,
    n_live_tup,
    seq_tup_read,
    round(
        100.0 * seq_scan / nullif(seq_scan + idx_scan, 0),
        1
    ) AS sequential_scan_pct
FROM pg_stat_user_tables
WHERE seq_scan + idx_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;
