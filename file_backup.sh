#!/bin/bash
# file_backup.sh - Comprehensive file and directory backup

# Configuration
SOURCE_DIRS=("/home/user/documents" "/etc" "/var/www")
BACKUP_ROOT="/backup"
RETENTION_DAYS=7
EXCLUDE_PATTERNS=("*.tmp" "*.log" ".cache")




# This code performs incremental backups using rsync, where it either:
# Creates a full backup (if no previous backup exists), or
# Creates an incremental backup (hard-linking unchanged files from the previous backup to save space).


# Option	Purpose
# -a (archive)	    Preserves permissions, timestamps, symlinks, etc. (recursive + verbose)
# -v (verbose)	    Shows progress.
# -H (hard-links)	Preserves hard links (critical for incremental backups).
# --delete	        Deletes files in $new_backup if they no longer exist in $source.
# $exclude_opts	Custom excludes (e.g., --exclude='*.tmp').
# --link-dest=...	Key for incremental backups: Hard-links unchanged files from $current_backup to $new_backup (saving disk space).
# "$source/"	    Source directory (trailing / ensures contents are copied, not the dir itself).
# "$new_backup/"	Destination directory.


# Function to create incremental backup
create_backup() {
    local source="$1"
    local backup_name=$(basename "$source")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_ROOT/$backup_name"
    local current_backup="$backup_dir/current"
    local new_backup="$backup_dir/$timestamp"
    
    echo "Backing up $source to $new_backup"
    
    # Create backup directory structure
    mkdir -p "$backup_dir"
    
    # Build exclude options
    local exclude_opts=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_opts="$exclude_opts --exclude=$pattern"
    done
    
    # Perform incremental backup using rsync
    if [[ -d "$current_backup" ]]; then
        # Incremental backup
        rsync -avH --delete $exclude_opts --link-dest="$current_backup" "$source/" "$new_backup/"
    else
        # First backup
        rsync -avH $exclude_opts "$source/" "$new_backup/"
    fi
    
    # Update current symlink
    rm -f "$current_backup"
    ln -sf "$timestamp" "$current_backup"
    
    echo "Backup completed: $new_backup"
}

# Function to cleanup old backups
cleanup_backups() {
    echo "Cleaning up backups older than $RETENTION_DAYS days..."
    
    for source_dir in "${SOURCE_DIRS[@]}"; do
        local backup_name=$(basename "$source_dir")
        local backup_dir="$BACKUP_ROOT/$backup_name"
        
        if [[ -d "$backup_dir" ]]; then
            find "$backup_dir" -maxdepth 1 -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;
        fi
    done
}

# Main backup function
main() {
    echo "Starting backup process at $(date)"
    
    # Create backup root directory
    mkdir -p "$BACKUP_ROOT"
    
    # Backup each source directory
    for source in "${SOURCE_DIRS[@]}"; do
        if [[ -d "$source" ]]; then
            create_backup "$source"
        else
            echo "Warning: Source directory $source does not exist"
        fi
    done
    
    # Cleanup old backups
    cleanup_backups
    
    echo "Backup process completed at $(date)"
}

main "$@"