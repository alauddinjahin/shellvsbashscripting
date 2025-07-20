#!/bin/bash

# Configuration Management

# Config files: Reading and parsing configuration
# Environment setup: .bashrc, .profile customization
# Path manipulation: Adding directories to PATH
# Alias management: Creating and managing command aliases


# Configuration file parser
parse_config() {
    local config_file="$1"
    local prefix="${2:-CFG_}"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file '$config_file' not found"
        return 1
    fi
    
    echo "Parsing configuration file: $config_file"
    
    # Parse key=value pairs, ignoring comments and empty lines
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        
        # Clean up key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Remove quotes from value if present
        value=$(echo "$value" | sed 's/^["'\'']\(.*\)["'\'']$/\1/')
        
        # Set environment variable with prefix
        declare -g "${prefix}${key^^}"="$value"
        echo "Set ${prefix}${key^^}=$value"
    done < <(grep -E '^[^#]*=' "$config_file")
}

# INI file parser
parse_ini_config() {
    local config_file="$1"
    local section_prefix="${2:-INI_}"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: INI file '$config_file' not found"
        return 1
    fi
    
    local current_section="DEFAULT"
    
    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | xargs)
        
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[#;] ]] && continue
        
        # Section header
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi
        
        # Key=value pair
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Clean up
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs | sed 's/^["'\'']\(.*\)["'\'']$/\1/')
            
            # Set variable with section prefix
            local var_name="${section_prefix}${current_section^^}_${key^^}"
            declare -g "$var_name"="$value"
            echo "Set $var_name=$value"
        fi
    done < "$config_file"
}

# JSON configuration parser (requires jq)
parse_json_config() {
    local json_file="$1"
    local prefix="${2:-JSON_}"
    
    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file '$json_file' not found"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required for JSON parsing"
        return 1
    fi
    
    # Parse JSON and create environment variables
    while IFS='=' read -r key value; do
        [[ -n "$key" && -n "$value" ]] || continue
        local var_name="${prefix}${key^^}"
        declare -g "$var_name"="$value"
        echo "Set $var_name=$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file")
}

# Configuration validation
validate_config() {
    local required_vars=("$@")
    local missing_vars=()
    
    echo "Validating configuration..."
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        else
            echo "✓ $var is set"
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "Missing required configuration variables:"
        printf '%s\n' "${missing_vars[@]}"
        return 1
    else
        echo "All required configuration variables are set"
        return 0
    fi
}




# Bash System Integration - Level 6

## 16. System Information

### System Commands

#### Basic System Information

```bash
#!/bin/bash

# Get comprehensive system information
get_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Current User: $(whoami)"
    echo "User ID: $(id -u)"
    echo "Group ID: $(id -g)"
    echo "Current Date: $(date)"
    echo "System Uptime: $(uptime)"
    echo
    
    # Detailed system information
    echo "=== Detailed System Info ==="
    echo "Kernel: $(uname -r)"
    echo "Operating System: $(uname -o)"
    echo "Architecture: $(uname -m)"
    echo "Processor: $(uname -p)"
    echo "Hardware Platform: $(uname -i)"
    echo
    
    # Distribution information (Linux)
    if [[ -f /etc/os-release ]]; then
        echo "=== Distribution Information ==="
        source /etc/os-release
        echo "Distribution: $NAME"
        echo "Version: $VERSION"
        echo "ID: $ID"
    fi
}

# System resource summary
system_resources() {
    echo "=== System Resources ==="
    
    # CPU information
    if [[ -f /proc/cpuinfo ]]; then
        cpu_count=$(nproc)
        cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        echo "CPU Cores: $cpu_count"
        echo "CPU Model: $cpu_model"
    fi
    
    # Memory information
    if [[ -f /proc/meminfo ]]; then
        total_mem=$(awk '/MemTotal/ {print int($2/1024) "MB"}' /proc/meminfo)
        free_mem=$(awk '/MemAvailable/ {print int($2/1024) "MB"}' /proc/meminfo)
        echo "Total Memory: $total_mem"
        echo "Available Memory: $free_mem"
    fi
    
    # Disk space
    echo "Disk Usage:"
    df -h | head -5
}
```

#### Advanced System Information Functions

```bash
#!/bin/bash

# Get load average and interpret it
check_load_average() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cpu_cores=$(nproc)
    local load_per_core=$(echo "scale=2; $load_avg / $cpu_cores" | bc -l)
    
    echo "Load Average: $load_avg"
    echo "CPU Cores: $cpu_cores"
    echo "Load per Core: $load_per_core"
    
    if (( $(echo "$load_per_core > 0.8" | bc -l) )); then
        echo "WARNING: High system load detected!"
        return 1
    else
        echo "System load is normal"
        return 0
    fi
}

# Check system temperatures (Linux)
check_temperatures() {
    echo "=== System Temperatures ==="
    
    # Check if sensors command is available
    if command -v sensors >/dev/null 2>&1; then
        sensors | grep -E "(Core|temp)" | head -5
    elif [[ -d /sys/class/thermal ]]; then
        for thermal in /sys/class/thermal/thermal_zone*/temp; do
            if [[ -r "$thermal" ]]; then
                temp=$(cat "$thermal")
                temp_celsius=$((temp / 1000))
                zone=$(basename "$(dirname "$thermal")")
                echo "$zone: ${temp_celsius}°C"
            fi
        done
    else
        echo "Temperature sensors not available"
    fi
}

# Network interface information
get_network_info() {
    echo "=== Network Information ==="
    
    # Get active network interfaces
    if command -v ip >/dev/null 2>&1; then
        echo "Active Network Interfaces:"
        ip -o link show | awk '{print $2, $9}' | grep UP
        echo
        echo "IP Addresses:"
        ip -o -4 addr show | awk '{print $2, $4}'
    else
        echo "Network Interfaces:"
        ifconfig | grep -E "(^\w|inet )" | head -10
    fi
    
    # Default route
    echo
    echo "Default Route:"
    if command -v ip >/dev/null 2>&1; then
        ip route show default
    else
        route -n | grep '^0.0.0.0'
    fi
}
```

### Process Information

#### Process Monitoring and Management

```bash
#!/bin/bash

# Advanced process information
get_process_info() {
    local process_name="$1"
    
    if [[ -z "$process_name" ]]; then
        echo "Usage: get_process_info <process_name>"
        return 1
    fi
    
    echo "=== Process Information for: $process_name ==="
    
    # Find processes
    local pids=($(pgrep -f "$process_name"))
    
    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "No processes found matching: $process_name"
        return 1
    fi
    
    echo "Found ${#pids[@]} process(es):"
    
    for pid in "${pids[@]}"; do
        echo "--- PID: $pid ---"
        
        # Basic process info
        ps -p "$pid" -o pid,ppid,user,command --no-headers
        
        # Memory usage
        if [[ -f "/proc/$pid/status" ]]; then
            echo "Memory Usage:"
            grep -E "(VmSize|VmRSS|VmPeak)" "/proc/$pid/status" 2>/dev/null
        fi
        
        # CPU usage (requires some time to calculate)
        echo "CPU Usage:"
        ps -p "$pid" -o %cpu --no-headers
        
        echo
    done
}

# Process monitoring function
monitor_processes() {
    local interval="${1:-5}"
    local count="${2:-10}"
    
    echo "Monitoring top processes every $interval seconds ($count iterations)..."
    
    for ((i=1; i<=count; i++)); do
        echo "=== Iteration $i/$(count) - $(date) ==="
        
        # Top CPU consuming processes
        echo "Top 5 CPU consumers:"
        ps aux --sort=-%cpu | head -6
        echo
        
        # Top memory consuming processes
        echo "Top 5 Memory consumers:"
        ps aux --sort=-%mem | head -6
        echo
        
        # System load
        echo "System Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo "----------------------------------------"
        
        if [[ $i -lt $count ]]; then
            sleep "$interval"
        fi
    done
}

# Kill processes safely
kill_process_safely() {
    local process_pattern="$1"
    local signal="${2:-TERM}"
    
    if [[ -z "$process_pattern" ]]; then
        echo "Usage: kill_process_safely <pattern> [signal]"
        return 1
    fi
    
    # Find processes
    local pids=($(pgrep -f "$process_pattern"))
    
    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "No processes found matching: $process_pattern"
        return 1
    fi
    
    echo "Found processes matching '$process_pattern':"
    ps -p "${pids[*]}" -o pid,user,command --no-headers
    
    read -p "Kill these processes with signal $signal? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for pid in "${pids[@]}"; do
            echo "Sending $signal to PID $pid"
            kill -"$signal" "$pid"
        done
        
        # Wait and check if processes are gone
        sleep 2
        local remaining=($(pgrep -f "$process_pattern"))
        if [[ ${#remaining[@]} -gt 0 ]]; then
            echo "Warning: ${#remaining[@]} processes still running"
            ps -p "${remaining[*]}" -o pid,user,command --no-headers
        else
            echo "All processes terminated successfully"
        fi
    else
        echo "Operation cancelled"
    fi
}
```

### Network Commands

#### Network Utilities and Monitoring

```bash
#!/bin/bash

# Advanced ping with statistics
advanced_ping() {
    local target="$1"
    local count="${2:-10}"
    local timeout="${3:-5}"
    
    if [[ -z "$target" ]]; then
        echo "Usage: advanced_ping <target> [count] [timeout]"
        return 1
    fi
    
    echo "Pinging $target with $count packets (timeout: ${timeout}s)..."
    
    # Perform ping and capture statistics
    local ping_result
    ping_result=$(ping -c "$count" -W "$timeout" "$target" 2>&1)
    local exit_code=$?
    
    echo "$ping_result"
    
    if [[ $exit_code -eq 0 ]]; then
        # Extract statistics
        local avg_time=$(echo "$ping_result" | grep "avg" | awk -F'/' '{print $(NF-1)}')
        echo "Average response time: ${avg_time}ms"
        
        # Check if response time is acceptable (< 100ms for LAN, < 500ms for WAN)
        if (( $(echo "$avg_time < 100" | bc -l) )); then
            echo "Status: Excellent connectivity"
        elif (( $(echo "$avg_time < 500" | bc -l) )); then
            echo "Status: Good connectivity"
        else
            echo "Status: Poor connectivity"
        fi
    else
        echo "Ping failed to $target"
        return 1
    fi
}

# Multi-target connectivity check
check_connectivity() {
    local targets=("8.8.8.8" "1.1.1.1" "google.com" "github.com")
    local failed_count=0
    
    echo "=== Connectivity Check ==="
    
    for target in "${targets[@]}"; do
        echo -n "Testing $target... "
        if ping -c 3 -W 5 "$target" >/dev/null 2>&1; then
            echo "✓ OK"
        else
            echo "✗ FAILED"
            ((failed_count++))
        fi
    done
    
    echo
    if [[ $failed_count -eq 0 ]]; then
        echo "All connectivity tests passed"
        return 0
    else
        echo "Failed connectivity tests: $failed_count/${#targets[@]}"
        return 1
    fi
}

# Download with progress and retry
download_with_retry() {
    local url="$1"
    local output_file="$2"
    local max_retries="${3:-3}"
    local timeout="${4:-30}"
    
    if [[ -z "$url" || -z "$output_file" ]]; then
        echo "Usage: download_with_retry <url> <output_file> [max_retries] [timeout]"
        return 1
    fi
    
    local retry_count=0
    
    while [[ $retry_count -lt $max_retries ]]; do
        echo "Download attempt $((retry_count + 1))/$max_retries..."
        
        # Try wget first, then curl
        if command -v wget >/dev/null 2>&1; then
            if wget --timeout="$timeout" --progress=bar:force "$url" -O "$output_file"; then
                echo "Download successful"
                return 0
            fi
        elif command -v curl >/dev/null 2>&1; then
            if curl --connect-timeout "$timeout" --progress-bar "$url" -o "$output_file"; then
                echo "Download successful"
                return 0
            fi
        else
            echo "Error: Neither wget nor curl available"
            return 1
        fi
        
        ((retry_count++))
        if [[ $retry_count -lt $max_retries ]]; then
            echo "Download failed. Retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    echo "Download failed after $max_retries attempts"
    return 1
}

# API testing function
test_api() {
    local url="$1"
    local method="${2:-GET}"
    local expected_code="${3:-200}"
    
    if [[ -z "$url" ]]; then
        echo "Usage: test_api <url> [method] [expected_status_code]"
        return 1
    fi
    
    echo "Testing API: $method $url"
    
    if command -v curl >/dev/null 2>&1; then
        local response
        response=$(curl -s -w "%{http_code}|%{time_total}" -X "$method" "$url")
        local status_code="${response##*|}"
        local response_time="${response%|*}"
        response_time="${response_time##*|}"
        local body="${response%|*|*}"
        
        echo "Status Code: ${status_code%|*}"
        echo "Response Time: ${response_time}s"
        
        if [[ "${status_code%|*}" == "$expected_code" ]]; then
            echo "✓ API test passed"
            return 0
        else
            echo "✗ API test failed (expected: $expected_code)"
            return 1
        fi
    else
        echo "Error: curl not available"
        return 1
    fi
}
```

### System Monitoring

#### Comprehensive System Monitoring

```bash
#!/bin/bash

# Memory monitoring
monitor_memory() {
    echo "=== Memory Usage ==="
    
    if [[ -f /proc/meminfo ]]; then
        local total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
        local available_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
        local used_kb=$((total_kb - available_kb))
        local used_percent=$(( (used_kb * 100) / total_kb ))
        
        echo "Total Memory: $((total_kb / 1024)) MB"
        echo "Used Memory: $((used_kb / 1024)) MB"
        echo "Available Memory: $((available_kb / 1024)) MB"
        echo "Usage Percentage: ${used_percent}%"
        
        # Memory usage warning
        if [[ $used_percent -gt 90 ]]; then
            echo "🔴 CRITICAL: Memory usage is very high!"
            return 2
        elif [[ $used_percent -gt 80 ]]; then
            echo "🟡 WARNING: Memory usage is high"
            return 1
        else
            echo "🟢 Memory usage is normal"
            return 0
        fi
    else
        echo "Unable to read memory information"
        return 1
    fi
}

# Disk space monitoring
monitor_disk_space() {
    local threshold="${1:-85}"
    echo "=== Disk Space Usage (Alert threshold: ${threshold}%) ==="
    
    local alert_count=0
    
    # Check all mounted filesystems
    while IFS= read -r line; do
        if [[ $line =~ ^/dev/ ]] || [[ $line =~ ^/ ]]; then
            local filesystem=$(echo "$line" | awk '{print $1}')
            local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
            local mountpoint=$(echo "$line" | awk '{print $6}')
            
            printf "%-20s %s%% %s" "$filesystem" "$usage" "$mountpoint"
            
            if [[ $usage -gt $threshold ]]; then
                echo " 🔴 ALERT!"
                ((alert_count++))
            elif [[ $usage -gt $((threshold - 10)) ]]; then
                echo " 🟡 WARNING"
            else
                echo " 🟢 OK"
            fi
        fi
    done < <(df -h)
    
    echo
    if [[ $alert_count -gt 0 ]]; then
        echo "⚠️  $alert_count filesystem(s) exceed threshold"
        return 1
    else
        echo "✅ All filesystems within acceptable limits"
        return 0
    fi
}

# System health check
system_health_check() {
    local log_file="${1:-/tmp/system_health_$(date +%Y%m%d_%H%M%S).log}"
    
    echo "=== System Health Check - $(date) ===" | tee "$log_file"
    echo "Generated by: $(whoami)@$(hostname)" | tee -a "$log_file"
    echo | tee -a "$log_file"
    
    local overall_status=0
    
    # Check system load
    echo "1. System Load Check:" | tee -a "$log_file"
    if check_load_average 2>&1 | tee -a "$log_file"; then
        echo "✅ Load check passed" | tee -a "$log_file"
    else
        echo "❌ Load check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Check memory
    echo "2. Memory Check:" | tee -a "$log_file"
    local mem_status
    monitor_memory 2>&1 | tee -a "$log_file"
    mem_status=${PIPESTATUS[0]}
    if [[ $mem_status -eq 0 ]]; then
        echo "✅ Memory check passed" | tee -a "$log_file"
    else
        echo "❌ Memory check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Check disk space
    echo "3. Disk Space Check:" | tee -a "$log_file"
    if monitor_disk_space 2>&1 | tee -a "$log_file"; then
        echo "✅ Disk space check passed" | tee -a "$log_file"
    else
        echo "❌ Disk space check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Check connectivity
    echo "4. Network Connectivity Check:" | tee -a "$log_file"
    if check_connectivity 2>&1 | tee -a "$log_file"; then
        echo "✅ Connectivity check passed" | tee -a "$log_file"
    else
        echo "❌ Connectivity check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Overall status
    echo "=== Overall Health Status ===" | tee -a "$log_file"
    if [[ $overall_status -eq 0 ]]; then
        echo "🎉 System is healthy!" | tee -a "$log_file"
    else
        echo "⚠️  System issues detected. Review the details above." | tee -a "$log_file"
    fi
    
    echo "Health check completed. Log saved to: $log_file"
    return $overall_status
}
```

## 17. Configuration Management

### Configuration File Handling

#### Reading and Parsing Configuration Files

```bash
#!/bin/bash

# Configuration file parser
parse_config() {
    local config_file="$1"
    local prefix="${2:-CFG_}"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file '$config_file' not found"
        return 1
    fi
    
    echo "Parsing configuration file: $config_file"
    
    # Parse key=value pairs, ignoring comments and empty lines
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        
        # Clean up key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Remove quotes from value if present
        value=$(echo "$value" | sed 's/^["'\'']\(.*\)["'\'']$/\1/')
        
        # Set environment variable with prefix
        declare -g "${prefix}${key^^}"="$value"
        echo "Set ${prefix}${key^^}=$value"
    done < <(grep -E '^[^#]*=' "$config_file")
}

# INI file parser
parse_ini_config() {
    local config_file="$1"
    local section_prefix="${2:-INI_}"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: INI file '$config_file' not found"
        return 1
    fi
    
    local current_section="DEFAULT"
    
    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | xargs)
        
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[#;] ]] && continue
        
        # Section header
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi
        
        # Key=value pair
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Clean up
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs | sed 's/^["'\'']\(.*\)["'\'']$/\1/')
            
            # Set variable with section prefix
            local var_name="${section_prefix}${current_section^^}_${key^^}"
            declare -g "$var_name"="$value"
            echo "Set $var_name=$value"
        fi
    done < "$config_file"
}

# JSON configuration parser (requires jq)
parse_json_config() {
    local json_file="$1"
    local prefix="${2:-JSON_}"
    
    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file '$json_file' not found"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required for JSON parsing"
        return 1
    fi
    
    # Parse JSON and create environment variables
    while IFS='=' read -r key value; do
        [[ -n "$key" && -n "$value" ]] || continue
        local var_name="${prefix}${key^^}"
        declare -g "$var_name"="$value"
        echo "Set $var_name=$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file")
}

# Configuration validation
validate_config() {
    local required_vars=("$@")
    local missing_vars=()
    
    echo "Validating configuration..."
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        else
            echo "✓ $var is set"
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "❌ Missing required configuration variables:"
        printf '%s\n' "${missing_vars[@]}"
        return 1
    else
        echo "✅ All required configuration variables are set"
        return 0
    fi
}
```

### Environment Setup

#### Advanced `.bashrc` and `.profile` Management

```bash
#!/bin/bash

# Enhanced bashrc setup function
setup_enhanced_bashrc() {
    local bashrc_file="$HOME/.bashrc"
    local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Create backup
    if [[ -f "$bashrc_file" ]]; then
        cp "$bashrc_file" "$backup_file"
        echo "Backup created: $backup_file"
    fi
    
    # Add enhanced configurations
    cat >> "$bashrc_file" << 'EOF'

# ============== Enhanced Bash Configuration ==============

# Better history settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Better directory navigation
shopt -s cdspell        # Correct minor spelling errors in cd
shopt -s dirspell       # Correct spelling errors during tab completion
shopt -s autocd         # cd into directory by typing its name

# Enhanced completion
shopt -s nocaseglob     # Case-insensitive globbing
shopt -s globstar       # Enable ** recursive globbing

# Colored output
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Enhanced prompt with git status
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(parse_git_branch)\[\033[00m\]\$ '

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# System information aliases
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Development aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ============== End Enhanced Configuration ==============
EOF

    echo "Enhanced .bashrc configuration added"
    echo "Run 'source ~/.bashrc' to apply changes"
}

# Profile management
setup_profile() {
    local profile_file="$HOME/.profile"
    local backup_file="$HOME/.profile.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Create backup if file exists
    if [[ -f "$profile_file" ]]; then
        cp "$profile_file" "$backup_file"
        echo "Backup created: $backup_file"
    fi
    
    # Add profile configurations
    cat >> "$profile_file" << 'EOF'

# ============== Enhanced Profile Configuration ==============

# Add user's private bin to PATH if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Add user's private local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Development tools
if [ -d "$HOME/.npm/bin" ] ; then
    PATH="$HOME/.npm/bin:$PATH"
fi

# Go development
if [ -d "$HOME/go/bin" ] ; then
    export GOPATH="$HOME/go"
    PATH="$GOPATH/bin:$PATH"
fi

# Rust development
if [ -d "$HOME/.cargo/bin" ] ; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# Set default editor
export EDITOR=vim
export VISUAL=vim

# Set locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ============== End Enhanced Profile Configuration ==============
EOF

    echo "Enhanced .profile configuration added"
    echo "Run 'source ~/.profile' to apply changes"
}
```

# Path Manipulation

#Advanced PATH Management


# Add directory to PATH safely
add_to_path() {
    local dir="$1"
    local position="${2:-end}"  # 'start' or 'end'
    
    if [[ -z "$dir" ]]; then
        echo "Usage: add_to_path <directory> [start|end]"
        return 1
    fi
    
    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Warning: Directory '$dir' does not exist"
        return 1
    fi
    
    # Check if already in PATH
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        echo "Directory '$dir' is already in PATH"
        return 0
    fi
    
    # Add to PATH
    if [[ "$position" == "start" ]]; then
        export PATH="$dir:$PATH"
        echo "Added '$dir' to the beginning of PATH"
    else
        export PATH="$PATH:$dir"
        echo "Added '$dir' to the end of PATH"
    fi
}

# Remove directory from PATH
remove_from_path() {
    local dir="$1"
    
    if [[ -z "$dir" ]]; then
        echo "Usage: remove_from_path <directory>"
        return 1
    fi
    
    # Remove from PATH
    PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir$" | tr '\n' ':' | sed 's/:$//')
    export PATH
    echo "Removed '$dir' from PATH"
}

# Clean PATH (remove duplicates and non-existent directories)
clean_path() {
    local keep_missing="${1:-false}"
    local new_path=""
    local seen_dirs=()
    
    echo "Cleaning PATH..."
    
    # Split PATH and process each directory
    IFS=':' read -ra path_dirs <<< "$PATH"
    
    for dir in "${path_dirs[@]}"; do
        # Skip empty entries
        [[ -z "$dir" ]] && continue
        
        # Skip duplicates
        if printf '%s\n' "${seen_dirs[@]}" | grep -qx "$dir"; then
            echo "Removing duplicate: $dir"
            continue
        fi
        
        # Check if directory exists
        if [[ ! -d "$dir" ]]; then
            if [[ "$keep_missing" == "true" ]]; then
                echo "Keeping missing directory: $dir"
            else
                echo "Removing non-existent directory: $dir"
                continue
            fi
        fi
        
        # Add to new PATH
        seen_dirs+=("$dir")
        if [[ -n "$new_path" ]]; then
            new_path="$new_path:$dir"
        else
            new_path="$dir"
        fi
    done
    
    export PATH="$new_path"
    echo "PATH cleaned successfully"
}

# Display PATH in readable format
show_path() {
    echo "Current PATH directories:"
    echo "========================"
    
    IFS=':' read -ra path_dirs <<< "$PATH"
    local index=1
    
    for dir in "${path_dirs[@]}"; do
        printf "%2d. %s" "$index" "$dir"
    done

}



#!/bin/bash

# Add directory to beginning of PATH
export PATH="/usr/local/bin:$PATH"

# Add directory to end of PATH
export PATH="$PATH:/opt/custom/bin"

# Add multiple directories
export PATH="/usr/local/bin:/opt/tools/bin:$PATH"

# Check if directory exists before adding
if [ -d "/opt/custom/bin" ]; then
    export PATH="$PATH:/opt/custom/bin"
fi


#!/bin/bash

# Function to add directory to PATH permanently
add_to_path() {
    local dir="$1"
    local profile_file="$HOME/.bashrc"
    
    if [ -d "$dir" ]; then
        # Check if already in PATH
        if [[ ":$PATH:" != *":$dir:"* ]]; then
            echo "export PATH=\"$PATH:$dir\"" >> "$profile_file"
            echo "Added $dir to PATH in $profile_file"
        else
            echo "$dir is already in PATH"
        fi
    else
        echo "Directory $dir does not exist"
    fi
}

# Usage
add_to_path "/opt/mytools/bin"



#!/bin/bash

# Remove directory from PATH
remove_from_path() {
    local dir="$1"
    PATH="${PATH//":$dir:"/":"}"  # Remove from middle
    PATH="${PATH/#"$dir:"/}"      # Remove from beginning
    PATH="${PATH/%":$dir"/}"      # Remove from end
    export PATH
}

# Check if command exists in PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Find all instances of a command in PATH
find_in_path() {
    local cmd="$1"
    local IFS=':'
    for dir in $PATH; do
        if [ -x "$dir/$cmd" ]; then
            echo "$dir/$cmd"
        fi
    done
}

# Example usage
if command_exists "python3"; then
    echo "Python 3 is available"
    find_in_path "python3"
fi


#!/bin/bash

# Simple aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Aliases with safety features
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# System information aliases
alias df='df -h'
alias free='free -m'
alias top='htop'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'



#!/bin/bash

# Function to create persistent aliases
create_alias() {
    local name="$1"
    local command="$2"
    local alias_file="$HOME/.bash_aliases"
    
    # Create alias file if it doesn't exist
    touch "$alias_file"
    
    # Check if alias already exists
    if grep -q "^alias $name=" "$alias_file"; then
        echo "Alias '$name' already exists. Updating..."
        sed -i "/^alias $name=/d" "$alias_file"
    fi
    
    # Add new alias
    echo "alias $name='$command'" >> "$alias_file"
    echo "Alias '$name' created: $command"
    
    # Source the file to make it available immediately
    source "$alias_file"
}

# Function to remove alias
remove_alias() {
    local name="$1"
    local alias_file="$HOME/.bash_aliases"
    
    if [ -f "$alias_file" ]; then
        sed -i "/^alias $name=/d" "$alias_file"
        unalias "$name" 2>/dev/null
        echo "Alias '$name' removed"
    fi
}

# Function to list all aliases
list_aliases() {
    echo "Current aliases:"
    alias | sort
}

# Function to backup aliases
backup_aliases() {
    local backup_file="$HOME/.bash_aliases.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.bash_aliases" "$backup_file" 2>/dev/null
    echo "Aliases backed up to: $backup_file"
}

# Examples
create_alias "ll" "ls -la --color=auto"
create_alias "grep" "grep --color=auto"
create_alias "weather" "curl wttr.in"



#!/bin/bash

# OS-specific aliases
case "$(uname -s)" in
    Linux*)
        alias open='xdg-open'
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
        ;;
    Darwin*)
        alias ll='ls -la -G'
        alias updatedb='sudo /usr/libexec/locate.updatedb'
        ;;
esac

# Check if commands exist before creating aliases
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

if command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias ll='exa -la'
    alias tree='exa --tree'
fi


