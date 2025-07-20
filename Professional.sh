#!/bin/bash

# =============================================================================
# PROFESSIONAL BASH DEVELOPMENT GUIDE - LEVEL 8
# =============================================================================

# =============================================================================
# 21. DEBUGGING & TESTING
# =============================================================================

# -----------------------------------------------------------------------------
# Debug Modes
# -----------------------------------------------------------------------------

# bash -x: Shows each command as it's executed (trace mode)
debug_trace_example() {
    echo "Starting debug trace example"
    local var="test"
    if [[ "$var" == "test" ]]; then
        echo "Variable matches!"
    fi
}

# bash -v: Shows each line as it's read (verbose mode)
debug_verbose_example() {
    echo "This shows the raw script lines"
    # Comments are also displayed in verbose mode
    local count=5
    echo "Count: $count"
}

# Enable debugging within script
enable_debug() {
    set -x  # Enable trace mode
    echo "Debug mode enabled"
    local test_var="debugging"
    echo "Test variable: $test_var"
    set +x  # Disable trace mode
    echo "Debug mode disabled"
}

# Conditional debugging
DEBUG=${DEBUG:-0}
debug_log() {
    [[ $DEBUG -eq 1 ]] && echo "[DEBUG] $*" >&2
}

debug_conditional_example() {
    debug_log "Starting function"
    local result=$((2 + 2))
    debug_log "Calculation result: $result"
    echo "Final result: $result"
}

# -----------------------------------------------------------------------------
# Testing Frameworks
# -----------------------------------------------------------------------------

# Simple test framework
run_tests() {
    local tests_passed=0
    local tests_failed=0
    
    echo "=== Running Tests ==="
    
    # Test 1: String comparison
    test_string_comparison() {
        local expected="hello"
        local actual="hello"
        
        if [[ "$actual" == "$expected" ]]; then
            echo "✓ String comparison test passed"
            ((tests_passed++))
        else
            echo "✗ String comparison test failed"
            ((tests_failed++))
        fi
    }
    
    # Test 2: Numeric comparison
    test_numeric_comparison() {
        local expected=10
        local actual=$((5 + 5))
        
        if [[ $actual -eq $expected ]]; then
            echo "✓ Numeric comparison test passed"
            ((tests_passed++))
        else
            echo "✗ Numeric comparison test failed"
            ((tests_failed++))
        fi
    }
    
    # Test 3: File operations
    test_file_operations() {
        local test_file="/tmp/test_file_$$"
        echo "test content" > "$test_file"
        
        if [[ -f "$test_file" ]]; then
            echo "✓ File creation test passed"
            ((tests_passed++))
            rm -f "$test_file"
        else
            echo "✗ File creation test failed"
            ((tests_failed++))
        fi
    }
    
    # Run all tests
    test_string_comparison
    test_numeric_comparison
    test_file_operations
    
    echo "=== Test Results ==="
    echo "Passed: $tests_passed"
    echo "Failed: $tests_failed"
    
    return $tests_failed
}

# Assert functions for testing
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$actual" != "$expected" ]]; then
        echo "ASSERTION FAILED: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
    return 0
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File does not exist: $file}"
    
    if [[ ! -f "$file" ]]; then
        echo "ASSERTION FAILED: $message"
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Code Validation with shellcheck
# -----------------------------------------------------------------------------

# Function to demonstrate shellcheck-compliant code
shellcheck_compliant_function() {
    # Use quotes around variables
    local input_file="$1"
    
    # Check if file exists before using
    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' not found" >&2
        return 1
    fi
    
    # Use arrays properly
    local file_list=()
    while IFS= read -r line; do
        file_list+=("$line")
    done < "$input_file"
    
    # Process array elements safely
    for file in "${file_list[@]}"; do
        if [[ -f "$file" ]]; then
            echo "Processing: $file"
        fi
    done
}

# Validate script with shellcheck (if available)
validate_script() {
    local script_file="$1"
    
    if command -v shellcheck >/dev/null 2>&1; then
        echo "Running shellcheck on $script_file"
        shellcheck "$script_file"
    else
        echo "shellcheck not available - install with: apt-get install shellcheck"
    fi
}

# -----------------------------------------------------------------------------
# Profiling & Performance Measurement
# -----------------------------------------------------------------------------

# Time measurement
profile_function() {
    local start_time end_time duration
    
    start_time=$(date +%s.%N)
    
    # Function to profile
    expensive_operation() {
        local count=1000
        for ((i=0; i<count; i++)); do
            echo "Operation $i" >/dev/null
        done
    }
    
    expensive_operation
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l)
    
    echo "Function took: ${duration} seconds"
}

# Memory usage tracking
track_memory_usage() {
    local pid=$$
    echo "Process ID: $pid"
    
    # Get memory info (Linux)
    if [[ -f "/proc/$pid/status" ]]; then
        grep -E "VmSize|VmRSS" "/proc/$pid/status"
    fi
    
    # Alternative using ps
    ps -o pid,vsz,rss,comm -p $pid
}

# Execution time wrapper
time_execution() {
    local cmd="$*"
    echo "Timing execution of: $cmd"
    
    { time $cmd; } 2>&1 | grep -E "real|user|sys"
}

# =============================================================================
# 22. DOCUMENTATION & MAINTENANCE
# =============================================================================

# -----------------------------------------------------------------------------
# Code Comments Best Practices
# -----------------------------------------------------------------------------

# Header comment block
#==============================================================================
# SCRIPT: example_script.sh
# DESCRIPTION: Demonstrates professional bash development practices
# AUTHOR: Your Name
# VERSION: 1.0.0
# CREATED: $(date +%Y-%m-%d)
# USAGE: ./example_script.sh [options] <arguments>
#==============================================================================

# Function with comprehensive documentation
#------------------------------------------------------------------------------
# FUNCTION: process_data
# DESCRIPTION: Processes input data and generates output report
# PARAMETERS:
#   $1 - input_file: Path to input data file
#   $2 - output_dir: Directory for output files (optional)
# RETURNS: 0 on success, 1 on error
# GLOBALS: None modified
# EXAMPLE: process_data "/data/input.txt" "/output"
#------------------------------------------------------------------------------
process_data() {
    local input_file="$1"
    local output_dir="${2:-/tmp}"
    
    # Validate input parameters
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing required parameter" >&2
        return 1
    fi
    
    # Main processing logic
    echo "Processing $input_file"
    # TODO: Add actual processing logic here
    
    return 0
}

# Inline comments for complex logic
complex_calculation() {
    local input="$1"
    
    # Calculate compound interest using formula: A = P(1 + r/n)^(nt)
    local principal="$input"
    local rate=0.05      # 5% annual interest rate
    local compounds=12   # Monthly compounding
    local years=10       # 10 year term
    
    # Convert to calculation-friendly format
    local result=$(echo "scale=2; $principal * (1 + $rate/$compounds)^($compounds*$years)" | bc -l)
    
    echo "$result"
}

# -----------------------------------------------------------------------------
# Help Functions
# -----------------------------------------------------------------------------

# Built-in help system
show_help() {
    cat << EOF
USAGE: ${0##*/} [OPTIONS] <command> [arguments]

DESCRIPTION:
    Professional bash script demonstrating best practices for development,
    debugging, testing, and maintenance.

COMMANDS:
    test        Run all test cases
    debug       Run debug examples
    profile     Run performance profiling
    validate    Validate script with shellcheck

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug mode
    --version       Show version information

EXAMPLES:
    ${0##*/} test                    # Run tests
    ${0##*/} --debug profile         # Profile with debug output
    ${0##*/} -v validate script.sh   # Validate script verbosely

AUTHOR: Professional Bash Developer
VERSION: 1.0.0
EOF
}

# Context-sensitive help
show_command_help() {
    local command="$1"
    
    case "$command" in
        test)
            echo "USAGE: $0 test"
            echo "Runs all available test cases and reports results"
            ;;
        debug)
            echo "USAGE: $0 debug [function_name]"
            echo "Demonstrates debugging techniques and trace modes"
            ;;
        profile)
            echo "USAGE: $0 profile [function_name]"
            echo "Profiles function execution time and memory usage"
            ;;
        *)
            echo "Unknown command: $command"
            echo "Use '$0 --help' for available commands"
            ;;
    esac
}

# Version information
show_version() {
    echo "${0##*/} version 1.0.0"
    echo "Professional Bash Development Framework"
    echo "Copyright (c) $(date +%Y) - Licensed under MIT"
}

# -----------------------------------------------------------------------------
# Version Control Integration
# -----------------------------------------------------------------------------

# Git hooks integration
setup_git_hooks() {
    local hooks_dir=".git/hooks"
    
    if [[ ! -d "$hooks_dir" ]]; then
        echo "Error: Not in a git repository"
        return 1
    fi
    
    # Pre-commit hook for shellcheck
    cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook to run shellcheck on bash scripts

for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$'); do
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck "$file" || exit 1
    fi
done
EOF
    
    chmod +x "$hooks_dir/pre-commit"
    echo "Git pre-commit hook installed"
}

# Get git information for script headers
get_git_info() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Git Branch: $(git branch --show-current)"
        echo "Last Commit: $(git log -1 --format='%h - %s (%an, %ar)')"
        echo "Repository: $(git config --get remote.origin.url)"
    else
        echo "Not in a git repository"
    fi
}

# -----------------------------------------------------------------------------
# Code Organization
# -----------------------------------------------------------------------------

# Configuration management
load_config() {
    local config_file="${1:-config.sh}"
    
    if [[ -f "$config_file" ]]; then
        # Safely source configuration
        # shellcheck source=/dev/null
        source "$config_file"
        echo "Configuration loaded from $config_file"
    else
        echo "Warning: Config file $config_file not found"
        # Set defaults
        DEBUG=${DEBUG:-0}
        VERBOSE=${VERBOSE:-0}
        LOG_LEVEL=${LOG_LEVEL:-INFO}
    fi
}

# Module loading system
load_module() {
    local module_name="$1"
    local module_path="modules/${module_name}.sh"
    
    if [[ -f "$module_path" ]]; then
        # shellcheck source=/dev/null
        source "$module_path"
        echo "Module $module_name loaded"
    else
        echo "Error: Module $module_name not found at $module_path" >&2
        return 1
    fi
}

# Library management
declare -A LOADED_LIBS

load_library() {
    local lib_name="$1"
    local lib_path="lib/${lib_name}.sh"
    
    # Check if already loaded
    if [[ ${LOADED_LIBS[$lib_name]} == "1" ]]; then
        return 0
    fi
    
    if [[ -f "$lib_path" ]]; then
        # shellcheck source=/dev/null
        source "$lib_path"
        LOADED_LIBS[$lib_name]="1"
        echo "Library $lib_name loaded"
    else
        echo "Error: Library $lib_name not found" >&2
        return 1
    fi
}

# =============================================================================
# 23. ADVANCED PATTERNS
# =============================================================================

# -----------------------------------------------------------------------------
# Design Patterns
# -----------------------------------------------------------------------------

# Singleton pattern
declare -g SINGLETON_INSTANCE

get_singleton() {
    if [[ -z "$SINGLETON_INSTANCE" ]]; then
        SINGLETON_INSTANCE="singleton_$$_$(date +%s)"
        echo "Created singleton instance: $SINGLETON_INSTANCE"
    fi
    echo "$SINGLETON_INSTANCE"
}

# Observer pattern
declare -A OBSERVERS

register_observer() {
    local event="$1"
    local callback="$2"
    
    OBSERVERS["$event"]+="$callback "
}

notify_observers() {
    local event="$1"
    shift
    local args="$*"
    
    if [[ -n "${OBSERVERS[$event]}" ]]; then
        for callback in ${OBSERVERS[$event]}; do
            if declare -f "$callback" >/dev/null; then
                $callback "$args"
            fi
        done
    fi
}

# Event handlers
on_file_created() {
    echo "File created: $1"
}

on_file_deleted() {
    echo "File deleted: $1"
}

# Factory pattern
create_object() {
    local type="$1"
    shift
    
    case "$type" in
        file)
            create_file_object "$@"
            ;;
        directory)
            create_directory_object "$@"
            ;;
        *)
            echo "Unknown object type: $type" >&2
            return 1
            ;;
    esac
}

create_file_object() {
    local filename="$1"
    local content="${2:-}"
    
    echo "Creating file object: $filename"
    if [[ -n "$content" ]]; then
        echo "$content" > "$filename"
    else
        touch "$filename"
    fi
}

create_directory_object() {
    local dirname="$1"
    echo "Creating directory object: $dirname"
    mkdir -p "$dirname"
}

# -----------------------------------------------------------------------------
# Error Recovery Strategies
# -----------------------------------------------------------------------------

# Retry mechanism with exponential backoff
retry_with_backoff() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    local command="$*"
    
    local attempt=1
    local current_delay="$delay"
    
    while [[ $attempt -le $max_attempts ]]; do
        echo "Attempt $attempt of $max_attempts: $command"
        
        if eval "$command"; then
            echo "Command succeeded on attempt $attempt"
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            echo "Command failed, retrying in ${current_delay}s..."
            sleep "$current_delay"
            current_delay=$((current_delay * 2))  # Exponential backoff
        fi
        
        ((attempt++))
    done
    
    echo "Command failed after $max_attempts attempts"
    return 1
}

# Circuit breaker pattern
declare -g CIRCUIT_FAILURES=0
declare -g CIRCUIT_STATE="CLOSED"  # CLOSED, OPEN, HALF_OPEN
declare -g CIRCUIT_LAST_FAILURE=0

circuit_breaker() {
    local command="$*"
    local max_failures=5
    local timeout=60
    local current_time
    current_time=$(date +%s)
    
    # Check circuit state
    case "$CIRCUIT_STATE" in
        OPEN)
            if [[ $((current_time - CIRCUIT_LAST_FAILURE)) -gt $timeout ]]; then
                CIRCUIT_STATE="HALF_OPEN"
                echo "Circuit breaker: HALF_OPEN"
            else
                echo "Circuit breaker: OPEN - rejecting request"
                return 1
            fi
            ;;
        HALF_OPEN)
            echo "Circuit breaker: HALF_OPEN - testing"
            ;;
        *)
            echo "Circuit breaker: CLOSED - normal operation"
            ;;
    esac
    
    # Execute command
    if eval "$command"; then
        CIRCUIT_FAILURES=0
        CIRCUIT_STATE="CLOSED"
        return 0
    else
        ((CIRCUIT_FAILURES++))
        CIRCUIT_LAST_FAILURE=$current_time
        
        if [[ $CIRCUIT_FAILURES -ge $max_failures ]]; then
            CIRCUIT_STATE="OPEN"
            echo "Circuit breaker: OPEN due to failures"
        fi
        return 1
    fi
}

# Graceful shutdown handler
declare -g SHUTDOWN_REQUESTED=0

graceful_shutdown() {
    echo "Shutdown requested - cleaning up..."
    SHUTDOWN_REQUESTED=1
    
    # Cleanup operations
    cleanup_temp_files
    save_state
    
    echo "Graceful shutdown completed"
    exit 0
}

cleanup_temp_files() {
    local temp_pattern="/tmp/$$_*"
    echo "Cleaning up temporary files: $temp_pattern"
    rm -f $temp_pattern 2>/dev/null || true
}

save_state() {
    echo "Saving application state..."
    # Implementation depends on application needs
}

# Set up signal handlers
trap graceful_shutdown SIGTERM SIGINT

# -----------------------------------------------------------------------------
# Configuration Management
# -----------------------------------------------------------------------------

# Advanced configuration with validation
declare -A CONFIG
declare -A CONFIG_VALIDATORS

# Configuration validators
validate_port() {
    local port="$1"
    if [[ $port =~ ^[0-9]+$ ]] && [[ $port -ge 1 ]] && [[ $port -le 65535 ]]; then
        return 0
    fi
    echo "Invalid port: $port" >&2
    return 1
}

validate_email() {
    local email="$1"
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    fi
    echo "Invalid email: $email" >&2
    return 1
}

# Register validators
CONFIG_VALIDATORS["port"]="validate_port"
CONFIG_VALIDATORS["email"]="validate_email"

# Set configuration value with validation
set_config() {
    local key="$1"
    local value="$2"
    
    # Check if validator exists
    if [[ -n "${CONFIG_VALIDATORS[$key]}" ]]; then
        local validator="${CONFIG_VALIDATORS[$key]}"
        if ! $validator "$value"; then
            echo "Configuration validation failed for $key" >&2
            return 1
        fi
    fi
    
    CONFIG["$key"]="$value"
    echo "Configuration set: $key=$value"
}

# Get configuration value with default
get_config() {
    local key="$1"
    local default="$2"
    
    echo "${CONFIG[$key]:-$default}"
}

# Load configuration from multiple sources
load_advanced_config() {
    local config_dir="${1:-config}"
    
    # Load default configuration
    if [[ -f "$config_dir/default.conf" ]]; then
        load_config_file "$config_dir/default.conf"
    fi
    
    # Load environment-specific configuration
    local env="${ENVIRONMENT:-development}"
    if [[ -f "$config_dir/$env.conf" ]]; then
        load_config_file "$config_dir/$env.conf"
    fi
    
    # Override with environment variables
    load_env_config
    
    # Validate all configuration
    validate_all_config
}

load_config_file() {
    local file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes from value
        value="${value%\"}"
        value="${value#\"}"
        
        set_config "$key" "$value"
    done < "$file"
}

load_env_config() {
    local prefix="APP_"
    
    while IFS='=' read -r name value; do
        if [[ $name == ${prefix}* ]]; then
            local key="${name#$prefix}"
            key="${key,,}"  # Convert to lowercase
            set_config "$key" "$value"
        fi
    done < <(env)
}

validate_all_config() {
    local errors=0
    
    for key in "${!CONFIG[@]}"; do
        if [[ -n "${CONFIG_VALIDATORS[$key]}" ]]; then
            local validator="${CONFIG_VALIDATORS[$key]}"
            if ! $validator "${CONFIG[$key]}"; then
                ((errors++))
            fi
        fi
    done
    
    if [[ $errors -gt 0 ]]; then
        echo "Configuration validation failed with $errors errors" >&2
        return 1
    fi
    
    echo "Configuration validation passed"
    return 0
}

# -----------------------------------------------------------------------------
# Plugin Architecture
# -----------------------------------------------------------------------------

# Plugin system
declare -A PLUGINS
declare -A PLUGIN_HOOKS

# Register plugin
register_plugin() {
    local plugin_name="$1"
    local plugin_path="$2"
    
    if [[ -f "$plugin_path" ]]; then
        PLUGINS["$plugin_name"]="$plugin_path"
        # shellcheck source=/dev/null
        source "$plugin_path"
        
        # Call plugin initialization if it exists
        if declare -f "plugin_${plugin_name}_init" >/dev/null; then
            "plugin_${plugin_name}_init"
        fi
        
        echo "Plugin registered: $plugin_name"
    else
        echo "Plugin not found: $plugin_path" >&2
        return 1
    fi
}

# Register hook
register_hook() {
    local hook_name="$1"
    local callback="$2"
    
    PLUGIN_HOOKS["$hook_name"]+="$callback "
    echo "Hook registered: $hook_name -> $callback"
}

# Execute hook
execute_hook() {
    local hook_name="$1"
    shift
    local args="$*"
    
    if [[ -n "${PLUGIN_HOOKS[$hook_name]}" ]]; then
        echo "Executing hook: $hook_name"
        for callback in ${PLUGIN_HOOKS[$hook_name]}; do
            if declare -f "$callback" >/dev/null; then
                echo "  -> $callback"
                $callback $args
            fi
        done
    fi
}

# Load all plugins from directory
load_plugins() {
    local plugins_dir="${1:-plugins}"
    
    if [[ -d "$plugins_dir" ]]; then
        for plugin_file in "$plugins_dir"/*.sh; do
            if [[ -f "$plugin_file" ]]; then
                local plugin_name
                plugin_name=$(basename "$plugin_file" .sh)
                register_plugin "$plugin_name" "$plugin_file"
            fi
        done
    fi
}

# Plugin discovery and metadata
get_plugin_info() {
    local plugin_name="$1"
    
    if [[ -n "${PLUGINS[$plugin_name]}" ]]; then
        local plugin_path="${PLUGINS[$plugin_name]}"
        echo "Plugin: $plugin_name"
        echo "Path: $plugin_path"
        
        # Extract metadata from plugin file
        if [[ -f "$plugin_path" ]]; then
            grep -E "^# (NAME|VERSION|DESCRIPTION|AUTHOR):" "$plugin_path" | \
            sed 's/^# //'
        fi
    else
        echo "Plugin not found: $plugin_name"
        return 1
    fi
}

# List all registered plugins
list_plugins() {
    echo "Registered Plugins:"
    for plugin_name in "${!PLUGINS[@]}"; do
        echo "  - $plugin_name (${PLUGINS[$plugin_name]})"
    done
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        test|tests)
            run_tests
            ;;
        debug)
            enable_debug
            debug_conditional_example
            ;;
        profile)
            profile_function
            track_memory_usage
            ;;
        validate)
            if [[ $# -gt 0 ]]; then
                validate_script "$1"
            else
                validate_script "$0"
            fi
            ;;
        config)
            load_advanced_config
            ;;
        plugins)
            load_plugins
            list_plugins
            ;;
        help|--help|-h)
            show_help
            ;;
        version|--version)
            show_version
            ;;
        *)
            echo "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Handle command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -d|--debug)
            DEBUG=1
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi