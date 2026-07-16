-- Purpose: identify blocked sessions and the sessions blocking them.
-- Requires: PostgreSQL 15+ and visibility into pg_stat_activity.
-- Usage: SELECT * FROM dba_advisor.lock_waits;
-- Privacy: query text, client addresses, roles, and application names are
-- intentionally omitted.

CREATE OR REPLACE VIEW dba_advisor.lock_waits
WITH (security_invoker = true) AS
SELECT
    blocked_activity.pid AS blocked_pid,
    blocking_activity.pid AS blocking_pid,
    blocked_activity.wait_event_type,
    blocked_activity.wait_event,
    blocked_activity.query_start AS blocked_query_started_at,
    blocking_activity.query_start AS blocking_query_started_at
FROM pg_stat_activity AS blocked_activity
CROSS JOIN
    LATERAL unnest(
        pg_blocking_pids(blocked_activity.pid)
    ) AS blockers (blocking_pid)
INNER JOIN pg_stat_activity AS blocking_activity
    ON blockers.blocking_pid = blocking_activity.pid
WHERE blocked_activity.datname = current_database();

COMMENT ON VIEW dba_advisor.lock_waits IS
'Blocked session metadata from pg_blocking_pids(); identity metadata omitted.';
