-- Purpose: find sessions idle while a transaction remains open.
-- Requires: visibility into pg_stat_activity.
-- Usage: run directly with psql; this is a read-only SELECT query.
-- Scope: cluster-wide, because an idle transaction in any database can hold
-- back vacuum and the shared transaction-ID horizon.
-- Privacy: query text, client addresses, roles, and application names are
-- intentionally omitted.

SELECT
    pid,
    xact_start,
    state_change,
    wait_event_type,
    wait_event,
    clock_timestamp() - xact_start AS transaction_age,
    clock_timestamp() - state_change AS idle_age
FROM pg_stat_activity
WHERE state IN ('idle in transaction', 'idle in transaction (aborted)')
ORDER BY xact_start ASC NULLS LAST;
