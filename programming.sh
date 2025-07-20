#!/bin/bash

# =============================================================================
# EXPERT-LEVEL BASH TECHNIQUES
# Advanced Algorithm Implementation and System Programming
# =============================================================================

# =============================================================================
# 1. DYNAMIC PROGRAMMING - Complex Algorithm Implementation
# =============================================================================

echo "=== Dynamic Programming Algorithms ==="

# -----------------------------------------------------------------------------
# Fibonacci with Memoization (Top-Down Approach)
# -----------------------------------------------------------------------------
declare -A fib_memo=()

fibonacci_memoized() {
    local n="$1"
    
    # Base cases
    if [ "$n" -le 1 ]; then
        echo "$n"
        return
    fi
    
    # Check if already computed
    if [ -n "${fib_memo[$n]}" ]; then
        echo "${fib_memo[$n]}"
        return
    fi
    
    # Compute and store result
    local fib_n_1 fib_n_2 result
    fib_n_1=$(fibonacci_memoized $((n - 1)))
    fib_n_2=$(fibonacci_memoized $((n - 2)))
    result=$((fib_n_1 + fib_n_2))
    
    fib_memo[$n]=$result
    echo "$result"
}

# Fibonacci Bottom-Up Approach (More Memory Efficient)
fibonacci_bottom_up() {
    local n="$1"
    
    if [ "$n" -le 1 ]; then
        echo "$n"
        return
    fi
    
    local prev=0 curr=1
    
    for ((i = 2; i <= n; i++)); do
        local temp=$curr
        curr=$((prev + curr))
        prev=$temp
    done
    
    echo "$curr"
}

# -----------------------------------------------------------------------------
# Longest Common Subsequence (LCS)
# -----------------------------------------------------------------------------
longest_common_subsequence() {
    local str1="$1"
    local str2="$2"
    local len1=${#str1}
    local len2=${#str2}
    
    # Create 2D DP table using associative array
    declare -A lcs_table
    
    # Initialize base cases
    for ((i = 0; i <= len1; i++)); do
        lcs_table[$i,0]=0
    done
    
    for ((j = 0; j <= len2; j++)); do
        lcs_table[0,$j]=0
    done
    
    # Fill the table
    for ((i = 1; i <= len1; i++)); do
        for ((j = 1; j <= len2; j++)); do
            if [ "${str1:$((i-1)):1}" = "${str2:$((j-1)):1}" ]; then
                lcs_table[$i,$j]=$((lcs_table[$((i-1)),$((j-1))] + 1))
            else
                local up=${lcs_table[$((i-1)),$j]}
                local left=${lcs_table[$i,$((j-1))]}
                lcs_table[$i,$j]=$(( up > left ? up : left ))
            fi
        done
    done
    
    echo "LCS length: ${lcs_table[$len1,$len2]}"
    
    # Reconstruct the actual LCS
    reconstruct_lcs() {
        local i=$len1 j=$len2 lcs=""
        
        while [ $i -gt 0 ] && [ $j -gt 0 ]; do
            if [ "${str1:$((i-1)):1}" = "${str2:$((j-1)):1}" ]; then
                lcs="${str1:$((i-1)):1}$lcs"
                i=$((i - 1))
                j=$((j - 1))
            elif [ ${lcs_table[$((i-1)),$j]} -gt ${lcs_table[$i,$((j-1))]} ]; then
                i=$((i - 1))
            else
                j=$((j - 1))
            fi
        done
        
        echo "LCS: $lcs"
    }
    
    reconstruct_lcs
}

# -----------------------------------------------------------------------------
# Knapsack Problem (0/1 Knapsack)
# -----------------------------------------------------------------------------
knapsack_01() {
    local capacity="$1"
    shift
    local items=("$@")  # Format: "weight,value weight,value ..."
    
    local n=${#items[@]}
    declare -A dp
    
    # Initialize DP table
    for ((i = 0; i <= n; i++)); do
        for ((w = 0; w <= capacity; w++)); do
            dp[$i,$w]=0
        done
    done
    
    # Fill the table
    for ((i = 1; i <= n; i++)); do
        local item="${items[$((i-1))]}"
        local weight="${item%,*}"
        local value="${item#*,}"
        
        for ((w = 1; w <= capacity; w++)); do
            # Don't take the item
            dp[$i,$w]=${dp[$((i-1)),$w]}
            
            # Take the item if possible
            if [ $w -ge $weight ]; then
                local with_item=$((dp[$((i-1)),$((w-weight))] + value))
                if [ $with_item -gt ${dp[$i,$w]} ]; then
                    dp[$i,$w]=$with_item
                fi
            fi
        done
    done
    
    echo "Maximum value: ${dp[$n,$capacity]}"
    
    # Reconstruct solution
    reconstruct_knapsack() {
        local i=$n w=$capacity
        local selected=()
        
        while [ $i -gt 0 ] && [ $w -gt 0 ]; do
            if [ ${dp[$i,$w]} != ${dp[$((i-1)),$w]} ]; then
                local item="${items[$((i-1))]}"
                selected+=("Item $i: ${item}")
                local weight="${item%,*}"
                w=$((w - weight))
            fi
            i=$((i - 1))
        done
        
        echo "Selected items:"
        printf '%s\n' "${selected[@]}"
    }
    
    reconstruct_knapsack
}

# -----------------------------------------------------------------------------
# Edit Distance (Levenshtein Distance)
# -----------------------------------------------------------------------------
edit_distance() {
    local str1="$1"
    local str2="$2"
    local len1=${#str1}
    local len2=${#str2}
    
    declare -A ed_table
    
    # Initialize base cases
    for ((i = 0; i <= len1; i++)); do
        ed_table[$i,0]=$i
    done
    
    for ((j = 0; j <= len2; j++)); do
        ed_table[0,$j]=$j
    done
    
    # Fill the table
    for ((i = 1; i <= len1; i++)); do
        for ((j = 1; j <= len2; j++)); do
            local cost=1
            if [ "${str1:$((i-1)):1}" = "${str2:$((j-1)):1}" ]; then
                cost=0
            fi
            
            local delete=$((ed_table[$((i-1)),$j] + 1))
            local insert=$((ed_table[$i,$((j-1))] + 1))
            local substitute=$((ed_table[$((i-1)),$((j-1))] + cost))
            
            # Find minimum
            local min=$delete
            [ $insert -lt $min ] && min=$insert
            [ $substitute -lt $min ] && min=$substitute
            
            ed_table[$i,$j]=$min
        done
    done
    
    echo "Edit distance between '$str1' and '$str2': ${ed_table[$len1,$len2]}"
}

# Demo function for Dynamic Programming
demo_dynamic_programming() {
    echo "--- Fibonacci Sequence ---"
    for i in {1..10}; do
        echo "F($i) = $(fibonacci_bottom_up $i)"
    done
    
    echo -e "\n--- Longest Common Subsequence ---"
    longest_common_subsequence "ABCDGH" "AEDFHR"
    
    echo -e "\n--- Knapsack Problem ---"
    # Items: weight,value
    knapsack_01 10 "2,1" "1,1" "3,4" "2,5" "1,7"
    
    echo -e "\n--- Edit Distance ---"
    edit_distance "kitten" "sitting"
}

# =============================================================================
# 2. STATE MACHINES - Implementing Stateful Logic
# =============================================================================

echo -e "\n=== State Machine Implementation ==="

# -----------------------------------------------------------------------------
# Generic State Machine Framework
# -----------------------------------------------------------------------------
declare -A state_machine_states=()
declare -A state_machine_transitions=()
declare -A state_machine_actions=()
declare state_machine_current_state=""

# Initialize state machine
init_state_machine() {
    local initial_state="$1"
    state_machine_current_state="$initial_state"
    echo "State machine initialized with state: $initial_state"
}

# Add state to machine
add_state() {
    local state="$1"
    local entry_action="${2:-}"
    
    state_machine_states["$state"]=1
    if [ -n "$entry_action" ]; then
        state_machine_actions["${state}_entry"]="$entry_action"
    fi
    
    echo "Added state: $state"
}

# Add transition between states
add_transition() {
    local from_state="$1"
    local to_state="$2"
    local event="$3"
    local guard_condition="${4:-true}"
    local action="${5:-}"
    
    local transition_key="${from_state}_${event}"
    state_machine_transitions["$transition_key"]="${to_state}|${guard_condition}|${action}"
    
    echo "Added transition: $from_state --[$event]--> $to_state"
}

# Process event in state machine
process_event() {
    local event="$1"
    local transition_key="${state_machine_current_state}_${event}"
    
    if [ -z "${state_machine_transitions[$transition_key]}" ]; then
        echo "No transition for event '$event' in state '$state_machine_current_state'"
        return 1
    fi
    
    local transition_data="${state_machine_transitions[$transition_key]}"
    local to_state="${transition_data%%|*}"
    local remaining="${transition_data#*|}"
    local guard="${remaining%%|*}"
    local action="${remaining#*|}"
    
    # Evaluate guard condition
    if ! eval "$guard"; then
        echo "Guard condition failed for transition"
        return 1
    fi
    
    # Execute transition action
    if [ -n "$action" ] && [ "$action" != "" ]; then
        echo "Executing transition action: $action"
        eval "$action"
    fi
    
    # Change state
    local old_state="$state_machine_current_state"
    state_machine_current_state="$to_state"
    
    # Execute entry action for new state
    local entry_action_key="${to_state}_entry"
    if [ -n "${state_machine_actions[$entry_action_key]}" ]; then
        echo "Executing entry action for state $to_state"
        eval "${state_machine_actions[$entry_action_key]}"
    fi
    
    echo "State transition: $old_state -> $to_state (event: $event)"
    return 0
}

# Get current state
get_current_state() {
    echo "$state_machine_current_state"
}

# -----------------------------------------------------------------------------
# Traffic Light State Machine Example
# -----------------------------------------------------------------------------
setup_traffic_light() {
    echo "--- Setting up Traffic Light State Machine ---"
    
    # Initialize states
    init_state_machine "RED"
    
    # Add states with entry actions
    add_state "RED" "echo 'STOP! Red light active'"
    add_state "YELLOW" "echo 'CAUTION! Yellow light active'"
    add_state "GREEN" "echo 'GO! Green light active'"
    
    # Add transitions
    add_transition "RED" "GREEN" "TIMER" "true" "echo 'Switching to GREEN'"
    add_transition "GREEN" "YELLOW" "TIMER" "true" "echo 'Switching to YELLOW'"
    add_transition "YELLOW" "RED" "TIMER" "true" "echo 'Switching to RED'"
    
    # Emergency transitions
    add_transition "GREEN" "RED" "EMERGENCY" "true" "echo 'EMERGENCY! All stop!'"
    add_transition "YELLOW" "RED" "EMERGENCY" "true" "echo 'EMERGENCY! All stop!'"
}

# -----------------------------------------------------------------------------
# TCP Connection State Machine Example
# -----------------------------------------------------------------------------
setup_tcp_connection() {
    echo "--- Setting up TCP Connection State Machine ---"
    
    init_state_machine "CLOSED"
    
    # TCP states
    add_state "CLOSED" "echo 'Connection closed'"
    add_state "LISTEN" "echo 'Listening for connections'"
    add_state "SYN_SENT" "echo 'SYN packet sent'"
    add_state "SYN_RECEIVED" "echo 'SYN packet received'"
    add_state "ESTABLISHED" "echo 'Connection established'"
    add_state "FIN_WAIT_1" "echo 'FIN sent, waiting for ACK'"
    add_state "FIN_WAIT_2" "echo 'FIN ACKed, waiting for FIN'"
    add_state "CLOSE_WAIT" "echo 'Waiting for close'"
    add_state "LAST_ACK" "echo 'Waiting for last ACK'"
    add_state "TIME_WAIT" "echo 'Waiting for timeout'"
    
    # TCP transitions (simplified)
    add_transition "CLOSED" "LISTEN" "LISTEN" "true"
    add_transition "CLOSED" "SYN_SENT" "CONNECT" "true"
    add_transition "LISTEN" "SYN_RECEIVED" "SYN" "true"
    add_transition "SYN_SENT" "ESTABLISHED" "SYN_ACK" "true"
    add_transition "SYN_RECEIVED" "ESTABLISHED" "ACK" "true"
    add_transition "ESTABLISHED" "FIN_WAIT_1" "CLOSE" "true"
    add_transition "ESTABLISHED" "CLOSE_WAIT" "FIN" "true"
    add_transition "FIN_WAIT_1" "FIN_WAIT_2" "ACK" "true"
    add_transition "FIN_WAIT_2" "TIME_WAIT" "FIN" "true"
    add_transition "CLOSE_WAIT" "LAST_ACK" "CLOSE" "true"
    add_transition "LAST_ACK" "CLOSED" "ACK" "true"
    add_transition "TIME_WAIT" "CLOSED" "TIMEOUT" "true"
}

# -----------------------------------------------------------------------------
# Parser State Machine for Simple Protocol
# -----------------------------------------------------------------------------
declare parser_buffer=""
declare -A parser_data=()

setup_protocol_parser() {
    echo "--- Setting up Protocol Parser State Machine ---"
    
    init_state_machine "WAITING_HEADER"
    
    add_state "WAITING_HEADER" "parser_buffer=''"
    add_state "READING_LENGTH" ""
    add_state "READING_DATA" ""
    add_state "MESSAGE_COMPLETE" "echo 'Message parsing complete'"
    
    add_transition "WAITING_HEADER" "READING_LENGTH" "HEADER_FOUND" "true" "echo 'Header found, reading length'"
    add_transition "READING_LENGTH" "READING_DATA" "LENGTH_READ" "true" "echo 'Length read, reading data'"
    add_transition "READING_DATA" "MESSAGE_COMPLETE" "DATA_COMPLETE" "true" "echo 'Data read completely'"
    add_transition "MESSAGE_COMPLETE" "WAITING_HEADER" "RESET" "true" "echo 'Resetting for next message'"
}

# Process incoming data for protocol parser
parse_protocol_data() {
    local data="$1"
    parser_buffer="${parser_buffer}${data}"
    
    case "$(get_current_state)" in
        "WAITING_HEADER")
            if [[ "$parser_buffer" == *"MSG:"* ]]; then
                parser_buffer="${parser_buffer#*MSG:}"
                process_event "HEADER_FOUND"
            fi
            ;;
        "READING_LENGTH")
            if [[ "$parser_buffer" =~ ^[0-9]+: ]]; then
                local length_part="${parser_buffer%%:*}"
                parser_data["expected_length"]="$length_part"
                parser_buffer="${parser_buffer#*:}"
                process_event "LENGTH_READ"
            fi
            ;;
        "READING_DATA")
            local expected_length="${parser_data[expected_length]}"
            if [ ${#parser_buffer} -ge "$expected_length" ]; then
                parser_data["message"]="${parser_buffer:0:$expected_length}"
                parser_buffer="${parser_buffer:$expected_length}"
                process_event "DATA_COMPLETE"
            fi
            ;;
        "MESSAGE_COMPLETE")
            echo "Parsed message: ${parser_data[message]}"
            process_event "RESET"
            ;;
    esac
}

# Demo function for State Machines
demo_state_machines() {
    echo "--- Traffic Light Demo ---"
    setup_traffic_light
    
    for i in {1..6}; do
        echo "Current state: $(get_current_state)"
        process_event "TIMER"
        sleep 1
    done
    
    echo -e "\n--- TCP Connection Demo ---"
    setup_tcp_connection
    
    local tcp_events=("LISTEN" "SYN" "ACK" "CLOSE" "ACK")
    for event in "${tcp_events[@]}"; do
        echo "Current state: $(get_current_state)"
        process_event "$event"
    done
    
    echo -e "\n--- Protocol Parser Demo ---"
    setup_protocol_parser
    
    # Simulate receiving protocol data
    parse_protocol_data "MSG:12:Hello World!"
    parse_protocol_data "MSG:5:Test!"
}

# =============================================================================
# 3. PROTOCOL IMPLEMENTATION - Custom Protocol Handling
# =============================================================================

echo -e "\n=== Custom Protocol Implementation ==="

# -----------------------------------------------------------------------------
# Simple Text-Based Protocol Implementation
# -----------------------------------------------------------------------------

# Protocol format: COMMAND:LENGTH:DATA\n
# Commands: PING, PONG, DATA, QUIT

declare -A protocol_handlers=()
declare protocol_server_running=false

# Register protocol handler
register_protocol_handler() {
    local command="$1"
    local handler_function="$2"
    protocol_handlers["$command"]="$handler_function"
    echo "Registered handler for command: $command"
}

# Protocol message builder
build_protocol_message() {
    local command="$1"
    local data="$2"
    local length=${#data}
    
    echo "${command}:${length}:${data}"
}

# Protocol message parser
parse_protocol_message() {
    local message="$1"
    
    # Extract components
    local command="${message%%:*}"
    local remaining="${message#*:}"
    local length="${remaining%%:*}"
    local data="${remaining#*:}"
    
    # Validate length
    if [ ${#data} -ne "$length" ]; then
        echo "ERROR: Data length mismatch"
        return 1
    fi
    
    echo "COMMAND:$command"
    echo "LENGTH:$length"
    echo "DATA:$data"
    
    # Call appropriate handler
    if [ -n "${protocol_handlers[$command]}" ]; then
        ${protocol_handlers[$command]} "$data"
    else
        echo "ERROR: Unknown command: $command"
        return 1
    fi
}

# Protocol handlers
handle_ping() {
    local data="$1"
    echo "Received PING: $data"
    local response
    response=$(build_protocol_message "PONG" "$data")
    echo "Sending response: $response"
}

handle_data() {
    local data="$1"
    echo "Received DATA: $data"
    # Process the data here
    echo "Data processed successfully"
}

handle_quit() {
    local data="$1"
    echo "Received QUIT command: $data"
    protocol_server_running=false
    echo "Server shutting down..."
}

# -----------------------------------------------------------------------------
# Binary Protocol Implementation
# -----------------------------------------------------------------------------

# Binary protocol: [MAGIC][VERSION][COMMAND][LENGTH][DATA][CHECKSUM]
# MAGIC: 4 bytes (0xDEADBEEF)
# VERSION: 1 byte
# COMMAND: 1 byte
# LENGTH: 2 bytes (big-endian)
# DATA: variable length
# CHECKSUM: 2 bytes (simple XOR checksum)

create_binary_message() {
    local command="$1"
    local data="$2"
    local version=1
    
    # Convert to binary representation (simplified for bash)
    local magic="DEAD"  # Simplified magic number
    local cmd_byte
    
    case "$command" in
        "PING") cmd_byte="01" ;;
        "PONG") cmd_byte="02" ;;
        "DATA") cmd_byte="03" ;;
        "QUIT") cmd_byte="04" ;;
        *) cmd_byte="00" ;;
    esac
    
    local length=$(printf "%04x" ${#data})
    
    # Calculate simple checksum (XOR of all bytes)
    local checksum=0
    for ((i = 0; i < ${#data}; i++)); do
        local char_code
        char_code=$(printf "%d" "'${data:$i:1}")
        checksum=$((checksum ^ char_code))
    done
    checksum=$(printf "%04x" $checksum)
    
    # Construct message
    local message="${magic}${version}${cmd_byte}${length}${data}${checksum}"
    echo "$message"
}

parse_binary_message() {
    local message="$1"
    
    # Extract components (simplified parsing)
    local magic="${message:0:4}"
    local version="${message:4:1}"
    local command="${message:5:2}"
    local length_hex="${message:7:4}"
    
    # Convert hex length to decimal
    local length=$((16#$length_hex))
    local data="${message:11:$length}"
    local checksum="${message:$((11 + length)):4}"
    
    echo "Magic: $magic"
    echo "Version: $version"
    echo "Command: $command"
    echo "Length: $length"
    echo "Data: $data"
    echo "Checksum: $checksum"
    
    # Validate magic number
    if [ "$magic" != "DEAD" ]; then
        echo "ERROR: Invalid magic number"
        return 1
    fi
    
    # Verify checksum
    local calculated_checksum=0
    for ((i = 0; i < ${#data}; i++)); do
        local char_code
        char_code=$(printf "%d" "'${data:$i:1}")
        calculated_checksum=$((calculated_checksum ^ char_code))
    done
    calculated_checksum=$(printf "%04x" $calculated_checksum)
    
    if [ "$checksum" != "$calculated_checksum" ]; then
        echo "ERROR: Checksum mismatch"
        return 1
    fi
    
    echo "Message validated successfully"
}

# -----------------------------------------------------------------------------
# HTTP-like Protocol Implementation
# -----------------------------------------------------------------------------

# Simple HTTP-like protocol parser
parse_http_request() {
    local request="$1"
    
    # Parse request line
    local request_line
    request_line=$(echo "$request" | head -n1)
    
    local method="${request_line%% *}"
    local remaining="${request_line#* }"
    local path="${remaining%% *}"
    local version="${remaining#* }"
    
    echo "Method: $method"
    echo "Path: $path"
    echo "Version: $version"
    
    # Parse headers
    echo "Headers:"
    echo "$request" | tail -n +2 | while IFS=: read -r header value; do
        if [ -n "$header" ] && [ -n "$value" ]; then
            echo "  $header:$value"
        fi
    done
}

build_http_response() {
    local status_code="$1"
    local status_text="$2"
    local content_type="$3"
    local body="$4"
    
    local content_length=${#body}
    
    cat << EOF
HTTP/1.1 $status_code $status_text
Content-Type: $content_type
Content-Length: $content_length
Connection: close

$body
EOF
}

# -----------------------------------------------------------------------------
# Protocol Server Implementation
# -----------------------------------------------------------------------------
start_protocol_server() {
    local port="${1:-8080}"
    local protocol_type="${2:-text}"
    
    echo "Starting protocol server on port $port (type: $protocol_type)"
    protocol_server_running=true
    
    # Register handlers
    register_protocol_handler "PING" "handle_ping"
    register_protocol_handler "DATA" "handle_data"
    register_protocol_handler "QUIT" "handle_quit"
    
    # Simulate server loop
    simulate_server_loop() {
        local client_requests=(
            "PING:4:test"
            "DATA:12:Hello Server"
            "QUIT:3:bye"
        )
        
        for request in "${client_requests[@]}"; do
            if [ "$protocol_server_running" = false ]; then
                break
            fi
            
            echo "Received: $request"
            parse_protocol_message "$request"
            echo "---"
            sleep 1
        done
    }
    
    simulate_server_loop
}

# Demo function for Protocol Implementation
demo_protocol_implementation() {
    echo "--- Text Protocol Demo ---"
    
    local ping_msg
    ping_msg=$(build_protocol_message "PING" "test123")
    echo "Built message: $ping_msg"
    parse_protocol_message "$ping_msg"
    
    echo -e "\n--- Binary Protocol Demo ---"
    local binary_msg
    binary_msg=$(create_binary_message "DATA" "binary_test")
    echo "Binary message: $binary_msg"
    parse_binary_message "$binary_msg"
    
    echo -e "\n--- HTTP-like Protocol Demo ---"
    local http_request="GET /index.html HTTP/1.1
Host: example.com
User-Agent: BashClient/1.0
Accept: text/html"
    
    echo "Parsing HTTP request:"
    parse_http_request "$http_request"
    
    echo -e "\nBuilding HTTP response:"
    build_http_response "200" "OK" "text/html" "<html><body>Hello World</body></html>"
    
    echo -e "\n--- Protocol Server Demo ---"
    start_protocol_server 8080 "text"
}

# =============================================================================
# 4. EMBEDDED SYSTEMS - Resource-Constrained Environments
# =============================================================================

echo -e "\n=== Embedded Systems Programming ==="

#!/bin/bash

# Embedded System Resource Management Scripts
# Simulating resource-constrained environment operations

echo "=== Embedded System Resource Monitor ==="

# 1. Memory Management - Check available RAM
check_memory() {
    echo "--- Memory Status ---"
    # Get memory info (embedded systems often have very limited RAM)
    total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    avail_mem=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}')
    
    # Convert to MB for readability
    total_mb=$((total_mem / 1024))
    avail_mb=$((avail_mem / 1024))
    used_mb=$((total_mb - avail_mb))
    
    echo "Total RAM: ${total_mb}MB"
    echo "Used RAM: ${used_mb}MB" 
    echo "Available RAM: ${avail_mb}MB"
    
    # Alert if memory usage is high (critical for embedded systems)
    usage_percent=$((used_mb * 100 / total_mb))
    if [ $usage_percent -gt 80 ]; then
        echo "WARNING: High memory usage (${usage_percent}%)"
    fi
}

# 2. Storage Management - Monitor flash/disk usage
check_storage() {
    echo "--- Storage Status ---"
    # Check root filesystem (represents flash storage)
    df -h / | tail -1 | while read fs size used avail percent mount; do
        echo "Storage: $size total, $used used, $avail available ($percent full)"
        
        # Extract percentage number
        percent_num=$(echo $percent | sed 's/%//')
        if [ $percent_num -gt 85 ]; then
            echo "WARNING: Storage nearly full ($percent)"
        fi
    done
}

# 3. CPU Usage Monitoring
check_cpu() {
    echo "--- CPU Status ---"
    # Get CPU load average
    load=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
    echo "CPU Load Average (1min): $load"
    
    # Simple CPU usage check
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    echo "CPU Usage: ${cpu_usage}%"
}

# 4. Process Management - List critical processes
monitor_processes() {
    echo "--- Critical Processes ---"
    # Show only essential processes (embedded systems run minimal processes)
    ps aux --sort=-%mem | head -5 | while read user pid cpu mem vsz rss tty stat start time command; do
        if [ "$user" != "USER" ]; then  # Skip header
            echo "PID: $pid, CPU: $cpu%, MEM: $mem%, CMD: $command"
        fi
    done
}

# 5. Temperature Monitoring (critical for embedded systems)
check_temperature() {
    echo "--- Temperature Status ---"
    # Check if thermal info is available
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp_celsius=$((temp_raw / 1000))
        echo "CPU Temperature: ${temp_celsius}°C"
        
        # Alert for high temperature
        if [ $temp_celsius -gt 70 ]; then
            echo "WARNING: High temperature detected!"
        fi
    else
        echo "Temperature monitoring not available"
    fi
}

# 6. Power Management Simulation
power_management() {
    echo "--- Power Management ---"
    
    # Simulate battery level check
    battery_level=$((50 + RANDOM % 50))  # Random level between 50-100%
    echo "Battery Level: ${battery_level}%"
    
    # Power saving mode trigger
    if [ $battery_level -lt 20 ]; then
        echo "ALERT: Low battery - entering power saving mode"
        echo "- Reducing CPU frequency"
        echo "- Disabling non-essential peripherals"
        echo "- Increasing sleep intervals"
    fi
}

# 7. Log Management (space-conscious for embedded systems)
manage_logs() {
    echo "--- Log Management ---"
    
    # Create sample log directory
    LOG_DIR="/tmp/embedded_logs"
    mkdir -p $LOG_DIR
    
    # Simulate log rotation to save space
    max_log_size=1024  # 1KB max for demonstration
    
    for logfile in sensor.log system.log error.log; do
        log_path="$LOG_DIR/$logfile"
        
        # Create dummy log if it doesn't exist
        if [ ! -f "$log_path" ]; then
            echo "$(date): Sample log entry" > "$log_path"
        fi
        
        # Check log size
        if [ -f "$log_path" ]; then
            size=$(stat -f%z "$log_path" 2>/dev/null || stat -c%s "$log_path" 2>/dev/null)
            echo "Log $logfile: ${size} bytes"
            
            # Rotate if too large
            if [ $size -gt $max_log_size ]; then
                echo "Rotating $logfile (size limit exceeded)"
                mv "$log_path" "${log_path}.old"
                touch "$log_path"
            fi
        fi
    done
}

# 8. Watchdog Timer Simulation
watchdog_check() {
    echo "--- Watchdog Status ---"
    
    # Simulate watchdog timer check
    last_heartbeat=$(date +%s)
    current_time=$(date +%s)
    
    echo "Last heartbeat: $(date -d @$last_heartbeat)"
    echo "Watchdog timer: Active"
    echo "System health: OK"
    
    # In real embedded system, this would reset the hardware watchdog
    echo "Watchdog timer reset"
}

# Main execution
main() {
    echo "Starting embedded system health check..."
    echo "Timestamp: $(date)"
    echo "============================================"
    
    check_memory
    echo
    check_storage  
    echo
    check_cpu
    echo
    monitor_processes
    echo
    check_temperature
    echo
    power_management
    echo
    manage_logs
    echo
    watchdog_check
    
    echo "============================================"
    echo "Health check complete"
    
    # Cleanup
    rm -rf /tmp/embedded_logs
}

# Run the main function
main

# -----------------------------------------------------------------------------
# Memory Management for Resource-Constrained Systems
# -----------------------------------------------------------------------------

# Memory pool allocator simulation
declare -a memory_pool=()
declare -A memory_allocations=()
declare -i pool_size=1024
declare -i pool_used=0

init_memory_pool() {
    local size="${1:-1024}"
    pool_size=$size
    pool_used=0
    memory_pool=()
    memory_allocations=()
    
    echo "Initialized memory pool: $size bytes"
}

allocate_memory() {
    local request_size="$1"
    local alignment="${2:-4}"  # Default 4-byte alignment
    
    # Align request size
    local aligned_size=$(( (request_size + alignment - 1) & ~(alignment - 1) ))
    
    if [ $((pool_used + aligned_size)) -gt $pool_size ]; then
        echo "ERROR: Out of memory (requested: $aligned_size, available: $((pool_size - pool_used)))"
        return 1
    fi
    
    local allocation_id="alloc_$$_$RANDOM"
    memory_allocations["$allocation_id"]="$pool_used:$aligned_size"
    pool_used=$((pool_used + aligned_size))
    
    echo "Allocated $aligned_size bytes at offset $pool_used (ID: $allocation_id)"
    echo "$allocation_id"
}

free_memory() {
    local allocation_id="$1"
    
    if [ -z "${memory_allocations[$allocation_id]}" ]; then
        echo "ERROR: Invalid allocation ID: $allocation_id"
        return 1
    fi
    
    local allocation_info="${memory_allocations[$allocation_id]}"
    local size="${allocation_info#*:}"
    
    unset memory_allocations["$allocation_id"]
    # Note: This is a simplified implementation - real embedded systems
    # would need proper defragmentation
    
    echo "Freed allocation: $allocation_id ($size bytes)"
}

memory_stats() {
    echo "Memory Pool Statistics:"
    echo "  Total size: $pool_size bytes"
    echo "  Used: $pool_used bytes"
    echo "  Free: $((pool_size - pool_used)) bytes"
    echo "  Utilization: $(( (pool_used * 100) / pool_size ))%"
    echo "  Active allocations: ${#memory_allocations[@]}"
}

# -----------------------------------------------------------------------------
# Power Management Simulation
# -----------------------------------------------------------------------------

declare -A power_modes=(
    ["ACTIVE"]=100
    ["IDLE"]=30
    ["SLEEP"]=5
    ["DEEP_SLEEP"]=1
)
declare current_power_mode="ACTIVE"
declare -i battery_level=100
declare -i power_consumption_rate=1

set_power_mode() {
    local mode="$1"
    
    if [ -z "${power_modes[$mode]}" ]; then
        echo "ERROR: Invalid power mode: $mode"
        return 1
    fi
    
    local old_mode="$current_power_mode"
    current_power_mode="$mode"
    power_consumption_rate="${power_modes[$mode]}"
    
    echo "Power mode changed: $old_mode -> $mode (consumption: ${power_consumption_rate}%)"
    
    # Simulate wake-up delays for low-power modes
    case "$mode" in
        "SLEEP")
            echo "Entering sleep mode (wake-up delay: 100ms)"
            ;;
        "DEEP_SLEEP")
            echo "Entering deep sleep mode (wake-up delay: 1s)"
            ;;
    esac
}



