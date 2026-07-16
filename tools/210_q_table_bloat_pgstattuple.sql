-- Purpose: inspect one table with extension-backed bloat metrics.
-- Requires: pgstattuple installed and EXECUTE access, normally via
-- pg_stat_scan_tables.
-- Usage: replace public.example_table with the target relation, then run with
-- psql.
-- Cost: pgstattuple_approx avoids a full scan where possible but still reads
-- relation pages. Run one target at a time and avoid broad production scans.
-- Limitation: live-tuple and free-space values can change during concurrent
-- writes.

WITH target AS (
    SELECT 'public.example_table'::regclass AS relation
)

SELECT
    target.relation::text AS relation_name,
    bloat_stats.table_len AS table_bytes,
    bloat_stats.scanned_percent,
    bloat_stats.approx_tuple_count,
    bloat_stats.approx_tuple_len AS approximate_live_tuple_bytes,
    bloat_stats.approx_tuple_percent AS approximate_live_tuple_pct,
    bloat_stats.dead_tuple_count,
    bloat_stats.dead_tuple_len AS dead_tuple_bytes,
    bloat_stats.dead_tuple_percent AS dead_tuple_pct,
    bloat_stats.approx_free_space AS approximate_free_bytes,
    bloat_stats.approx_free_percent AS approximate_free_pct
FROM target
CROSS JOIN LATERAL pgstattuple_approx(target.relation) AS bloat_stats;
