#!/usr/bin/env bash
set -Eeo pipefail

source "$(which docker-entrypoint.sh)"

if [ "${1:0:1}" = '-' ]; then
    set -- postgres "$@"
fi

if [ "$1" = 'postgres' ] && ! _pg_want_help "$@"; then
	docker_setup_env
	docker_create_db_directories

	if [ "$(id -u)" = '0' ]; then
		exec gosu postgres "$BASH_SOURCE" "$@"
	fi

	if [ ! -s "$PGDATA/PG_VERSION" ]; then
		bash /docker-entrypoint-initdb.d/init.sh --preflight
		docker_verify_minimum_env
		docker_init_database_dir
		pg_setup_hba_conf "$@"

		# Only required for '--auth[-local]=md5' on POSTGRES_INITDB_ARGS.
		export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"

		docker_temp_server_start "$@" -c max_locks_per_transaction=256
		docker_setup_db
		docker_process_init_files /docker-entrypoint-initdb.d/*
		docker_temp_server_stop
	elif [ ! -f "$PGDATA/.postgresql-scripts-bootstrap-complete" ]; then
		echo "Refusing to start an incomplete PostgreSQL Scripts bootstrap." >&2
		exit 1
	fi
fi

exec "$@"
