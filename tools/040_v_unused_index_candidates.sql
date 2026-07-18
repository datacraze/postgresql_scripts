-- Purpose: show index usage counters with their statistics-reset context.
-- Requires: PostgreSQL 15+, catalog visibility, and the dba_advisor schema.
-- Usage: SELECT * FROM dba_advisor.unused_index_candidates;
-- Limitation: counters are cumulative; low scans alone do not justify removal.

SET search_path = pg_catalog;

CREATE OR REPLACE VIEW dba_advisor.unused_index_candidates
WITH (security_invoker = true) AS
WITH database_stats AS (
    SELECT stats_reset
    FROM pg_stat_database
    WHERE datname = current_database()
)

SELECT
    index_stats.schemaname AS schema_name,
    index_stats.relname AS table_name,
    index_stats.indexrelname AS index_name,
    index_stats.idx_scan,
    index_stats.idx_tup_read,
    index_stats.idx_tup_fetch,
    database_stats.stats_reset,
    pg_relation_size(index_stats.indexrelid) AS index_bytes,
    pg_get_indexdef(index_stats.indexrelid) AS index_definition
FROM pg_stat_user_indexes AS index_stats
INNER JOIN pg_index AS index_definition
    ON index_stats.indexrelid = index_definition.indexrelid
CROSS JOIN database_stats
WHERE
    index_definition.indisvalid
    AND index_definition.indisready
    AND NOT index_definition.indisprimary
    AND NOT index_definition.indisunique
    AND NOT index_definition.indisreplident
    AND index_definition.indpred IS null
    AND NOT EXISTS (
        SELECT 1
        FROM pg_constraint AS constraint_definition
        WHERE constraint_definition.conindid = index_stats.indexrelid
    );

COMMENT ON VIEW dba_advisor.unused_index_candidates IS
'Usage counters with reset context; low scans alone do not justify removal.';
