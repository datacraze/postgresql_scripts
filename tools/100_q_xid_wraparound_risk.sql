-- Purpose: report database and table transaction-ID age relative to freeze
-- settings.
-- Requires: access to pg_database, pg_class, and pg_namespace.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Limitation: coordinate any remediation with an authorized DBA.

WITH freeze_settings AS (
    SELECT current_setting('autovacuum_freeze_max_age')::int AS freeze_max_age
)

SELECT
    'database' AS object_type,
    database_stats.datname AS object_name,
    age(database_stats.datfrozenxid) AS xid_age,
    round(
        100.0 * age(database_stats.datfrozenxid)
        / freeze_settings.freeze_max_age,
        2
    ) AS pct_of_freeze_max_age,
    NULL::text AS total_size
FROM pg_database AS database_stats
CROSS JOIN freeze_settings
WHERE database_stats.datallowconn

UNION ALL

SELECT
    'table' AS object_type,
    format('%I.%I', namespace.nspname, table_relation.relname) AS object_name,
    age(table_relation.relfrozenxid) AS xid_age,
    round(
        100.0 * age(table_relation.relfrozenxid)
        / freeze_settings.freeze_max_age,
        2
    ) AS pct_of_freeze_max_age,
    pg_size_pretty(pg_total_relation_size(table_relation.oid)) AS total_size
FROM pg_class AS table_relation
INNER JOIN pg_namespace AS namespace
    ON table_relation.relnamespace = namespace.oid
CROSS JOIN freeze_settings
WHERE
    table_relation.relkind IN ('r', 'm')
    AND namespace.nspname NOT IN (
        'pg_catalog', 'information_schema', 'pg_toast'
    )
ORDER BY xid_age DESC
LIMIT 50;
