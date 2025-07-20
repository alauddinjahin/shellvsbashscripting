#!/bin/bash

# Basic here string
grep "pattern" <<< "This is a test pattern string"

# With variables
text="Hello World"
tr '[:lower:]' '[:upper:]' <<< "$text"

# Multiple operations
result=$(tr '[:upper:]' '[:lower:]' <<< "$USER" | sed 's/./*/g')
echo "Masked user: $result"


# Validate email format
validate_email() {
    local email="$1"
    if grep -qE '^[^@]+@[^@]+\.[^@]+$' <<< "$email"; then
        echo "Valid email: $email"
    else
        echo "Invalid email: $email"
    fi
}

# Parse JSON with here string
parse_json() {
    local json_data='{"name":"John","age":30,"city":"New York"}'
    
    name=$(python3 -c "import json, sys; data=json.load(sys.stdin); print(data['name'])" <<< "$json_data")
    age=$(python3 -c "import json, sys; data=json.load(sys.stdin); print(data['age'])" <<< "$json_data")
    
    echo "Name: $name, Age: $age"
}

# Word count with here string
count_words() {
    local text="$1"
    local word_count=$(wc -w <<< "$text")
    echo "Word count: $word_count"
}


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