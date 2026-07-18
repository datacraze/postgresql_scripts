-- Purpose: create the dedicated schema used by the diagnostic views.
-- Requires: CREATE privilege in the target database.
-- Usage: run once before any numbered diagnostic view.
-- Hardening: pin the session search path so later object references resolve
-- against pg_catalog only.

SET search_path = pg_catalog;

CREATE SCHEMA IF NOT EXISTS dba_advisor;
