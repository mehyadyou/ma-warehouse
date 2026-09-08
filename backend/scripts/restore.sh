#!/usr/bin/env bash
set -euo pipefail

FILE="${1:?Usage: restore.sh <backup.dump> [--drop-first]}"
DROP_FIRST="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

get_env() {
    local key="$1" fallback="${2:-}"
    local val=""
    if [ -f "$ENV_FILE" ]; then
        val="$(grep -E "^[[:space:]]*${key}[[:space:]]*=" "$ENV_FILE" | tail -n1 | sed -E 's/^[^=]*=[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/')"
    fi
    if [ -z "$val" ]; then val="$fallback"; fi
    printf '%s' "$val"
}

POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(get_env POSTGRES_PASSWORD)}"
DATABASE_NAME="${DATABASE_NAME:-$(get_env DATABASE_NAME "ma_warehouse")}"
if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "POSTGRES_PASSWORD missing (.env یا متغیر محیطی)" >&2
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Backup file not found: $FILE" >&2
  exit 1
fi

# ── راستی‌آزمایی چک‌سام قبل از بازیابی (اگر فایل .sha256 کنار بکاپ هست) ──
if [ -f "$FILE.sha256" ]; then
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "$FILE")" && sha256sum -c "$(basename "$FILE").sha256") || { echo "SHA256 mismatch!" >&2; exit 1; }
  elif command -v shasum >/dev/null 2>&1; then
    (cd "$(dirname "$FILE")" && shasum -a 256 -c "$(basename "$FILE").sha256") || { echo "SHA256 mismatch!" >&2; exit 1; }
  fi
fi

export PGPASSWORD="$POSTGRES_PASSWORD"
if [[ "$DROP_FIRST" == "--drop-first" ]]; then
  echo "Dropping and recreating database..."
  docker exec -e "PGPASSWORD=$POSTGRES_PASSWORD" -i ma-warehouse-db psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS $DATABASE_NAME WITH (FORCE);"
  docker exec -e "PGPASSWORD=$POSTGRES_PASSWORD" -i ma-warehouse-db psql -U postgres -d postgres -c "CREATE DATABASE $DATABASE_NAME;"
fi

docker exec -i -e "PGPASSWORD=$POSTGRES_PASSWORD" ma-warehouse-db pg_restore -U postgres -d "$DATABASE_NAME" --no-owner --clean --if-exists < "$FILE"
unset PGPASSWORD

echo "Restore OK from: $FILE"
