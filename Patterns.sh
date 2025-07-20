# Advanced Patterns

# Design patterns: Common scripting patterns
# Error recovery: Robust error handling strategies
# Configuration management: Advanced config handling
# Plugin architectures: Extensible script design


#!/bin/bash
# Input validation with case statements

validate_email() {
    local email="$1"
    case $email in
        *@*.*)
            echo "Valid email format"
            return 0
            ;;
        *)
            echo "Invalid email format"
            return 1
            ;;
    esac
}

validate_phone() {
    local phone="$1"
    case $phone in
        [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9])
            echo "Valid US phone format (XXX-XXX-XXXX)"
            return 0
            ;;
        +[0-9]*)
            echo "International phone format"
            return 0
            ;;
        [0-9]*)
            echo "Numeric phone number"
            return 0
            ;;
        *)
            echo "Invalid phone format"
            return 1
            ;;
    esac
}

validate_date() {
    local date="$1"
    case $date in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
            echo "Valid date format (YYYY-MM-DD)"
            return 0
            ;;
        [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9])
            echo "Valid date format (MM/DD/YYYY)"
            return 0
            ;;
        [0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9])
            echo "Valid date format (DD-MM-YYYY)"
            return 0
            ;;
        *)
            echo "Invalid date format"
            return 1
            ;;
    esac
}

# Interactive validation
# while true; do
#     echo "=== Data Validation ==="
#     echo "1. Validate Email"
#     echo "2. Validate Phone"
#     echo "3. Validate Date"
#     echo "4. Exit"
#     read -p "Choose option: " choice
    
#     case $choice in
#         1)
#             read -p "Enter email: " email
#             validate_email "$email"
#             ;;
#         2)
#             read -p "Enter phone: " phone
#             validate_phone "$phone"
#             ;;
#         3)
#             read -p "Enter date: " date
#             validate_date "$date"
#             ;;
#         4)
#             echo "Goodbye!"
#             break
#             ;;
#         *)
#             echo "Invalid choice"
#             ;;
#     esac
#     echo
# done





# Log processing based on log levels

process_log_entry() {
    local log_entry="$1"
    local level="${log_entry%% *}"  # Extract first word (log level)
    # echo $level
    case $level in
        "ERROR"|"FATAL"|"CRITICAL")
            echo "CRITICAL: $log_entry"
            # Send alert
            echo "$log_entry" >> critical_errors.log
            ;;
        "WARN"|"WARNING")
            echo "WARNING: $log_entry"
            echo "$log_entry" >> warnings.log
            ;;
        "INFO"|"INFORMATION")
            echo "INFO: $log_entry"
            ;;
        "DEBUG"|"TRACE")
            echo "DEBUG: $log_entry"
            ;;
        [0-9]*-[0-9]*-[0-9]*)  # Date format at start
            # Extract log level from structured log
            case $log_entry in
                *ERROR*|*FATAL*)
                    echo "CRITICAL: $log_entry"
                    ;;
                *WARN*)
                    echo "WARNING: $log_entry"
                    ;;
                *INFO*)
                    echo "INFO: $log_entry"
                    ;;
                *DEBUG*)
                    echo "DEBUG: $log_entry"
                    ;;
                *)
                    echo "LOG: $log_entry"
                    ;;
            esac
            ;;
        *)
            echo "UNKNOWN: $log_entry"
            ;;
    esac
}

# Process log file
if [ -f "$1" ]; then
    while IFS= read -r line; do
        [ -n "$line" ] && process_log_entry "$line"
    done < "$1"
else
    # Process sample log entries
    sample_logs=(
        "ERROR Failed to connect to database"
        "WARN Memory usage above 80%"
        "INFO User logged in successfully"
        "DEBUG Processing request 12345"
        "2024-01-15 10:30:00 ERROR Connection timeout"
        "2024-01-15 10:31:00 INFO Request processed"
    )
    
    for log in "${sample_logs[@]}"; do
        process_log_entry "$log"
    done
fi




# File system operations with pattern matching

operation="$1"
target="$2"

case $operation in
    "backup")
        case $target in
            *.txt|*.log|*.conf)
                echo "Backing up configuration/text file: $target"
                cp "$target" "$target.bak.$(date +%Y%m%d)"
                ;;
            *.sql)
                echo "Backing up SQL file: $target"
                gzip -c "$target" > "$target.bak.$(date +%Y%m%d).gz"
                ;;
            /home/*)
                echo "Backing up home directory: $target"
                tar -czf "${target##*/}_backup_$(date +%Y%m%d).tar.gz" "$target"
                ;;
            /etc/*)
                echo "Backing up system configuration: $target"
                sudo cp -r "$target" "/backup/etc_$(date +%Y%m%d)/"
                ;;
            *)
                echo "Generic backup for: $target"
                cp -r "$target" "$target.backup.$(date +%Y%m%d)"
                ;;
        esac
        ;;
    "clean")
        case $target in
            *.tmp|*.temp)
                echo "Removing temporary file: $target"
                rm -f "$target"
                ;;
            /tmp/*)
                echo "Cleaning temporary directory: $target"
                find "$target" -type f -mtime +7 -delete
                ;;
            *.log)
                echo "Truncating log file: $target"
                > "$target"
                ;;
            ~/Downloads/*)
                echo "Cleaning downloads: $target"
                find "$target" -type f -mtime +30 -delete
                ;;
            *)
                echo "Standard clean for: $target"
                ;;
        esac
        ;;
    "compress")
        case $target in
            *.txt|*.log|*.csv)
                echo "Compressing text file: $target"
                gzip "$target"
                ;;
            *.jpg|*.png)
                echo "Image compression not implemented for: $target"
                ;;
            /home/*|/var/*)
                echo "Creating archive: $target"
                tar -czf "${target##*/}.tar.gz" "$target"
                ;;
            *)
                echo "Generic compression for: $target"
                zip -r "$target.zip" "$target"
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 <operation> <target>"
        echo "Operations: backup, clean, compress"
        echo "Examples:"
        echo "  $0 backup /etc/nginx/nginx.conf"
        echo "  $0 clean /tmp/*"
        echo "  $0 compress /home/user/documents"
        exit 1
        ;;
esac


# Bash Case Statements Guide

## Basic case-esac Structure

```bash
# Basic syntax
case variable in
    pattern1)
        # commands
        ;;
    pattern2)
        # commands
        ;;
    *)
        # default case
        ;;
esac

# Simple example
day="Monday"
case $day in
    "Monday")
        echo "Start of the work week"
        ;;
    "Friday")
        echo "TGIF!"
        ;;
    "Saturday"|"Sunday")
        echo "Weekend!"
        ;;
    *)
        echo "Regular weekday"
        ;;
esac
```

## Menu Systems with Case

```bash
#!/bin/bash
# Interactive menu

while true; do
    echo "=== System Menu ==="
    echo "1. Show system info"
    echo "2. List processes"
    echo "3. Show disk usage"
    echo "4. Show network info"
    echo "5. Exit"
    echo
    read -p "Select option (1-5): " choice
    
    case $choice in
        1)
            echo "=== System Information ==="
            uname -a
            uptime
            ;;
        2)
            echo "=== Running Processes ==="
            ps aux | head -20
            ;;
        3)
            echo "=== Disk Usage ==="
            df -h
            ;;
        4)
            echo "=== Network Information ==="
            ip addr show | grep -E "inet|link"
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1-5."
            ;;
    esac
    echo
    read -p "Press Enter to continue..."
    echo
done
```

## File Extension Processing

```bash
#!/bin/bash
# Process files based on extension

for file in *; do
    if [ -f "$file" ]; then
        extension="${file##*.}"
        filename="${file%.*}"
        
        case $extension in
            "txt"|"log")
                echo "Text file: $file"
                wc -l "$file"
                ;;
            "jpg"|"jpeg"|"png"|"gif")
                echo "Image file: $file"
                ls -lh "$file"
                ;;
            "sh")
                echo "Shell script: $file"
                if [ -x "$file" ]; then
                    echo "  Executable: Yes"
                else
                    echo "  Executable: No"
                fi
                ;;
            "pdf"|"doc"|"docx")
                echo "Document: $file"
                ;;
            "zip"|"tar"|"gz"|"rar")
                echo "Archive: $file"
                ;;
            *)
                echo "Unknown file type: $file"
                ;;
        esac
    fi
done
```

## Command Line Argument Processing

```bash
#!/bin/bash
# Command processing script

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command> [arguments]"
    echo "Commands: install, remove, update, status, help"
    exit 1
fi

command=$1
shift  # Remove first argument

case $command in
    "install"|"i")
        echo "Installing package(s): $*"
        for package in "$@"; do
            echo "  Installing $package..."
            # apt install $package -y
        done
        ;;
    "remove"|"uninstall"|"r")
        echo "Removing package(s): $*"
        for package in "$@"; do
            echo "  Removing $package..."
            # apt remove $package -y
        done
        ;;
    "update"|"u")
        echo "Updating package list..."
        # apt update
        if [ $# -gt 0 ]; then
            echo "Upgrading packages: $*"
        else
            echo "Upgrading all packages..."
        fi
        ;;
    "status"|"s")
        if [ $# -gt 0 ]; then
            for package in "$@"; do
                echo "Status of $package:"
                # dpkg -l | grep $package
            done
        else
            echo "System status:"
            # apt list --upgradable
        fi
        ;;
    "help"|"h"|"--help")
        echo "Package Manager Help"
        echo "Commands:"
        echo "  install|i <packages>  - Install packages"
        echo "  remove|r <packages>   - Remove packages"
        echo "  update|u [packages]   - Update system or specific packages"
        echo "  status|s [packages]   - Show status"
        echo "  help|h               - Show this help"
        ;;
    *)
        echo "Error: Unknown command '$command'"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac
```

## Pattern Matching with Wildcards

```bash
#!/bin/bash
# Advanced pattern matching

read -p "Enter a filename or URL: " input

case $input in
    *.txt|*.log|*.md)
        echo "Text-based file"
        if [ -f "$input" ]; then
            echo "File exists. Line count: $(wc -l < "$input")"
        fi
        ;;
    *.jpg|*.jpeg|*.png|*.gif|*.bmp)
        echo "Image file"
        if [ -f "$input" ]; then
            echo "File size: $(du -h "$input" | cut -f1)"
        fi
        ;;
    http://*|https://*)
        echo "Web URL detected"
        case $input in
            *github.com*)
                echo "GitHub repository"
                ;;
            *stackoverflow.com*)
                echo "Stack Overflow question"
                ;;
            *youtube.com*|*youtu.be*)
                echo "YouTube video"
                ;;
            *.pdf)
                echo "PDF document online"
                ;;
            *)
                echo "Generic web URL"
                ;;
        esac
        ;;
    [0-9]*)
        echo "Starts with a number"
        case $input in
            [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9])
                echo "Looks like a phone number (XXX-XXX-XXXX)"
                ;;
            [0-9][0-9][0-9][0-9])
                echo "Looks like a year"
                ;;
            *)
                echo "Number-like input"
                ;;
        esac
        ;;
    [A-Z]*)
        echo "Starts with uppercase letter"
        ;;
    [a-z]*)
        echo "Starts with lowercase letter"
        ;;
    /*)
        echo "Absolute path"
        if [ -d "$input" ]; then
            echo "Directory exists"
        elif [ -f "$input" ]; then
            echo "File exists"
        else
            echo "Path does not exist"
        fi
        ;;
    ./*)
        echo "Relative path from current directory"
        ;;
    "")
        echo "Empty input"
        ;;
    *)
        echo "Unknown pattern"
        ;;
esac
```

## Service Management Script

```bash
#!/bin/bash
# Service management with case statements

service_name="$1"
action="$2"

if [ $# -ne 2 ]; then
    echo "Usage: $0 <service_name> <action>"
    echo "Actions: start, stop, restart, status, enable, disable"
    exit 1
fi

case $action in
    "start")
        echo "Starting service: $service_name"
        if systemctl is-active --quiet "$service_name"; then
            echo "Service is already running"
        else
            sudo systemctl start "$service_name"
            if [ $? -eq 0 ]; then
                echo "Service started successfully"
            else
                echo "Failed to start service"
            fi
        fi
        ;;
    "stop")
        echo "Stopping service: $service_name"
        sudo systemctl stop "$service_name"
        if [ $? -eq 0 ]; then
            echo "Service stopped successfully"
        else
            echo "Failed to stop service"
        fi
        ;;
    "restart")
        echo "Restarting service: $service_name"
        sudo systemctl restart "$service_name"
        if [ $? -eq 0 ]; then
            echo "Service restarted successfully"
        else
            echo "Failed to restart service"
        fi
        ;;
    "status")
        echo "Service status for: $service_name"
        systemctl status "$service_name" --no-pager
        ;;
    "enable")
        echo "Enabling service: $service_name"
        sudo systemctl enable "$service_name"
        if [ $? -eq 0 ]; then
            echo "Service enabled for startup"
        else
            echo "Failed to enable service"
        fi
        ;;
    "disable")
        echo "Disabling service: $service_name"
        sudo systemctl disable "$service_name"
        if [ $? -eq 0 ]; then
            echo "Service disabled from startup"
        else
            echo "Failed to disable service"
        fi
        ;;
    *)
        echo "Invalid action: $action"
        echo "Valid actions: start, stop, restart, status, enable, disable"
        exit 1
        ;;
esac
```

## User Input Validation

```bash
#!/bin/bash
# Input validation with case statements

validate_email() {
    local email="$1"
    case $email in
        *@*.*)
            echo "Valid email format"
            return 0
            ;;
        *)
            echo "Invalid email format"
            return 1
            ;;
    esac
}

validate_phone() {
    local phone="$1"
    case $phone in
        [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9])
            echo "Valid US phone format (XXX-XXX-XXXX)"
            return 0
            ;;
        +[0-9]*)
            echo "International phone format"
            return 0
            ;;
        [0-9]*)
            echo "Numeric phone number"
            return 0
            ;;
        *)
            echo "Invalid phone format"
            return 1
            ;;
    esac
}

validate_date() {
    local date="$1"
    case $date in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
            echo "Valid date format (YYYY-MM-DD)"
            return 0
            ;;
        [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9])
            echo "Valid date format (MM/DD/YYYY)"
            return 0
            ;;
        [0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9])
            echo "Valid date format (DD-MM-YYYY)"
            return 0
            ;;
        *)
            echo "Invalid date format"
            return 1
            ;;
    esac
}

# Interactive validation
while true; do
    echo "=== Data Validation ==="
    echo "1. Validate Email"
    echo "2. Validate Phone"
    echo "3. Validate Date"
    echo "4. Exit"
    read -p "Choose option: " choice
    
    case $choice in
        1)
            read -p "Enter email: " email
            validate_email "$email"
            ;;
        2)
            read -p "Enter phone: " phone
            validate_phone "$phone"
            ;;
        3)
            read -p "Enter date: " date
            validate_date "$date"
            ;;
        4)
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
    echo
done
```

## Log Level Processing

```bash
#!/bin/bash
# Log processing based on log levels

process_log_entry() {
    local log_entry="$1"
    local level="${log_entry%% *}"  # Extract first word (log level)
    
    case $level in
        "ERROR"|"FATAL"|"CRITICAL")
            echo "🔴 CRITICAL: $log_entry"
            # Send alert
            echo "$log_entry" >> critical_errors.log
            ;;
        "WARN"|"WARNING")
            echo "🟡 WARNING: $log_entry"
            echo "$log_entry" >> warnings.log
            ;;
        "INFO"|"INFORMATION")
            echo "🔵 INFO: $log_entry"
            ;;
        "DEBUG"|"TRACE")
            echo "🔍 DEBUG: $log_entry"
            ;;
        [0-9]*-[0-9]*-[0-9]*)  # Date format at start
            # Extract log level from structured log
            case $log_entry in
                *ERROR*|*FATAL*)
                    echo "🔴 CRITICAL: $log_entry"
                    ;;
                *WARN*)
                    echo "🟡 WARNING: $log_entry"
                    ;;
                *INFO*)
                    echo "🔵 INFO: $log_entry"
                    ;;
                *DEBUG*)
                    echo "🔍 DEBUG: $log_entry"
                    ;;
                *)
                    echo "📝 LOG: $log_entry"
                    ;;
            esac
            ;;
        *)
            echo "📝 UNKNOWN: $log_entry"
            ;;
    esac
}

# Process log file
if [ -f "$1" ]; then
    while IFS= read -r line; do
        [ -n "$line" ] && process_log_entry "$line"
    done < "$1"
else
    # Process sample log entries
    sample_logs=(
        "ERROR Failed to connect to database"
        "WARN Memory usage above 80%"
        "INFO User logged in successfully"
        "DEBUG Processing request 12345"
        "2024-01-15 10:30:00 ERROR Connection timeout"
        "2024-01-15 10:31:00 INFO Request processed"
    )
    
    for log in "${sample_logs[@]}"; do
        process_log_entry "$log"
    done
fi
```

## File System Operations

```bash
#!/bin/bash
# File system operations with pattern matching

operation="$1"
target="$2"

case $operation in
    "backup")
        case $target in
            *.txt|*.log|*.conf)
                echo "Backing up configuration/text file: $target"
                cp "$target" "$target.bak.$(date +%Y%m%d)"
                ;;
            *.sql)
                echo "Backing up SQL file: $target"
                gzip -c "$target" > "$target.bak.$(date +%Y%m%d).gz"
                ;;
            /home/*)
                echo "Backing up home directory: $target"
                tar -czf "${target##*/}_backup_$(date +%Y%m%d).tar.gz" "$target"
                ;;
            /etc/*)
                echo "Backing up system configuration: $target"
                sudo cp -r "$target" "/backup/etc_$(date +%Y%m%d)/"
                ;;
            *)
                echo "Generic backup for: $target"
                cp -r "$target" "$target.backup.$(date +%Y%m%d)"
                ;;
        esac
        ;;
    "clean")
        case $target in
            *.tmp|*.temp)
                echo "Removing temporary file: $target"
                rm -f "$target"
                ;;
            /tmp/*)
                echo "Cleaning temporary directory: $target"
                find "$target" -type f -mtime +7 -delete
                ;;
            *.log)
                echo "Truncating log file: $target"
                > "$target"
                ;;
            ~/Downloads/*)
                echo "Cleaning downloads: $target"
                find "$target" -type f -mtime +30 -delete
                ;;
            *)
                echo "Standard clean for: $target"
                ;;
        esac
        ;;
    "compress")
        case $target in
            *.txt|*.log|*.csv)
                echo "Compressing text file: $target"
                gzip "$target"
                ;;
            *.jpg|*.png)
                echo "Image compression not implemented for: $target"
                ;;
            /home/*|/var/*)
                echo "Creating archive: $target"
                tar -czf "${target##*/}.tar.gz" "$target"
                ;;
            *)
                echo "Generic compression for: $target"
                zip -r "$target.zip" "$target"
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 <operation> <target>"
        echo "Operations: backup, clean, compress"
        echo "Examples:"
        echo "  $0 backup /etc/nginx/nginx.conf"
        echo "  $0 clean /tmp/*"
        echo "  $0 compress /home/user/documents"
        exit 1
        ;;
esac
```


# Complex pattern matching scenarios

process_input() {
    local input="$1"
    
    case $input in
        # IP Address patterns
        [0-9]*.[0-9]*.[0-9]*.[0-9]*)
            echo "IP Address detected: $input"
            case $input in
                192.168.*)
                    echo "  Private IP (Class C)"
                    ;;
                10.*)
                    echo "  Private IP (Class A)"
                    ;;
                172.1[6-9].*|172.2[0-9].*|172.3[0-1].*)
                    echo "  Private IP (Class B)"
                    ;;
                127.*)
                    echo "  Loopback IP"
                    ;;
                *)
                    echo "  Public IP"
                    ;;
            esac
            ;;
        # MAC Address patterns
        [0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F])
            echo "MAC Address: $input"
            ;;
        # Version numbers
        [0-9]*.[0-9]*.[0-9]*)
            echo "Version number: $input"
            case $input in
                0.*)
                    echo "  Development version"
                    ;;
                1.0.0)
                    echo "  Initial release"
                    ;;
                [2-9].*)
                    echo "  Stable version"
                    ;;
            esac
            ;;
        # Credit card patterns (simplified)
        4[0-9][0-9][0-9]*)
            echo "Visa card pattern detected"
            ;;
        5[1-5][0-9][0-9]*)
            echo "Mastercard pattern detected"
            ;;
        # Hash patterns
        [a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]*)
            case ${#input} in
                32)
                    echo "MD5 hash: $input"
                    ;;
                40)
                    echo "SHA-1 hash: $input"
                    ;;
                64)
                    echo "SHA-256 hash: $input"
                    ;;
                *)
                    echo "Unknown hash format"
                    ;;
            esac
            ;;
        # Multiple patterns with OR
        *.tar.gz|*.tgz|*.tar.bz2|*.tar.xz)
            echo "Compressed archive: $input"
            ;;
        # Range patterns
        [A-M]*)
            echo "Starts with letters A-M: $input"
            ;;
        [N-Z]*)
            echo "Starts with letters N-Z: $input"
            ;;
        *)
            echo "No pattern matched for: $input"
            ;;
    esac
}

# Test various inputs
test_inputs=(
    "192.168.1.1"
    "10.0.0.1"
    "AA:BB:CC:DD:EE:FF"
    "1.2.3"
    "5d41402abc4b2a76b9719d911017c592"
    "archive.tar.gz"
    "Alice"
    "Zulu"
    "4111111111111111"
)

for input in "${test_inputs[@]}"; do
    echo "Testing: $input"
    process_input "$input"
    echo
done