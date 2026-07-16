-- Purpose: inspect one B-tree index with extension-backed page metrics.
-- Requires: pgstattuple installed and EXECUTE access, normally via
-- pg_stat_scan_tables.
-- Usage: replace public.example_index with the target B-tree index, then run
-- with psql.
-- Cost: pgstatindex reads index pages. Run one target at a time and avoid broad
-- scans.
-- Limitation: density and fragmentation are investigation signals, not rebuild
-- thresholds. Concurrent writes can change results during collection.

WITH target AS (
    SELECT 'public.example_index'::regclass AS index_relation
)

SELECT
    target.index_relation::text AS index_name,
    bloat_stats.tree_level,
    bloat_stats.index_size AS index_bytes,
    bloat_stats.internal_pages,
    bloat_stats.leaf_pages,
    bloat_stats.empty_pages,
    bloat_stats.deleted_pages,
    bloat_stats.avg_leaf_density,
    bloat_stats.leaf_fragmentation
FROM target
CROSS JOIN LATERAL pgstatindex(target.index_relation) AS bloat_stats;
