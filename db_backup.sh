#!/bin/bash
# db_backup.sh - Database backup with multiple database support

# Configuration
DB_HOST="localhost"
DB_USER="backup_user"
DB_PASS="backup_password"  # Better to use .my.cnf or environment variables
BACKUP_DIR="/backup/databases"
RETENTION_DAYS=14
COMPRESS=true

# Database configurations
declare -A DATABASES=(
    ["mysql"]="mysql mysqldump"
    ["postgresql"]="postgres pg_dump"
)

# Function to backup MySQL database
backup_mysql() {
    local db_name="$1"
    local backup_file="$2"
    
    echo "Backing up MySQL database: $db_name"
    
    if mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" \
        --single-transaction --routines --triggers "$db_name" > "$backup_file"; then
        echo "MySQL backup successful: $backup_file"
        return 0
    else
        echo "MySQL backup failed for $db_name"
        return 1
    fi
}


# Includes:
# Database schema
# Data
# Stored procedures (--routines)
# Triggers (--triggers)


# Option/Part	Purpose
# -h "$DB_HOST"	Connects to the MySQL server at host $DB_HOST (e.g., localhost).
# -u "$DB_USER"	Logs in with username $DB_USER.
# -p"$DB_PASS"	Uses password $DB_PASS (no space after -p!).
# --single-transaction	Critical for live DBs: Runs a consistent backup without locking tables (uses transactions).
# --routines	Includes stored procedures/functions in the backup.
# --triggers	Includes triggers in the backup.
# "$db_name"	Name of the database to back up.
# > "$backup_file"	Redirects the backup output to a file (e.g., backup.sql).



# Function to backup PostgreSQL database
backup_postgresql() {
    local db_name="$1"
    local backup_file="$2"
    
    echo "Backing up PostgreSQL database: $db_name"
    
    export PGPASSWORD="$DB_PASS"
    if pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$db_name" > "$backup_file"; then
        echo "PostgreSQL backup successful: $backup_file"
        return 0
    else
        echo "PostgreSQL backup failed for $db_name"
        return 1
    fi
}

# Function to compress backup file
compress_backup() {
    local file="$1"
    
    if [[ "$COMPRESS" == true && -f "$file" ]]; then
        echo "Compressing $file"
        gzip "$file"
        echo "Compressed to ${file}.gz"
    fi
}

# Function to get database list
get_databases() {
    local db_type="$1"
    
    case "$db_type" in
        "mysql")
            mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | tail -n +2 | grep -v -E '^(information_schema|performance_schema|sys)$'
            ;;
        "postgresql")
            export PGPASSWORD="$DB_PASS"
            psql -h "$DB_HOST" -U "$DB_USER" -d postgres -t -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname != 'postgres';" | grep -v '^$'
            ;;
    esac
}

# Main backup function
main() {
    echo "Starting database backup at $(date)"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Backup each database type
    for db_type in "${!DATABASES[@]}"; do
        echo "Processing $db_type databases..."
        
        # Get list of databases
        local db_list=$(get_databases "$db_type")
        
        for db_name in $db_list; do
            db_name=$(echo "$db_name" | tr -d ' ')  # Remove whitespace
            local backup_file="$BACKUP_DIR/${db_type}_${db_name}_${timestamp}.sql"
            
            case "$db_type" in
                "mysql")
                    backup_mysql "$db_name" "$backup_file"
                    ;;
                "postgresql")
                    backup_postgresql "$db_name" "$backup_file"
                    ;;
            esac
            
            if [[ $? -eq 0 ]]; then
                compress_backup "$backup_file"
            fi
        done
    done
    
    # Cleanup old backups
    echo "Cleaning up old backups..."
    find "$BACKUP_DIR" -name "*.sql*" -mtime +$RETENTION_DAYS -delete
    
    echo "Database backup completed at $(date)"
}

main "$@"