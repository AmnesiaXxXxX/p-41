#!/bin/bash
BACKUP_DIR=/backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Создаём директорию для бэкапов
mkdir -p "$BACKUP_DIR"

# Создаём дамп
pg_dumpall -U "$POSTGRES_USER" > "$BACKUP_DIR/backup_$TIMESTAMP.sql"

echo "Бэкап создан: backup_$TIMESTAMP.sql"