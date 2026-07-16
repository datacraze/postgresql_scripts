-- Run as an authorized DBA after replacing diagnostic_role.
-- The diagnostic views require PostgreSQL 15+ and run with the grantee's
-- catalog privileges because they use security_invoker.

GRANT USAGE ON SCHEMA dba_advisor TO diagnostic_role;
GRANT SELECT ON ALL TABLES IN SCHEMA dba_advisor TO diagnostic_role;

-- Do not grant pg_read_all_stats by default. It enables direct access to
-- pg_stat_activity.query and other sensitive monitoring data. Review that
-- privilege separately when full cross-session diagnostics are justified.
