#!/bin/sh

: "${BACKUP_INTERVAL_CRON:=*/15 * * * *}"
: "${BACKUP_DIR:=/backups}"

mkdir -p /var/log
touch /var/log/cron.log

CRON_FILE="/etc/crontabs/root"
cat > "$CRON_FILE" <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-postgres}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}
PGPASSWORD=${PGPASSWORD:-${POSTGRES_PASSWORD:-}}
BACKUP_RETENTION_COUNT=${BACKUP_RETENTION_COUNT:-10}
BACKUP_DIR=${BACKUP_DIR}

${BACKUP_INTERVAL_CRON} /bin/sh /opt/backup/run_backup.sh >> /var/log/cron.log 2>&1
EOF

echo "[backup] Installed CRON schedule: ${BACKUP_INTERVAL_CRON}, keep ${BACKUP_RETENTION_COUNT:-10} dumps"
echo "[backup] Cron file:"
cat "$CRON_FILE"

exec crond -f -l 8