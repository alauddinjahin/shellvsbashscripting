# Method 1: function keyword
function function_name() {
    echo "with keyword"
}

# Method 2: without function keyword (preferred)
# function_name() {
#     echo "without keyword"
# }

# # Simple example
# greet() {
#     echo "Hello, World!"
# }

# # Call the function
# greet

# # Function with basic logic
# check_file() {
#     if [ -f "$1" ]; then
#         echo "File $1 exists"
#     else
#         echo "File $1 does not exist"
#     fi
# }

# check_file "test.txt"


# function_name

# System information function
system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    # echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    # echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    # echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3"/"$2}')"
    # echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
}


# system_info

# Network utilities function
network_check() {
    echo "=== Network Status ==="
    echo "IP Address: $(ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}')"
    echo "Default Gateway: $(ip route | grep default | awk '{print $3}')"
    echo "DNS Servers: $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ' ')"
    
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "Internet: Connected"
    else
        echo "Internet: Disconnected"
    fi
}


# network_check

# Function with parameters
create_user() {
    echo "Creating user: $1"
    echo "With home directory: $2"
    echo "Shell: $3"
    echo "Number of parameters: $#"
    echo "All parameters: $@"
}

# create_user "john" "/home/john" "/bin/bash"


# Math operations
calculate() {
    local operation="$1"
    local num1="$2"
    local num2="$3"
    
    case $operation in
        "add"|"+")
            echo "$((num1 + num2))"
            ;;
        "subtract"|"-")
            echo "$((num1 - num2))"
            ;;
        "multiply"|"*")
            echo "$((num1 * num2))"
            ;;
        "divide"|"/")
            if [ "$num2" -ne 0 ]; then
                echo "$((num1 / num2))"
            else
                echo "Error: Division by zero"
                return 1
            fi
            ;;
        *)
            echo "Error: Unknown operation '$operation'"
            echo "Supported: add, subtract, multiply, divide"
            return 1
            ;;
    esac
}

# echo "5 + 3 = $(calculate add 5 3)"
# echo "10 - 4 = $(calculate subtract 10 4)"
# echo "6 * 7 = $(calculate multiply 6 7)"
# echo "15 / 3 = $(calculate divide 15 3)"


# Process files function
process_files() {
    if [ $# -eq 0 ]; then
        echo "No files specified"
        return 1
    fi
    
    echo "Processing $# files..."
    
    for file in "$@"; do
        if [ -f "$file" ]; then
            echo "Processing: $file"
            echo "  Size: $(du -h "$file" | cut -f1)"
            echo "  Lines: $(wc -l < "$file")"
            echo "  Words: $(wc -w < "$file")"
        else
            echo "Warning: '$file' is not a valid file"
        fi
    done
}

# process_files *.txt *.log


# Function returning exit codes
validate_email() {
    local email="$1"
    
    if [ -z "$email" ]; then
        echo "Error: Email cannot be empty"
        return 1
    fi
    
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo "Valid email: $email"
        return 0
    else
        echo "Invalid email format: $email"
        return 2
    fi
}

# Using return values
# validate_email "user@example.com"
# result=$?
# echo "Return code: $result"

# validate_email "invalid-email"
# result=$?
# echo "Return code: $result"

# validate_email ""
# result=$?
# echo "Return code: $result"

# Service management with return codes
# start_service() {
#     local service_name="$1"
    
#     if [ -z "$service_name" ]; then
#         echo "Error: Service name required"
#         return 1
#     fi
    
#     if systemctl is-active --quiet "$service_name"; then
#         echo "Service $service_name is already running"
#         return 0
#     fi
    
#     if systemctl start "$service_name" 2>/dev/null; then
#         echo "Service $service_name started successfully"
#         return 0
#     else
#         echo "Failed to start service $service_name"
#         return 3
#     fi
# }

# # Using function with conditional logic
# if start_service "nginx"; then
#     echo "Service operation successful"
# else
#     case $? in
#         1) echo "Invalid parameters" ;;
#         3) echo "Service start failed" ;;
#         *) echo "Unknown error" ;;
#     esac
# fi



# Function that outputs values
# get_system_stats() {
#     local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
#     local memory_usage=$(free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100.0}')
#     local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    
#     echo "$cpu_usage,$memory_usage,$disk_usage"
# }

# # Capture output
# stats=$(get_system_stats)
# IFS=',' read -r cpu mem disk <<< "$stats"
# echo "CPU: ${cpu}%"
# echo "Memory: ${mem}%"
# echo "Disk: ${disk}%"



#!/bin/bash
# Mathematical functions library

# Basic arithmetic functions
math_add() {
    echo "$(($1 + $2))"
}

math_subtract() {
    echo "$(($1 - $2))"
}

math_multiply() {
    echo "$(($1 * $2))"
}

math_divide() {
    if [ "$2" -eq 0 ]; then
        echo "Error: Division by zero" >&2
        return 1
    fi
    echo "$(($1 / $2))"
}

# Advanced math functions
math_power() {
    local base=$1
    local exponent=$2
    local result=1
    
    for ((i=1; i<=exponent; i++)); do
        result=$((result * base))
    done
    
    echo "$result"
}

math_factorial() {
    local n=$1
    local result=1
    
    if [ "$n" -lt 0 ]; then
        echo "Error: Factorial of negative number" >&2
        return 1
    fi
    
    for ((i=1; i<=n; i++)); do
        result=$((result * i))
    done
    
    echo "$result"
}

math_is_prime() {
    local n=$1
    
    if [ "$n" -lt 2 ]; then
        return 1
    fi
    
    for ((i=2; i*i<=n; i++)); do
        if [ $((n % i)) -eq 0 ]; then
            return 1
        fi
    done
    
    return 0
}

math_gcd() {
    local a=$1
    local b=$2
    
    while [ "$b" -ne 0 ]; do
        local temp=$b
        b=$((a % b))
        a=$temp
    done
    
    echo "$a"
}





# Configuration management function
configure_app() {
    local config_file="$1"
    local app_name="$2"
    local port="$3"
    
    # Local arrays
    local required_dirs=("/var/log/$app_name" "/var/run/$app_name" "/etc/$app_name")
    local config_params=("port=$port" "log_level=info" "debug=false")
    
    # Create required directories
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "Creating directory: $dir"
            mkdir -p "$dir"
        fi
    done
    
    # Write configuration
    echo "# Configuration for $app_name" > "$config_file"
    echo "# Generated on $(date)" >> "$config_file"
    
    for param in "${config_params[@]}"; do
        echo "$param" >> "$config_file"
    done
    
    echo "Configuration written to $config_file"
}

# configure_app "/tmp/myapp.conf" "myapp" "8080"

# Database connection function with local variables
db_query() {
    local host="$1"
    local database="$2"
    local query="$3"
    local username="${4:-admin}"
    local timeout="${5:-30}"
    
    # Local connection string
    local connection_string="host=$host dbname=$database user=$username"
    
    echo "Connecting to database..."
    echo "Connection: $connection_string"
    echo "Timeout: $timeout seconds"
    echo "Executing: $query"
    
    # Simulate query execution
    local start_time=$(date +%s) # date +%s to time
    sleep 1  # Simulate query time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "Query completed in $duration seconds"
    
    # Local variables are automatically cleaned up when function ends
}

# db_query "localhost" "mydb" "SELECT * FROM users"




# File information functions
file_info() {
    local file="$1"
    
    if [ ! -e "$file" ]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi
    
    echo "File: $file"
    echo "Size: $(du -h "$file" | cut -f1)"
    echo "Type: $(file -b "$file")" # -b where you only need the file type without the filename.
    echo "Permissions: $(ls -l "$file" | cut -d' ' -f1)"
    echo "Owner: $(ls -l "$file" | cut -d' ' -f3)"
    echo "Group: $(ls -l "$file" | cut -d' ' -f4)"
    echo "Modified: $(ls -l "$file" | cut -d' ' -f6-8)"
}

# Backup function
file_backup() {
    local source="$1"
    local backup_dir="${2:-./backups}"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    
    if [ ! -f "$source" ]; then
        echo "Error: Source file '$source' does not exist"
        return 1
    fi
    
    mkdir -p "$backup_dir"
    local backup_file="$backup_dir/$(basename "$source").backup.$timestamp"
    
    if cp "$source" "$backup_file"; then
        echo "Backup created: $backup_file"
        return 0
    else
        echo "Error: Failed to create backup"
        return 1
    fi
}

# Find duplicate files
file_find_duplicates() {
    local directory="${1:-.}"
    
    echo "Searching for duplicate files in: $directory"
    
    find "$directory" -type f -exec md5sum {} + | \
    sort | \
    uniq -w32 -dD | \
    while read hash file; do
        echo "Duplicate: $file"
    done

    # -w32 → Only compares the first 32 characters (the MD5 hash) when checking for duplicates.
    # -d → Prints only duplicate lines.
    # -D → Prints all duplicate lines (not just one per group).
}

# Clean old files
file_cleanup() {
    local directory="$1"
    local days_old="$2"
    
    if [ -z "$directory" ] || [ -z "$days_old" ]; then
        echo "Usage: file_cleanup <directory> <days_old>"
        return 1
    fi
    
    echo "Cleaning files older than $days_old days in $directory"
    
    find "$directory" -type f -mtime +$days_old -print0 | \
    while IFS= read -r -d '' file; do
        echo "Removing: $file"
        rm "$file"
    done
}

# Safe file operations
file_safe_copy() {
    local source="$1"
    local destination="$2"
    
    if [ ! -f "$source" ]; then
        echo "Error: Source file does not exist"
        return 1
    fi
    
    if [ -f "$destination" ]; then
        echo "Warning: Destination file exists"
        read -p "Overwrite? (y/N): " response
        case $response in
            [Yy]*)
                ;;
            *)
                echo "Copy cancelled"
                return 1
                ;;
        esac
    fi
    
    cp "$source" "$destination"
    echo "File copied successfully"
}




# System monitoring
sys_cpu_usage() {
    # Runs top in batch mode
    # (-b) for one iteration
    # (-n1), making it script-friendly.
    # awk '{print $2}': Extracts the user CPU % (second field, e.g., 12.3).
    # sed 's/%us,//': Removes the trailing %us, (if present), leaving just the numeric value.

    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
}

sys_memory_usage() {
    # free: Displays memory usage (RAM + swap).
    # ($3/$2) * 100.0 = (used / total) * 100
    # %.1f : format to 1 decimal place
    free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100.0}'
}

sys_disk_usage() {
    local path="${1:-/}"
    df -h "$path" | tail -1 | awk '{print $5}' | sed 's/%//'
    # tail -1 : Takes the last line (target filesystem).
    # sed 's/%//' removes the % 
}

sys_load_average() {
    uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//'
    # Splits the line at load average:
    # sed 's/^[ \t]*//': Removes leading spaces/tabs.
}

# User management
sys_user_exists() {
    local username="$1"
    id "$username" &>/dev/null
}

sys_group_exists() {
    local groupname="$1"
    getent group "$groupname" &>/dev/null
}

# Network functions
sys_port_check() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" &>/dev/null
}

sys_ping_host() {
    local host="$1"
    local count="${2:-1}"
    
    ping -c "$count" "$host" &>/dev/null
}



# Demonstrate system functions
demo_system() {
    echo "=== System Functions Demo ==="
    echo "CPU Usage: $(sys_cpu_usage)%"
    echo "Memory Usage: $(sys_memory_usage)%"
    echo "Disk Usage: $(sys_disk_usage)%"
    echo "Load Average: $(sys_load_average)"
    echo
    
    # if sys_user_exists "root"; then
    #     echo "User 'root' exists"
    # fi
    
    # if sys_ping_host "8.8.8.8"; then
    #     echo "Can reach 8.8.8.8"
    # else
    #     echo "Cannot reach 8.8.8.8"
    # fi
    # echo
}


# demo_system



# [@] keeps elements separate, useful for loops or when preserving whitespace.
# [*] merges all array elements into one string (joined by IFS, usually a space).

array=("a" "b" "c")
echo "${array[*]}"
IFS=","; echo -e "${array[*]}"
# IFS=","; printf "%s" "${array[*]}"