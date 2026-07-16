-- Purpose: show progress for currently running CREATE INDEX or REINDEX
-- operations.
-- Requires: PostgreSQL 12+ and access to pg_stat_progress_create_index.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: an empty result means no visible index build is running.

SELECT
    progress.pid,
    progress.datname AS database_name,
    progress.relid::regclass AS relation_name,
    progress.command,
    progress.phase,
    progress.blocks_total,
    progress.blocks_done,
    round(
        100.0 * progress.blocks_done / nullif(progress.blocks_total, 0),
        1
    ) AS pct_complete
FROM pg_stat_progress_create_index AS progress;
