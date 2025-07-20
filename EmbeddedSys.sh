#!/bin/bash

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

# Memory compaction/defragmentation simulation
compact_memory() {
    echo "Starting memory compaction..."
    
    # In real systems, this would move allocated blocks to eliminate fragmentation
    local compacted_size=0
    for alloc_id in "${!memory_allocations[@]}"; do
        local allocation_info="${memory_allocations[$alloc_id]}"
        local size="${allocation_info#*:}"
        memory_allocations["$alloc_id"]="$compacted_size:$size"
        compacted_size=$((compacted_size + size))
    done
    
    pool_used=$compacted_size
    echo "Memory compaction complete. Reclaimed: $((pool_size - pool_used)) bytes"
}

# Memory leak detection
check_memory_leaks() {
    echo "Checking for memory leaks..."
    
    if [ ${#memory_allocations[@]} -gt 0 ]; then
        echo "WARNING: ${#memory_allocations[@]} allocations still active:"
        for alloc_id in "${!memory_allocations[@]}"; do
            local allocation_info="${memory_allocations[$alloc_id]}"
            local size="${allocation_info#*:}"
            echo "  - $alloc_id: $size bytes"
        done
    else
        echo "No memory leaks detected"
    fi
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
declare -i simulation_time=0

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

update_battery() {
    local time_elapsed="${1:-1}"  # seconds
    
    # Calculate power consumption based on current mode
    local consumption=$((power_consumption_rate * time_elapsed / 100))
    battery_level=$((battery_level - consumption))
    
    if [ $battery_level -lt 0 ]; then
        battery_level=0
    fi
    
    simulation_time=$((simulation_time + time_elapsed))
    
    echo "Battery update: ${battery_level}% (consumed: ${consumption}% in ${time_elapsed}s)"
}

get_battery_status() {
    echo "Battery Status:"
    echo "  Level: ${battery_level}%"
    echo "  Current mode: $current_power_mode"
    echo "  Power consumption rate: ${power_consumption_rate}%/hour"
    echo "  Runtime: ${simulation_time} seconds"
    
    # Estimate remaining time
    if [ $power_consumption_rate -gt 0 ]; then
        local remaining_hours=$((battery_level * 60 / power_consumption_rate))
        echo "  Estimated remaining time: ${remaining_hours} minutes"
    fi
}

# Automatic power management based on battery level
auto_power_management() {
    if [ $battery_level -le 10 ]; then
        echo "CRITICAL: Battery very low - forcing deep sleep mode"
        set_power_mode "DEEP_SLEEP"
    elif [ $battery_level -le 25 ]; then
        echo "WARNING: Battery low - switching to sleep mode"
        set_power_mode "SLEEP"
    elif [ $battery_level -le 50 ] && [ "$current_power_mode" == "ACTIVE" ]; then
        echo "INFO: Battery moderate - switching to idle mode"
        set_power_mode "IDLE"
    fi
}

# -----------------------------------------------------------------------------
# Task Scheduling for Embedded Systems
# -----------------------------------------------------------------------------

declare -A scheduled_tasks=()
declare -i task_counter=0

schedule_task() {
    local task_name="$1"
    local priority="${2:-5}"  # 1-10, 1 is highest priority
    local memory_req="${3:-64}"
    local power_mode_req="${4:-IDLE}"
    
    task_counter=$((task_counter + 1))
    local task_id="task_$task_counter"
    
    scheduled_tasks["$task_id"]="$task_name:$priority:$memory_req:$power_mode_req"
    echo "Scheduled task: $task_name (ID: $task_id, Priority: $priority)"
}

execute_tasks() {
    echo "Executing scheduled tasks..."
    
    # Sort tasks by priority (simple bubble sort for demonstration)
    local sorted_tasks=()
    for task_id in "${!scheduled_tasks[@]}"; do
        sorted_tasks+=("$task_id")
    done
    
    # Execute tasks based on available resources
    for task_id in "${sorted_tasks[@]}"; do
        local task_info="${scheduled_tasks[$task_id]}"
        IFS=':' read -r name priority mem_req power_req <<< "$task_info"
        
        echo "Attempting to execute task: $name"
        
        # Check memory requirements
        if [ $((pool_used + mem_req)) -gt $pool_size ]; then
            echo "  SKIPPED: Insufficient memory ($mem_req bytes needed)"
            continue
        fi
        
        # Check power requirements
        if [ $battery_level -lt 15 ] && [ "$power_req" == "ACTIVE" ]; then
            echo "  SKIPPED: Insufficient battery for active mode"
            continue
        fi
        
        # Allocate memory for task
        local task_mem
        task_mem=$(allocate_memory "$mem_req")
        
        if [ $? -eq 0 ]; then
            # Set appropriate power mode
            set_power_mode "$power_req"
            
            echo "  EXECUTING: $name (using $mem_req bytes)"
            
            # Simulate task execution time
            local exec_time=$((1 + RANDOM % 3))
            update_battery "$exec_time"
            
            # Free task memory
            free_memory "$task_mem"
            
            # Remove completed task
            unset scheduled_tasks["$task_id"]
            
            echo "  COMPLETED: $name"
        else
            echo "  FAILED: Memory allocation failed"
        fi
        
        # Auto power management after each task
        auto_power_management
    done
}

# -----------------------------------------------------------------------------
# System Health Monitoring
# -----------------------------------------------------------------------------

system_health_check() {
    echo "=== System Health Check ==="
    
    # Memory health
    local mem_utilization=$(( (pool_used * 100) / pool_size ))
    if [ $mem_utilization -gt 80 ]; then
        echo "WARNING: High memory utilization (${mem_utilization}%)"
        compact_memory
    fi
    
    # Power health
    get_battery_status
    auto_power_management
    
    # Memory leak check
    check_memory_leaks
    
    echo "Health check complete"
}

# -----------------------------------------------------------------------------
# Demonstration and Test Functions
# -----------------------------------------------------------------------------

run_memory_test() {
    echo "=== Memory Management Test ==="
    
    # Initialize memory pool
    init_memory_pool 512
    
    # Test allocations
    local alloc1 alloc2 alloc3
    alloc1=$(allocate_memory 128)
    alloc2=$(allocate_memory 64 8)  # 8-byte aligned
    alloc3=$(allocate_memory 256)
    
    memory_stats
    
    # Test freeing memory
    free_memory "$alloc2"
    memory_stats
    
    # Test memory compaction
    compact_memory
    memory_stats
    
    # Clean up remaining allocations
    free_memory "$alloc1"
    free_memory "$alloc3"
    
    check_memory_leaks
}

run_power_test() {
    echo "=== Power Management Test ==="
    
    # Test different power modes
    get_battery_status
    
    # Simulate normal operation
    update_battery 5
    get_battery_status
    
    # Switch to idle mode
    set_power_mode "IDLE"
    update_battery 10
    get_battery_status
    
    # Simulate battery drain
    battery_level=30
    auto_power_management
    update_battery 5
    
    # Critical battery level
    battery_level=8
    auto_power_management
    update_battery 2
    
    get_battery_status
}

run_task_scheduling_test() {
    echo "=== Task Scheduling Test ==="
    
    # Initialize system
    init_memory_pool 1024
    battery_level=80
    set_power_mode "ACTIVE"
    
    # Schedule various tasks
    schedule_task "sensor_read" 1 32 "IDLE"
    schedule_task "data_process" 3 128 "ACTIVE"
    schedule_task "wireless_tx" 2 64 "ACTIVE"
    schedule_task "log_write" 5 16 "IDLE"
    schedule_task "system_check" 4 48 "IDLE"
    
    # Execute tasks
    execute_tasks
    
    # Final system status
    memory_stats
    get_battery_status
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    echo "Embedded System Resource Management Simulation"
    echo "=============================================="
    
    # Run individual tests
    run_memory_test
    echo
    
    run_power_test  
    echo
    
    run_task_scheduling_test
    echo
    
    # Final system health check
    system_health_check
    
    echo "=============================================="
    echo "Simulation complete"
}

# Execute main function
main