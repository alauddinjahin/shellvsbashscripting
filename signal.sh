#!/bin/bash

# Signal Handling

# trap command: Catching signals (INT, TERM, EXIT)
# Signal types: Common signals and their purposes
# Cleanup functions: Ensuring proper resource cleanup 



# Global variables for cleanup
TEMP_DIR=""
BACKGROUND_PIDS=()
LOCK_FILE=""

# Comprehensive cleanup function
cleanup_and_exit() {
    local exit_code=${1:-0}
    
    echo "Received signal. Starting cleanup..."
    
    # Kill background processes
    for pid in "${BACKGROUND_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Killing background process: $pid"
            kill "$pid"
            wait "$pid" 2>/dev/null
        fi
    done
    
    # Remove temporary directory
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        echo "Removing temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
    
    # Remove lock file
    if [[ -n "$LOCK_FILE" && -f "$LOCK_FILE" ]]; then
        echo "Removing lock file: $LOCK_FILE"
        rm -f "$LOCK_FILE"
    fi
    
    echo "Cleanup completed. Exiting with code: $exit_code"
    exit $exit_code
}

# Set up signal handlers
trap 'cleanup_and_exit 130' INT    # Ctrl+C
trap 'cleanup_and_exit 143' TERM   # Termination
trap 'cleanup_and_exit 129' HUP    # Hangup
trap 'cleanup_and_exit 0' EXIT     # Normal exit

# Initialize resources
TEMP_DIR=$(mktemp -d)
LOCK_FILE="/tmp/myscript.lock"

# Create lock file
echo $$ > "$LOCK_FILE"

# Start background processes
(while true; do echo "Background task 1"; sleep 5; done) &
BACKGROUND_PIDS+=($!)

(while true; do echo "Background task 2"; sleep 3; done) &
BACKGROUND_PIDS+=($!)

echo "Script initialized with PID: $$"
echo "Temporary directory: $TEMP_DIR"
echo "Lock file: $LOCK_FILE"
echo "Background processes: ${BACKGROUND_PIDS[*]}"

# Main script logic
for i in {1..20}; do
    echo "Main task: $i/20"
    echo "Some data" > "$TEMP_DIR/file_$i.txt"
    sleep 2
done

echo "Script completed successfully"




# Graceful shutdown with user confirmation
graceful_shutdown() {
    echo ""
    echo "Shutdown requested. Current operations in progress..."
    
    # Give user option to wait or force quit
    echo "Choose an option:"
    echo "1) Wait for current operations to complete (recommended)"
    echo "2) Force immediate shutdown"
    
    read -t 10 -p "Enter choice (1 or 2), or wait 10 seconds for automatic graceful shutdown: " choice
    
    case $choice in
        2)
            echo "Forcing immediate shutdown..."
            cleanup_and_exitV2 1
            ;;
        *)
            echo "Waiting for operations to complete..."
            GRACEFUL_SHUTDOWN=true
            ;;
    esac
}

# Cleanup function
cleanup_and_exitV2() {
    local exit_code=${1:-0}
    echo "Performing final cleanup..."
    
    # Stop services gracefully
    if pgrep -f "my_service" > /dev/null; then
        echo "Stopping services..."
        pkill -TERM -f "my_service"
        sleep 2
        pkill -KILL -f "my_service" 2>/dev/null
    fi
    
    # Save state
    echo "Saving application state..."
    # Implementation depends on your application
    
    exit $exit_code
}

# Global flag for graceful shutdown
GRACEFUL_SHUTDOWN=false

# Set up signal handlers
trap graceful_shutdown INT TERM
trap 'cleanup_and_exit 0' EXIT

# Main application loop
echo "Application started. Press Ctrl+C for graceful shutdown."

counter=0
while true; do
    # Check for graceful shutdown flag
    if [[ "$GRACEFUL_SHUTDOWN" == "true" ]]; then
        echo "Completing current operation and shutting down..."
        break
    fi
    
    # Simulate work
    echo "Processing operation $((++counter))..."
    sleep 2
    
    # Simulate long-running operations
    if ((counter % 5 == 0)); then
        echo "Starting long operation (10 seconds)..."
        for i in {1..10}; do
            if [[ "$GRACEFUL_SHUTDOWN" == "true" ]]; then
                echo "Graceful shutdown requested. Finishing operation..."
                sleep 1  # Allow operation to complete
            else
                sleep 1
            fi
        done
        echo "Long operation completed"
    fi
done

echo "Application shutdown completed"





# Signal-safe logging mechanism
LOG_FILE="/tmp/myscript.log"
SIGNAL_LOG="/tmp/myscript_signals.log"

# Signal-safe log function
log_signal() {
    local signal="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Signal $signal received by PID $$" >> "$SIGNAL_LOG"
}

# Regular log function
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Signal handlers with logging
handle_sigint() {
    log_signal "SIGINT"
    echo ""
    echo "Interrupt signal received. Shutting down gracefully..."
    exit 130
}

handle_sigterm() {
    log_signal "SIGTERM"
    echo "Termination signal received. Shutting down..."
    exit 143
}

handle_sigusr1() {
    log_signal "SIGUSR1"
    echo "User signal 1 received. Rotating logs..."
    mv "$LOG_FILE" "${LOG_FILE}.$(date +%s)"
    touch "$LOG_FILE"
}

# Set up signal handlers
trap handle_sigint INT
trap handle_sigterm TERM
trap handle_sigusr1 USR1
trap 'log_signal "EXIT"' EXIT

log_message "Script started with PID: $$"
echo "Script started. Send signals with: kill -USR1 $$"

# Main loop
for i in {1..60}; do
    log_message "Heartbeat $i"
    echo "Running... $i/60 (send SIGUSR1 to rotate logs)"
    sleep 1
done

log_message "Script completed normally"