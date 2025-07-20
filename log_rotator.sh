#!/bin/bash
# log_rotator.sh - Automated log management and rotation

# Configuration
LOG_DIR="/var/log/myapp"
MAX_SIZE="100M"  # Maximum log file size
KEEP_DAYS=30     # Days to keep old logs
COMPRESS=true    # Compress old logs


# $(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile")
# stat -f%z (macOS/BSD):
# -f%z: Outputs file size in bytes.
# 2>/dev/null: Silences errors if this syntax fails.
# || stat -c%s (Linux fallback):
# -c%s: Linux alternative to get size in bytes.
# Runs only if the first stat fails.


# Function to rotate a single log file
rotate_log() {
    local logfile="$1"
    local basename=$(basename "$logfile")
    local dirname=$(dirname "$logfile")
    
    # Check if log file exists and size
    if [[ -f "$logfile" ]]; then
        local size=$(du -h "$logfile" | cut -f1)
        echo "Processing $logfile (Size: $size)"
        
        # Rotate if file is larger than MAX_SIZE
        if [[ $(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile") -gt $(echo $MAX_SIZE | sed 's/M/000000/') ]]; then
            # Create timestamp
            local timestamp=$(date +%Y%m%d_%H%M%S)
            
            # Move current log to timestamped version
            mv "$logfile" "${logfile}.${timestamp}"
            
            # Create new empty log file
            touch "$logfile"
            
            # Set appropriate permissions
            chmod 644 "$logfile"
            
            # Compress if enabled
            if [[ "$COMPRESS" == true ]]; then
                gzip "${logfile}.${timestamp}"
                echo "Compressed ${logfile}.${timestamp}"
            fi
            
            echo "Rotated $logfile"
        fi
    fi
}

# Function to clean old logs
cleanup_old_logs() {
    echo "Cleaning up logs older than $KEEP_DAYS days..."
    find "$LOG_DIR" -name "*.log.*" -mtime +$KEEP_DAYS -delete
    find "$LOG_DIR" -name "*.gz" -mtime +$KEEP_DAYS -delete
}

# Main execution
main() {
    echo "Starting log rotation at $(date)"
    
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"
    
    # Find and rotate all .log files
    find "$LOG_DIR" -name "*.log" -type f | while read logfile; do
        rotate_log "$logfile"
    done
    
    # Clean up old logs
    cleanup_old_logs
    
    echo "Log rotation completed at $(date)"
}

# Run main function
main "$@"