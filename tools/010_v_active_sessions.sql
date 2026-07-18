-- Purpose: inspect session state, waits, transaction age, and query age.
-- Requires: PostgreSQL 15+ and visibility into pg_stat_activity.
-- Usage: SELECT * FROM dba_advisor.active_sessions;
-- Privacy: query text, client addresses, roles, and application names are
-- intentionally omitted.

SET search_path = pg_catalog;

CREATE OR REPLACE VIEW dba_advisor.active_sessions
WITH (security_invoker = true) AS
SELECT
    activity.pid,
    activity.backend_type,
    activity.state,
    activity.wait_event_type,
    activity.wait_event,
    activity.xact_start,
    activity.query_start,
    activity.state_change,
    clock_timestamp() - activity.xact_start AS transaction_age,
    clock_timestamp() - activity.query_start AS query_age
FROM pg_stat_activity AS activity
WHERE
    activity.datname = current_database()
    AND activity.pid <> pg_backend_pid()
ORDER BY activity.query_start NULLS LAST;

COMMENT ON VIEW dba_advisor.active_sessions IS
'Session metadata excludes query text, addresses, roles, and app names.';
