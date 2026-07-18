-- Purpose: find foreign keys without a suitable leading B-tree index.
-- Requires: PostgreSQL 15+, catalog visibility, and the dba_advisor schema.
-- Usage: SELECT * FROM dba_advisor.missing_fk_index_candidates;
-- Limitation: validate workload and query plans before creating an index.
-- Limitation: matching requires the index to lead with the foreign-key
-- columns in constraint order, so a usable permuted index (foreign key on
-- (a, b) served by an index on (b, a)) is still reported as a candidate.

SET search_path = pg_catalog;

CREATE OR REPLACE VIEW dba_advisor.missing_fk_index_candidates
WITH (security_invoker = true) AS
WITH foreign_keys AS (
    SELECT
        constraint_definition.oid AS constraint_oid,
        namespace.nspname AS schema_name,
        table_relation.relname AS table_name,
        constraint_definition.conname AS constraint_name,
        constraint_definition.conrelid AS table_oid,
        constraint_definition.conkey AS foreign_key_columns,
        table_relation.reltuples::bigint AS estimated_rows
    FROM pg_constraint AS constraint_definition
    INNER JOIN pg_class AS table_relation
        ON constraint_definition.conrelid = table_relation.oid
    INNER JOIN pg_namespace AS namespace
        ON table_relation.relnamespace = namespace.oid
    WHERE constraint_definition.contype = 'f'
)

SELECT
    foreign_keys.schema_name,
    foreign_keys.table_name,
    foreign_keys.constraint_name,
    foreign_keys.estimated_rows,
    pg_get_constraintdef(foreign_keys.constraint_oid) AS constraint_definition
FROM foreign_keys
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_index AS index_definition
    INNER JOIN pg_class AS index_relation
        ON index_definition.indexrelid = index_relation.oid
    INNER JOIN pg_am AS access_method
        ON index_relation.relam = access_method.oid
    WHERE
        index_definition.indrelid = foreign_keys.table_oid
        AND index_definition.indisvalid
        AND index_definition.indisready
        AND index_definition.indpred IS null
        AND access_method.amname = 'btree'
        AND index_definition.indnkeyatts
        >= array_length(foreign_keys.foreign_key_columns, 1)
        AND array(
            SELECT  -- noqa: LT09
                (index_definition.indkey::smallint [])[positions.position - 1]
            FROM
                generate_subscripts(
                    foreign_keys.foreign_key_columns,
                    1
                ) AS positions (position)
            ORDER BY positions.position
        ) = foreign_keys.foreign_key_columns
);

COMMENT ON VIEW dba_advisor.missing_fk_index_candidates IS
'Foreign keys lacking a valid non-partial B-tree index in FK column order.';
