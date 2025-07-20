#!/bin/bash

# Container orchestration: Docker and Kubernetes scripts
# Cloud automation: AWS/Azure/GCP integration
# Infrastructure as code: Terraform integration
# Monitoring integration: Prometheus, Grafana scripts


# Performance & Scalability

# Parallel processing: Background job management
# Load balancing: Distributing tasks across systems
# Resource optimization: CPU and memory efficiency
# Scalable architectures: Designing for growth


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
            echo "CRITICAL: Memory usage is very high!"
            return 2
        elif [[ $used_percent -gt 80 ]]; then
            echo "WARNING: Memory usage is high"
            return 1
        else
            echo "Memory usage is normal"
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
                echo " ALERT!"
                ((alert_count++))
            elif [[ $usage -gt $((threshold - 10)) ]]; then
                echo " WARNING"
            else
                echo "OK"
            fi
        fi
    done < <(df -h)
    
    echo
    if [[ $alert_count -gt 0 ]]; then
        echo "$alert_count filesystem(s) exceed threshold"
        return 1
    else
        echo "All filesystems within acceptable limits"
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
        echo "Load check passed" | tee -a "$log_file"
    else
        echo "Load check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Check memory
    echo "2. Memory Check:" | tee -a "$log_file"
    local mem_status
    monitor_memory 2>&1 | tee -a "$log_file"
    mem_status=${PIPESTATUS[0]}
    if [[ $mem_status -eq 0 ]]; then
        echo "Memory check passed" | tee -a "$log_file"
    else
        echo "Memory check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Check disk space
    echo "3. Disk Space Check:" | tee -a "$log_file"
    if monitor_disk_space 2>&1 | tee -a "$log_file"; then
        echo "Disk space check passed" | tee -a "$log_file"
    else
        echo "Disk space check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Check connectivity
    echo "4. Network Connectivity Check:" | tee -a "$log_file"
    if check_connectivity 2>&1 | tee -a "$log_file"; then
        echo "Connectivity check passed" | tee -a "$log_file"
    else
        echo "Connectivity check failed" | tee -a "$log_file"
        overall_status=1
    fi
    echo | tee -a "$log_file"
    
    # Overall status
    echo "=== Overall Health Status ===" | tee -a "$log_file"
    if [[ $overall_status -eq 0 ]]; then
        echo "System is healthy!" | tee -a "$log_file"
    else
        echo "System issues detected. Review the details above." | tee -a "$log_file"
    fi
    
    echo "Health check completed. Log saved to: $log_file"
    return $overall_status
}


