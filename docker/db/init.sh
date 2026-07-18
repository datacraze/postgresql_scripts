#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

require_identifier() {
    [[ $1 =~ ^[a-z][a-z0-9_]{0,62}$ ]] || fail "Invalid PostgreSQL identifier: $1"
}

require_password() {
    [ "${#1}" -ge 16 ] || fail "Passwords must contain at least 16 characters."
    [[ $1 != '<'*'>' ]] || fail "Replace password placeholders before starting Docker."
}

role_exists() {
    local role_name=$1
    local result

    result=$(psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
        -v role_name="$role_name" -tA <<'EOSQL'
SELECT 1 FROM pg_roles WHERE rolname = :'role_name';
EOSQL
    )
    [ "$result" = '1' ]
}

create_login_role() {
    local role_name=$1
    local role_password=$2

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
        -v role_name="$role_name" -v role_password="$role_password" <<'EOSQL'
CREATE ROLE :"role_name" LOGIN PASSWORD :'role_password'
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
EOSQL
}

ensure_login_role() {
    local role_name=$1
    local role_password=$2

    if role_exists "$role_name"; then
        psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
            -v role_name="$role_name" <<'EOSQL'
ALTER ROLE :"role_name" NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
EOSQL
    else
        create_login_role "$role_name" "$role_password"
    fi
}

database_exists() {
    local result

    result=$(psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
        -v database_name="$DC_DB" -tA <<'EOSQL'
SELECT 1 FROM pg_database WHERE datname = :'database_name';
EOSQL
    )
    [ "$result" = '1' ]
}

create_database() {
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
        -v database_name="$DC_DB" -v admin_role="$DC_ADMIN_USER" <<'EOSQL'
CREATE DATABASE :"database_name" OWNER :"admin_role";
EOSQL
}

configure_access() {
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$DC_DB" \
        -v database_name="$DC_DB" -v admin_role="$DC_ADMIN_USER" \
        -v readonly_role="$DC_READONLY_USER" <<'EOSQL'
REVOKE ALL ON DATABASE :"database_name" FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT CONNECT, TEMPORARY ON DATABASE :"database_name" TO :"admin_role";
GRANT CONNECT ON DATABASE :"database_name" TO :"readonly_role";
EOSQL
}

install_diagnostic_extensions() {
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$DC_DB" <<'EOSQL'
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pgstattuple;
EOSQL
}

validate_configuration() {
    POSTGRES_USER=${POSTGRES_USER:-postgres}
    : "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set}"
    : "${DC_ADMIN_USER:?DC_ADMIN_USER must be set}"
    : "${DC_ADMIN_USER_PASSWORD:?DC_ADMIN_USER_PASSWORD must be set}"
    : "${DC_READONLY_USER:?DC_READONLY_USER must be set}"
    : "${DC_READONLY_USER_PASSWORD:?DC_READONLY_USER_PASSWORD must be set}"
    : "${DC_DB:?DC_DB must be set}"

    require_identifier "$POSTGRES_USER"
    require_identifier "$DC_ADMIN_USER"
    require_identifier "$DC_READONLY_USER"
    require_identifier "$DC_DB"
    [ "$DC_ADMIN_USER" != "$POSTGRES_USER" ] || fail "DC_ADMIN_USER must not be POSTGRES_USER."
    [ "$DC_READONLY_USER" != "$POSTGRES_USER" ] || fail "DC_READONLY_USER must not be POSTGRES_USER."
    [ "$DC_ADMIN_USER" != "$DC_READONLY_USER" ] || fail "Application role names must differ."
    [ "$DC_READONLY_USER" != 'readonly' ] || fail "DC_READONLY_USER must not be readonly."
    require_password "$POSTGRES_PASSWORD"
    require_password "$DC_ADMIN_USER_PASSWORD"
    require_password "$DC_READONLY_USER_PASSWORD"
}

validate_configuration

if [ "${1:-}" = '--preflight' ]; then
    exit 0
fi

ensure_login_role "$DC_ADMIN_USER" "$DC_ADMIN_USER_PASSWORD"
ensure_login_role "$DC_READONLY_USER" "$DC_READONLY_USER_PASSWORD"
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
    -v readonly_role="$DC_READONLY_USER" <<'EOSQL'
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readonly') THEN
        CREATE ROLE readonly NOLOGIN;
    END IF;
END
$$;
GRANT readonly TO :"readonly_role";
EOSQL

if database_exists; then
    fail "Database $DC_DB already exists; initialization is intentionally one-time."
fi

create_database
configure_access
install_diagnostic_extensions
touch "$PGDATA/.postgresql-scripts-bootstrap-complete"
