#!/bin/bash

# Basic usage
# ls /existing/path
# echo "ls exit code: $?"  # 0 = success

# Conditional execution based on exit code
# mkdir test_dir
# if [ $? -eq 0 ]; then
#     echo "Directory created successfully"
# else
#     echo "Failed to create directory"
# fi


# Chain commands with exit code checking
# grep "INFO" log.txt
# if [ $? -eq 0 ]; then
#     echo "Pattern found"
# elif [ $? -eq 1 ]; then
#     echo "Pattern not found"
# else
#     echo "Error occurred"
# fi

# Set custom exit codes in scripts
# if [ $# -eq 0 ]; then
#     echo "Error: No arguments"
#     exit 1  # Error exit code
# fi
# echo "Success"
# exit 0  # Success exit code



# Standard exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2
readonly EXIT_FILE_NOT_FOUND=3
readonly EXIT_PERMISSION_DENIED=4

# Function to handle different error types
handle_error() {
    local error_code="$1"
    local error_message="$2"
    
    echo "ERROR: $error_message" >&2
    
    case $error_code in
        $EXIT_INVALID_ARGS)
            echo "Usage: $0 <arg1> <arg2>" >&2
            ;;
        $EXIT_FILE_NOT_FOUND)
            echo "Please check the file path and try again." >&2
            ;;
        $EXIT_PERMISSION_DENIED)
            echo "Please check file permissions." >&2
            ;;
    esac
    
    exit "$error_code"
}

# Example usage
if [ $# -lt 2 ]; then
    handle_error $EXIT_INVALID_ARGS "Insufficient arguments provided"
fi

if [ ! -f "$1" ]; then
    handle_error $EXIT_FILE_NOT_FOUND "File '$1' not found"
fi

if [ ! -r "$1" ]; then
    handle_error $EXIT_PERMISSION_DENIED "Cannot read file '$1'"
fi


#!/bin/bash

# Global log file
readonly LOG_FILE="/var/log/myscript.log"
readonly SCRIPT_NAME="$(basename "$0")"

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$SCRIPT_NAME] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        log "DEBUG" "$@"
    fi
}

# Setup logging
setup_logging() {
    local log_dir=$(dirname "$LOG_FILE")
    
    # Create log directory if it doesn't exist
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" || {
            echo "Failed to create log directory: $log_dir" >&2
            exit 1
        }
    fi
    
    # Start logging session
    log_info "Script started with PID: $$"
    log_info "Arguments: $*"
}

# Cleanup function
cleanup() {
    log_info "Script finished with exit code: $?"
}

# Set trap for cleanup
trap cleanup EXIT

# Example usage
setup_logging "$@"

log_info "Starting file processing"
if [ -f "input.txt" ]; then
    log_info "Input file found"
    # Process file...
else
    log_error "Input file not found"
    exit 1
fi



#!/bin/bash

# Enable debugging options
set -euo pipefail

# set -e: Exit on any command failure
# set -u: Exit on undefined variables
# set -o pipefail: Exit on pipe failures

# Function to demonstrate debugging
debug_example() {
    # set -x: Enable command tracing
    set -x
    
    echo "This command will be traced"
    ls -la /tmp
    
    # Disable tracing
    set +x
    
    echo "This command won't be traced"
}

# Conditional debugging
if [ "${DEBUG:-}" = "true" ]; then
    set -x
fi

# Error handler with debugging info
error_handler() {
    local line_number="$1"
    local error_code="$2"
    
    echo "ERROR: Script failed at line $line_number with exit code $error_code" >&2
    echo "Stack trace:" >&2
    local i=0
    while caller $i >/dev/null 2>&1; do
        echo "  $(caller $i)" >&2
        ((i++))
    done
    exit "$error_code"
}

# Set error trap
trap 'error_handler ${LINENO} $?' ERR

# Comprehensive error handling function
safe_execute() {
    local cmd="$1"
    local description="$2"
    
    log_info "Executing: $description"
    log_debug "Command: $cmd"
    
    if [ "${DEBUG:-}" = "true" ]; then
        set -x
    fi
    
    if ! eval "$cmd"; then
        log_error "$description failed"
        return 1
    fi
    
    if [ "${DEBUG:-}" = "true" ]; then
        set +x
    fi
    
    log_info "$description completed successfully"
    return 0
}

# Example with all error handling combined
main() {
    setup_logging "$@"
    
    log_info "Starting main process"
    
    # Safe command execution
    safe_execute "mkdir -p /tmp/test" "Create test directory" || exit 1
    safe_execute "touch /tmp/test/file.txt" "Create test file" || exit 1
    safe_execute "ls -la /tmp/test" "List test directory" || exit 1
    
    log_info "Main process completed successfully"
}

# Only run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi


# Best Practices Summary
# PATH Management: Always check if directories exist before adding to PATH
# Aliases: Use functions for complex operations instead of aliases
# Exit Codes: Use meaningful exit codes and handle them consistently
# Error Checking: Always check command return codes for critical operations
# Logging: Implement structured logging with timestamps and log levels
# Debugging: Use set -euo pipefail for strict error handling
# Cleanup: Always implement proper cleanup with trap handlers

