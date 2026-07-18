-- Run as an authorized DBA after replacing diagnostic_role.
-- The diagnostic views require PostgreSQL 15+ and run with the grantee's
-- catalog privileges because they use security_invoker.

GRANT USAGE ON SCHEMA dba_advisor TO diagnostic_role;
GRANT SELECT ON ALL TABLES IN SCHEMA dba_advisor TO diagnostic_role;

-- The grant above is a snapshot of the views installed so far. Uncomment to
-- cover views created in dba_advisor later.
-- ALTER DEFAULT PRIVILEGES IN SCHEMA dba_advisor
-- GRANT SELECT ON TABLES TO diagnostic_role;

-- GRANT pg_stat_scan_tables TO diagnostic_role; -- required for 210/220

-- Without pg_read_all_stats, the pg_stat_activity-based views return NULL
-- columns for sessions belonging to other roles.
-- Do not grant pg_read_all_stats by default. It enables direct access to
-- pg_stat_activity.query and other sensitive monitoring data. Review that
-- privilege separately when full cross-session diagnostics are justified.
