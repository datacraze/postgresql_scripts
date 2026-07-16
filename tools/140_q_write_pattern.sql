-- Purpose: summarize cumulative insert, update, and delete patterns by table.
-- Requires: access to pg_stat_user_tables.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: counters reset and do not describe a bounded reporting period.

SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_live_tup,
    round(
        100.0 * n_tup_ins / nullif(n_tup_ins + n_tup_upd + n_tup_del, 0),
        1
    ) AS insert_pct,
    round(
        100.0 * n_tup_upd / nullif(n_tup_ins + n_tup_upd + n_tup_del, 0),
        1
    ) AS update_pct,
    round(
        100.0 * n_tup_del / nullif(n_tup_ins + n_tup_upd + n_tup_del, 0),
        1
    ) AS delete_pct
FROM pg_stat_user_tables
WHERE n_tup_ins + n_tup_upd + n_tup_del > 0
ORDER BY n_tup_ins + n_tup_upd + n_tup_del DESC
LIMIT 20;
