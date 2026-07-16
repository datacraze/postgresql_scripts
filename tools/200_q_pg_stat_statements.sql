-- Purpose: identify statement fingerprints with the greatest cumulative
-- execution time.
-- Requires: PostgreSQL 13+ with pg_stat_statements in the visible search path.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Privacy: statement text is intentionally omitted; query IDs are retained.

SELECT
    statement_stats.queryid,
    statement_stats.calls,
    statement_stats.rows,
    statement_stats.shared_blks_hit,
    statement_stats.shared_blks_read,
    round(statement_stats.total_exec_time::numeric, 2) AS total_exec_ms,
    round(statement_stats.mean_exec_time::numeric, 2) AS mean_exec_ms,
    round(
        100.0 * statement_stats.shared_blks_hit
        / nullif(
            statement_stats.shared_blks_hit + statement_stats.shared_blks_read,
            0
        ),
        2
    ) AS shared_cache_hit_pct
FROM pg_stat_statements AS statement_stats
WHERE statement_stats.calls > 0
ORDER BY statement_stats.total_exec_time DESC
LIMIT 20;
