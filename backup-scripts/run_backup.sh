#!/bin/sh

: "${POSTGRES_HOST:=postgres}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_DB:=postgres}"
: "${POSTGRES_USER:=postgres}"
: "${PGPASSWORD:=${POSTGRES_PASSWORD:-}}"
: "${BACKUP_DIR:=/backups}"
: "${RETENTION_COUNT:=${BACKUP_RETENTION_COUNT:-10}}"

mkdir -p "$BACKUP_DIR"

LOCK_DIR="/tmp/pg_backup.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "[backup] Another backup is running (lock: $LOCK_DIR). Exit."
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${BACKUP_DIR}/${POSTGRES_DB}_${TS}.dump"

echo "[backup] Starting backup for DB=${POSTGRES_DB} at ${TS}"

PGPASSWORD="$PGPASSWORD" pg_dump \
  -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -Fc -Z 9 -f "$OUT"

ln -sfn "$OUT" "${BACKUP_DIR}/${POSTGRES_DB}_latest.dump"

echo "[backup] Created ${OUT}"

if [ "$RETENTION_COUNT" -gt 0 ] 2>/dev/null; then
  ls -1t "${BACKUP_DIR}/${POSTGRES_DB}_"*.dump 2>/dev/null | awk "NR>${RETENTION_COUNT}" | xargs -r rm -f
  echo "[backup] Pruned to last ${RETENTION_COUNT} dumps"
fi

echo "[backup] Done."