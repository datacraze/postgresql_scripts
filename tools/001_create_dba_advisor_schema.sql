-- Purpose: create the dedicated schema used by the diagnostic views.
-- Requires: CREATE privilege in the target database.
-- Usage: run once before any numbered diagnostic view.

CREATE SCHEMA IF NOT EXISTS dba_advisor;
