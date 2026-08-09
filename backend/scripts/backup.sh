#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-./backups}"
RETENTION_DAYS="${2:-30}"

mkdir -p "$DIR"
stamp="$(date +%Y%m%d_%H%M%S)"
out="$DIR/ma_warehouse_${stamp}.dump"

docker exec ma-warehouse-db pg_dump -U postgres -d ma_warehouse -Fc -f /tmp/ma_backup.dump
docker cp ma-warehouse-db:/tmp/ma_backup.dump "$out"
docker exec ma-warehouse-db rm -f /tmp/ma_backup.dump

find "$DIR" -name "*.dump" -mtime "+$RETENTION_DAYS" -delete

echo "Backup OK: $out"
