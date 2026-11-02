#!/bin/sh
# Dumps the game and login databases to BACKUP_DIR, keeping KEEP_DAYS days. Run from cron; see README.md.
set -eu
cd "$(dirname "$0")"
BACKUP_DIR="${BACKUP_DIR:-$HOME/voidforged/backups}"
KEEP_DAYS="${KEEP_DAYS:-14}"
stamp=$(date +%Y-%m-%d_%H%M)
umask 077
mkdir -p "$BACKUP_DIR"

dump() {
	tmp="$BACKUP_DIR/.$1_$stamp.tmp"
	docker compose exec -T db sh -c "mariadb-dump -uroot -p\"\$MARIADB_ROOT_PASSWORD\" --single-transaction --routines \
		--triggers --events --max-allowed-packet=256M --default-character-set=utf8mb4 $1" | gzip -6 > "$tmp"
	# A dump that stopped early has no closing line, so it never replaces a good one
	if ! gzip -dc "$tmp" | tail -n 1 | grep -q 'Dump completed'; then
		rm -f "$tmp"
		echo "backup of $1 failed" >&2
		exit 1
	fi
	mv "$tmp" "$BACKUP_DIR/$1_$stamp.sql.gz"
}

dump "${DB_NAME:-peq}"
dump "${LOGIN_DB_NAME:-voidforged_login}"
find "$BACKUP_DIR" -name '*.sql.gz' -mtime +"$KEEP_DAYS" -delete
echo "backup ok $stamp"
