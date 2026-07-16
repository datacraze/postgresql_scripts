-- Purpose: summarize non-idle wait events across current database sessions.
-- Requires: visibility into pg_stat_activity.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Privacy: query text, client addresses, and individual roles are omitted.

SELECT
    wait_event_type,
    wait_event,
    count(*) AS session_count
FROM pg_stat_activity
WHERE
    datname = current_database()
    AND state <> 'idle'
    AND wait_event IS NOT NULL
GROUP BY wait_event_type, wait_event
ORDER BY session_count DESC;
