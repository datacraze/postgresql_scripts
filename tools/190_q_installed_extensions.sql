-- Purpose: list installed PostgreSQL extensions and their schemas.
-- Requires: access to pg_extension and pg_namespace.
-- Usage: run directly with psql; this is a read-only SELECT query.

SELECT
    extension_info.extname AS extension_name,
    extension_info.extversion AS extension_version,
    namespace.nspname AS schema_name
FROM pg_extension AS extension_info
INNER JOIN pg_namespace AS namespace
    ON extension_info.extnamespace = namespace.oid
ORDER BY extension_name;
