#!/bin/bash
# system_monitor.sh - Comprehensive system health monitoring

# Configuration
ALERT_EMAIL="admin@company.com"
LOG_FILE="/var/log/system_monitor.log"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
LOAD_THRESHOLD=5.0

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to send alert
send_alert() {
    local subject="$1"
    local message="$2"
    
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
    log_message "ALERT" "Alert sent: $subject"
}

# Function to check CPU usage
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        local message="High CPU usage detected: ${cpu_usage}% (Threshold: ${CPU_THRESHOLD}%)"
        log_message "WARNING" "$message"
        send_alert "High CPU Usage Alert" "$message"
        return 1
    else
        log_message "INFO" "CPU usage normal: ${cpu_usage}%"
        return 0
    fi
}

# Function to check memory usage
check_memory() {
    local memory_info=$(free | grep Mem)
    local total=$(echo $memory_info | awk '{print $2}')
    local used=$(echo $memory_info | awk '{print $3}')
    local memory_usage=$(echo "scale=2; $used/$total*100" | bc)
    
    if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
        local message="High memory usage detected: ${memory_usage}% (Threshold: ${MEMORY_THRESHOLD}%)"
        log_message "WARNING" "$message"
        send_alert "High Memory Usage Alert" "$message"
        return 1
    else
        log_message "INFO" "Memory usage normal: ${memory_usage}%"
        return 0
    fi
}

# Function to check disk usage
check_disk() {
    local alert_sent=0
    
    while IFS= read -r line; do
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        local partition=$(echo "$line" | awk '{print $6}')
        
        if [[ "$usage" =~ ^[0-9]+$ ]] && [[ $usage -gt $DISK_THRESHOLD ]]; then
            local message="High disk usage detected on $partition: ${usage}% (Threshold: ${DISK_THRESHOLD}%)"
            log_message "WARNING" "$message"
            send_alert "High Disk Usage Alert" "$message"
            alert_sent=1
        fi
    done < <(df -h | grep -E '^/dev/')
    
    if [[ $alert_sent -eq 0 ]]; then
        log_message "INFO" "All disk usage levels normal"
    fi
    
    return $alert_sent
}

# Function to check system load
check_load() {
    local load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
    
    if (( $(echo "$load_1min > $LOAD_THRESHOLD" | bc -l) )); then
        local message="High system load detected: $load_1min (Threshold: $LOAD_THRESHOLD)"
        log_message "WARNING" "$message"
        send_alert "High System Load Alert" "$message"
        return 1
    else
        log_message "INFO" "System load normal: $load_1min"
        return 0
    fi
}

# Function to check services
check_services() {
    local services=("nginx" "mysql" "postgresql" "ssh")
    local failed_services=()
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            failed_services+=("$service")
            log_message "ERROR" "Service $service is not running"
        fi
    done
    
    if [[ ${#failed_services[@]} -gt 0 ]]; then
        local message="The following services are not running: ${failed_services[*]}"
        send_alert "Service Failure Alert" "$message"
        return 1
    else
        log_message "INFO" "All monitored services are running"
        return 0
    fi
}

# Function to generate system report
generate_report() {
    local report_file="/tmp/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
System Health Report - $(date)
================================

System Information:
$(uname -a)

Uptime:
$(uptime)

CPU Usage:
$(top -bn1 | head -5)

Memory Usage:
$(free -h)

Disk Usage:
$(df -h)

Network Connections:
$(netstat -tuln | head -10)

Running Processes (Top 10):
$(ps aux --sort=-%cpu | head -10)

System Load:
$(cat /proc/loadavg)
EOF

    echo "$report_file"
}

# Main monitoring function
main() {
    log_message "INFO" "Starting system health check"
    
    local checks_failed=0
    
    # Run all checks
    check_cpu || ((checks_failed++))
    check_memory || ((checks_failed++))
    check_disk || ((checks_failed++))
    check_load || ((checks_failed++))
    check_services || ((checks_failed++))
    
    # Generate report if there are issues
    if [[ $checks_failed -gt 0 ]]; then
        local report_file=$(generate_report)
        send_alert "System Health Issues Detected" "System health check found $checks_failed issues. See attached report: $report_file"
    fi
    
    log_message "INFO" "System health check completed ($checks_failed issues found)"
    
    return $checks_failed
}

main "$@"