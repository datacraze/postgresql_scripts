-- Purpose: summarize connection, transaction, I/O, temporary-file, and
-- deadlock stats.
-- Requires: access to pg_stat_database.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: statistics are cumulative since reset and need workload context.

SELECT
    datname AS database_name,
    numbackends AS connection_count,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    temp_files,
    deadlocks,
    conflicts,
    stats_reset,
    round(
        100.0 * xact_rollback / nullif(xact_commit + xact_rollback, 0),
        2
    ) AS rollback_pct,
    round(
        100.0 * blks_hit / nullif(blks_hit + blks_read, 0),
        2
    ) AS cache_hit_pct,
    pg_size_pretty(temp_bytes) AS temp_bytes
FROM pg_stat_database
WHERE datname = current_database();
