# Process Management

# Background jobs: & operator
# Job control: jobs, fg, bg, nohup
# Process substitution: <(command) and >(command)
# Pipes and filters: Chaining commands


# Run command in background
long_running_task &
echo "Task started in background"

# Multiple background jobs
./backup.sh &
./cleanup.sh &
./monitor.sh &

# Capture background job PID
long_process &
pid=$! # last current pid
echo "Started process with PID: $pid"

# Wait for background job to complete
./process_data.sh &
job_pid=$!
wait $job_pid
echo "Background job completed"


# File compression in background
compress_files() {
    for file in *.txt; do
        gzip "$file" &
    done
    wait  # Wait for all compression jobs to finish
    echo "All files compressed"
}

# Parallel processing
parallel_grep() {
    local pattern="$1"
    shift
    
    for file in "$@"; do
        grep "$pattern" "$file" > "${file}.matches" & # Command runs independently (&). Script continues immediately.
    done
    wait
    echo "Parallel search completed"
}


parallel_grep() {
    local pattern="$1"
    shift
    local max_jobs=4
    local running=0

    for file in "$@"; do
        if (( running >= max_jobs )); then
            wait -n  # Wait for any single job to finish
            ((running--))
        fi
        grep "$pattern" "$file" > "${file}.matches" &
        ((running++))
    done
    wait
    echo "Parallel search completed"
}



# List current jobs
jobs                    # Show all jobs
jobs -l                 # Show with PIDs
jobs -p                 # Show PIDs only
jobs -r                 # Show only running jobs
jobs -s                 # Show only stopped jobs

# Bring job to foreground
fg                      # Bring most recent job to foreground
fg %1                   # Bring job 1 to foreground
fg %backup              # Bring job named 'backup' to foreground

# Send job to background
bg                      # Continue most recent stopped job in background
bg %2                   # Continue job 2 in background

# Stop and kill jobs
kill %1                 # Kill job 1
kill -STOP %2           # Stop job 2
kill -CONT %2           # Continue stopped job 2



# Run command that survives logout
nohup long_running_process &
nohup ./backup_script.sh > backup.log 2>&1 &

# Redirect output when using nohup
nohup python data_processor.py > processing.log 2>&1 &

# Check nohup jobs
ps aux | grep your_process_name



# Job management function
manage_job() {
    local action="$1"
    local job_spec="$2"
    
    case "$action" in
        start)
            eval "$job_spec" &
            echo "Started job: $job_spec (PID: $!)"
            ;;
        stop)
            kill -STOP "%${job_spec}"
            echo "Stopped job: $job_spec"
            ;;
        resume)
            bg "%${job_spec}"
            echo "Resumed job: $job_spec"
            ;;
        kill)
            kill "%${job_spec}"
            echo "Killed job: $job_spec"
            ;;
    esac
}

# Monitor background jobs
monitor_jobs() {
    while true; do
        clear
        echo "=== Active Jobs ==="
        jobs -l
        sleep 2
    done
}


# Compare output of two commands
diff <(ls /dir1) <(ls /dir2)

# Process command output as file input
while read -r line; do
    echo "Processing: $line"
done < <(find /path -name "*.txt")

# Multiple process substitutions
comm -12 <(sort file1.txt) <(sort file2.txt)

# Complex example: compare configurations
diff <(grep -v "^#" config1.conf | sort) <(grep -v "^#" config2.conf | sort)

# Split output to multiple destinations
echo "Important data" | tee >(mail admin@company.com) >(logger -t script)

# Process output through different filters
generate_data | tee >(grep ERROR > errors.log) >(grep WARNING > warnings.log)

# Complex processing pipeline
process_logs() {
    cat access.log | tee \
        >(grep "404" > 404_errors.log) \
        >(awk '{print $1}' | sort | uniq -c > ip_counts.txt) \
        >(grep "POST" > post_requests.log) \
        > /dev/null
}



# Join files based on process substitution
join -t, <(sort -t, -k1,1 file1.csv) <(sort -t, -k1,1 file2.csv)

# Create temporary named pipes
mkfifo pipe1 pipe2
producer > pipe1 &
consumer < pipe1 &
filter < pipe2 > processed_output &
tee pipe2 < input_data

# Parallel processing with process substitution
parallel_process() {
    local input_file="$1"
    
    # Split processing across multiple workers
    {
        sed -n '1,1000p' "$input_file" | process_chunk > results1.txt
    } &
    {
        sed -n '1001,2000p' "$input_file" | process_chunk > results2.txt
    } &
    {
        sed -n '2001,$p' "$input_file" | process_chunk > results3.txt
    } &
    
    wait
    cat results*.txt > final_results.txt
    rm results*.txt
}


# Simple pipe chain
cat file.txt | grep "pattern" | sort | uniq

# Multi-stage processing
ps aux | grep python | awk '{print $2}' | xargs kill

# Data transformation pipeline
cut -d, -f2 data.csv | tail -n +2 | sort -n | uniq -c | sort -nr


# Log analysis pipeline
analyze_logs() {
    local logfile="$1"
    
    cat "$logfile" | \
    grep -E "ERROR|WARN" | \
    awk '{print $1, $4, $5}' | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -20
}

# sort -nr
# -n: Numeric sort.
# -r: Reverse order (descending).
# Sorts by count (most frequent errors first).

# default sort : Alphabetically sorts the filtered lines.

# Data processing pipeline
process_sales_data() {
    cat sales.csv | \
    tail -n +2 | \                          # Skip header # -n +2: Skips the first line (header). Output starts from line 2. 
    cut -d, -f3,4,5 | \                     # Select columns #-d,: Sets comma as delimiter.
    awk -F, '$2 > 1000 {print $0}' | \      # Filter by amount # -F,: Sets comma as field separator.
    sort -t, -k2,2nr | \                    # Sort by amount # -t,: Comma delimiter. # Sorts by column 2 (2,2), numerically (n), descending (r).
    head -10                                # Top 10
}

# Network monitoring pipeline
network_stats() {
    netstat -an | \
    grep ESTABLISHED | \
    awk '{print $5}' | \
    cut -d: -f1 | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -10
}

# netstat -an
# -a: Shows all connections.
# -n: Displays IPs (no DNS resolution).




# Error handling in pipelines
set -o pipefail  # Pipeline fails if any command fails

safe_pipeline() {
    local input="$1"
    local output="$2"
    
    if cat "$input" | \
       process_step1 | \
       process_step2 | \
       process_step3 > "$output"; then
        echo "Pipeline completed successfully"
    else
        echo "Pipeline failed at step ${PIPESTATUS[*]}"
        return 1
    fi
}

# Parallel pipes
parallel_pipes() {
    local input="$1"
    
    # Split input across multiple processing pipes
    tee < "$input" \
        >(process_type_a > results_a.txt) \
        >(process_type_b > results_b.txt) \
        >(process_type_c > results_c.txt) \
        > /dev/null
    
    wait
    echo "Parallel processing complete"
}

# Conditional piping
conditional_process() {
    local data_file="$1"
    local threshold=1000
    
    if [[ $(wc -l < "$data_file") -gt $threshold ]]; then
        # Large file: use parallel processing
        split_and_process "$data_file"
    else
        # Small file: simple pipeline
        cat "$data_file" | process_simple > output.txt
    fi
}





#!/bin/bash
batch_processor() {
    local job_list="$1"
    local max_concurrent=3
    local running_jobs=0
    
    while IFS= read -r job; do
        # Wait if we've reached max concurrent jobs
        while [[ $running_jobs -ge $max_concurrent ]]; do
            wait -n  # Wait for any job to complete
            ((running_jobs--))
        done
        
        # Start new job in background
        eval "$job" &
        ((running_jobs++))
        echo "Started job: $job (PID: $!)"
    done < "$job_list"
    
    # Wait for all remaining jobs
    wait
    echo "All batch jobs completed"
}


resource_monitor() {
    local output_file="monitor_$(date +%Y%m%d_%H%M%S).log"
    
    # Start monitoring processes in background
    {
        while true; do
            echo "=== $(date) ===" >> "$output_file"
            ps aux --sort=-%cpu | head -10 >> "$output_file"
            echo "" >> "$output_file"
            sleep 30
        done
    } &
    
    local monitor_pid=$!
    echo "Resource monitoring started (PID: $monitor_pid)"
    echo "Log file: $output_file"
    echo "To stop: kill $monitor_pid"
    
    # Return monitor PID for external control
    echo $monitor_pid
}


#!/bin/bash
data_workflow() {
    local input_dir="$1"
    local output_dir="$2"
    
    mkdir -p "$output_dir"
    
    # Stage 1: Data validation (parallel)
    find "$input_dir" -name "*.csv" | while read -r file; do
        {
            validate_csv "$file" && echo "$file" >> valid_files.list
        } &
    done
    wait
    
    # Stage 2: Data processing (pipeline)
    if [[ -f valid_files.list ]]; then
        cat valid_files.list | \
        xargs -I {} sh -c 'process_csv "$1" > "'"$output_dir"'/$(basename "$1" .csv)_processed.txt"' _ {} &
    fi
    
    # Stage 3: Generate reports (background)
    {
        sleep 60  # Wait for processing to complete
        generate_summary_report "$output_dir"
    } &
    
    echo "Data workflow initiated"
    jobs -l
}

# Component Breakdown
# xargs -I {}
# xargs: Executes commands for each input item

# -I {}: Replaces {} with each input filename

# sh -c '...' _ {}
# sh -c: Executes the following command string in a new shell

# _ {}:

# _ is a placeholder for $0 (script name)

# {} becomes $1 (first argument) in the subshell


maintenance_scheduler() {
    echo "Starting system maintenance..."
    
    # Cleanup logs (background, low priority)
    nohup nice -n 10 find /var/log -name "*.log" -mtime +30 -delete &
    cleanup_pid=$!
    
    # Database backup (foreground, critical)
    backup_database || {
        echo "Database backup failed!"
        kill $cleanup_pid 2>/dev/null
        exit 1
    }
    
    # Update system packages (background)
    nohup update_packages > update.log 2>&1 &
    update_pid=$!
    
    # Monitor jobs
    echo "Maintenance jobs started:"
    echo "Cleanup PID: $cleanup_pid"
    echo "Update PID: $update_pid"
    
    # Wait for critical jobs
    wait $cleanup_pid
    echo "Maintenance completed"
}