-- Purpose: find equivalent non-unique, non-constraint index definitions.
-- Requires: PostgreSQL 15+, catalog visibility, and the dba_advisor schema.
-- Usage: SELECT * FROM dba_advisor.duplicate_index_candidates;
-- Limitation: every row is a review candidate, never an automatic drop command.

CREATE OR REPLACE VIEW dba_advisor.duplicate_index_candidates
WITH (security_invoker = true) AS
WITH index_signatures AS (
    SELECT
        namespace.nspname AS schema_name,
        table_relation.relname AS table_name,
        index_relation.oid AS index_oid,
        index_relation.relname AS index_name,
        pg_get_indexdef(index_relation.oid) AS index_definition,
        format(
            '%s|%s|%s|%s|%s|%s',
            index_definition.indkey,
            index_definition.indclass,
            index_definition.indcollation,
            index_definition.indoption,
            coalesce(
                pg_get_expr(
                    index_definition.indexprs, index_definition.indrelid
                ),
                ''
            ),
            coalesce(
                pg_get_expr(
                    index_definition.indpred, index_definition.indrelid
                ),
                ''
            )
        ) AS index_signature
    FROM pg_index AS index_definition
    INNER JOIN pg_class AS index_relation
        ON index_definition.indexrelid = index_relation.oid
    INNER JOIN pg_class AS table_relation
        ON index_definition.indrelid = table_relation.oid
    INNER JOIN pg_namespace AS namespace
        ON table_relation.relnamespace = namespace.oid
    WHERE
        index_definition.indisvalid
        AND index_definition.indisready
        AND NOT index_definition.indisprimary
        AND NOT index_definition.indisunique
        AND NOT EXISTS (
            SELECT 1
            FROM pg_constraint AS constraint_definition
            WHERE constraint_definition.conindid = index_relation.oid
        )
)

SELECT
    schema_name,
    table_name,
    index_signature,
    array_agg(
        index_name
        ORDER BY index_name
    ) AS index_names,
    array_agg(
        index_definition
        ORDER BY index_name
    ) AS index_definitions,
    count(*) AS duplicate_count
FROM index_signatures
GROUP BY schema_name, table_name, index_signature
HAVING count(*) > 1;

COMMENT ON VIEW dba_advisor.duplicate_index_candidates IS
'Non-constraint index signatures. Review all candidates before removal.';
