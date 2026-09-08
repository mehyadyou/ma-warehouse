#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-./backups}"
RETENTION_DAYS="${2:-30}"
REMOTE_DIR="${3:-${BACKUP_REMOTE_DIR:-}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

# ── خواندن POSTGRES_PASSWORD و DATABASE_NAME از .env (سازگار با scram-sha-256) ──
# backup.ps1 همین کار را می‌کند؛ backup.sh قبلی PGPASSWORD نداشت و با scram شکست می‌خورد.
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

mkdir -p "$DIR"
stamp="$(date +%Y%m%d_%H%M%S)"
out="$DIR/ma_warehouse_${stamp}.dump"

export PGPASSWORD="$POSTGRES_PASSWORD"
docker exec -e "PGPASSWORD=$POSTGRES_PASSWORD" ma-warehouse-db pg_dump -U postgres -d "$DATABASE_NAME" -Fc -f /tmp/ma_backup.dump
docker cp ma-warehouse-db:/tmp/ma_backup.dump "$out"
docker exec ma-warehouse-db rm -f /tmp/ma_backup.dump
unset PGPASSWORD

# ── چک‌سام SHA256 برای راستی‌آزمایی انتقال آفسایت ──
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$out" > "$out.sha256"
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$out" > "$out.sha256"
fi

find "$DIR" -name "*.dump" -mtime "+$RETENTION_DAYS" -delete
find "$DIR" -name "*.dump.sha256" -mtime "+$RETENTION_DAYS" -delete

# ── کپی آفسایت (اختیاری): BACKUP_REMOTE_DIR یا آرگومان سوم ──
if [ -n "$REMOTE_DIR" ]; then
    mkdir -p "$REMOTE_DIR"
    cp -f "$out" "$REMOTE_DIR/"
    [ -f "$out.sha256" ] && cp -f "$out.sha256" "$REMOTE_DIR/"
    echo "Remote copy OK: $REMOTE_DIR"
fi

echo "Backup OK: $out"
