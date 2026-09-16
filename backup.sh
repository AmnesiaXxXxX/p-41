#!/bin/bash
DB_NAME=${POSTGRES_USER}
DB_USER=${POSTGRES_PASSWORD}
BACKUP_DIR=/backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Создаём директорию для бэкапов
mkdir -p "$BACKUP_DIR"

# Создаём дамп
pg_dump -U "$POSTGRES_USER" "$POSTGRES_PASSWORD" > "$BACKUP_DIR/backup_$TIMESTAMP.sql"

echo "Бэкап создан: backup_$TIMESTAMP.sql"