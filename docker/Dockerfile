FROM postgres:18.4-trixie@sha256:c2d42a104eb6b37b286a2d9c5cf83f349de4d6516d513d00a2bd9610e2c2e5e4

HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=5 \
  CMD pg_isready -U "${POSTGRES_USER:-postgres}"

COPY --chmod=755 db/init.sh /docker-entrypoint-initdb.d/init.sh

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/custom-entrypoint.sh

ENTRYPOINT ["custom-entrypoint.sh"]
CMD ["postgres", "-c", "shared_preload_libraries=pg_stat_statements"]
