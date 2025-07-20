#!/bin/bash

# Create a named pipe
mkfifo mypipe

# In one terminal/process - writer
echo "Hello from process 1" > mypipe &

# In another terminal/process - reader
cat < mypipe



# Producer-Consumer pattern
PIPE_NAME="/tmp/data_pipe"

# Create the pipe
mkfifo "$PIPE_NAME"

# Producer function
producer() {
    for i in {1..10}; do
        echo "Data packet $i: $(date)" > "$PIPE_NAME"
        sleep 1
    done
    echo "DONE" > "$PIPE_NAME"
}

# Consumer function
consumer() {
    while read line < "$PIPE_NAME"; do
        if [[ "$line" == "DONE" ]]; then
            break
        fi
        echo "Processed: $line"
    done
}

# Start producer in background
producer &
producer_pid=$!

# Start consumer
consumer

# Clean up
wait $producer_pid
rm "$PIPE_NAME"



#!/bin/bash

# Log aggregator using named pipes
setup_log_aggregator() {
    local log_pipe="/tmp/log_aggregator"
    local output_file="/var/log/aggregated.log"
    
    mkfifo "$log_pipe"
    
    # Log processor running in background
    (
        while read log_entry < "$log_pipe"; do
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$timestamp] $log_entry" >> "$output_file"
        done
    ) &
    
    echo $! > /tmp/log_aggregator.pid
    echo "Log aggregator started. Pipe: $log_pipe"
}

# Function to send logs to aggregator
send_log() {
    local message="$1"
    local log_pipe="/tmp/log_aggregator"
    
    if [[ -p "$log_pipe" ]]; then
        echo "$message" > "$log_pipe"
    else
        echo "Log aggregator not running" >&2
    fi
}

# Usage examples
send_log "Application started"
send_log "ERROR: Database connection failed"
send_log "User login: john@example.com"


