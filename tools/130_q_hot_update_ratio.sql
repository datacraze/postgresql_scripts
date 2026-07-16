-- Purpose: identify update-heavy tables with a low HOT-update ratio.
-- Requires: access to pg_stat_user_tables and relation metadata.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: low HOT activity is not proof that changing fillfactor is
-- beneficial.

SELECT
    table_stats.schemaname AS schema_name,
    table_stats.relname AS table_name,
    table_stats.n_tup_upd,
    table_stats.n_tup_hot_upd,
    relation.reloptions,
    round(
        100.0 * table_stats.n_tup_hot_upd / nullif(table_stats.n_tup_upd, 0),
        1
    ) AS hot_update_pct
FROM pg_stat_user_tables AS table_stats
INNER JOIN pg_class AS relation
    ON table_stats.relid = relation.oid
WHERE table_stats.n_tup_upd > 0
ORDER BY hot_update_pct ASC NULLS FIRST
LIMIT 20;
