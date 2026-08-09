#!/usr/bin/env bash
set -euo pipefail

FILE="${1:?Usage: restore.sh <backup.dump> [--drop-first]}"
DROP_FIRST="${2:-}"

if [[ ! -f "$FILE" ]]; then
  echo "Backup file not found: $FILE" >&2
  exit 1
fi

if [[ "$DROP_FIRST" == "--drop-first" ]]; then
  echo "Dropping and recreating database..."
  docker exec -i ma-warehouse-db psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS ma_warehouse WITH (FORCE);"
  docker exec -i ma-warehouse-db psql -U postgres -d postgres -c "CREATE DATABASE ma_warehouse;"
fi

docker exec -i ma-warehouse-db pg_restore -U postgres -d ma_warehouse --no-owner --clean --if-exists < "$FILE"

echo "Restore OK from: $FILE"
