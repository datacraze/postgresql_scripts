-- Purpose: inspect table size, scan counters, dead tuples, and maintenance
-- dates.
-- Requires: PostgreSQL 15+, catalog visibility, and the dba_advisor schema.
-- Usage: SELECT * FROM dba_advisor.table_statistics;
-- Limitation: counters require workload and statistics-reset context.

SET search_path = pg_catalog;

CREATE OR REPLACE VIEW dba_advisor.table_statistics
WITH (security_invoker = true) AS
SELECT
    namespace.nspname AS schema_name,
    table_relation.relname AS table_name,
    table_statistics.n_live_tup,
    table_statistics.n_dead_tup,
    table_statistics.seq_scan,
    table_statistics.idx_scan,
    table_statistics.last_vacuum,
    table_statistics.last_autovacuum,
    table_statistics.last_analyze,
    table_statistics.last_autoanalyze,
    pg_relation_size(table_relation.oid) AS table_bytes,
    pg_indexes_size(table_relation.oid) AS index_bytes,
    pg_total_relation_size(table_relation.oid) AS total_bytes
FROM pg_stat_user_tables AS table_statistics
INNER JOIN pg_class AS table_relation
    ON table_statistics.relid = table_relation.oid
INNER JOIN pg_namespace AS namespace
    ON table_relation.relnamespace = namespace.oid;

COMMENT ON VIEW dba_advisor.table_statistics IS
'Table statistics and sizes; interpret counters with workload context.';
