-- Purpose: show progress for currently running VACUUM operations.
-- Requires: PostgreSQL 9.6+ and access to pg_stat_progress_vacuum.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: an empty result means no visible VACUUM operation is running.

SELECT
    progress.pid,
    progress.datname AS database_name,
    progress.relid::regclass AS relation_name,
    progress.phase,
    progress.heap_blks_total,
    progress.heap_blks_scanned,
    progress.heap_blks_vacuumed,
    round(
        100.0
        * progress.heap_blks_vacuumed
        / nullif(progress.heap_blks_total, 0),
        1
    ) AS pct_complete
FROM pg_stat_progress_vacuum AS progress;
