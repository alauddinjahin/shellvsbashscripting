#!/bin/bash
#  Security Considerations

# Input validation: Sanitizing user input
# Command injection prevention: Proper quoting
# File permissions: Secure file handling
# Temporary files: Safe temporary file creation


# Performance Optimization

# Efficient loops: Avoiding unnecessary iterations
# Command substitution: $(command) vs backticks
# Built-in commands: Using bash built-ins vs external commands
# Memory management: Handling large files efficiently


# Function to validate email format
validate_email() {
    local email="$1"
    local regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if [[ $email =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}


# Function to sanitize filename input
sanitize_filename() {
    local filename="$1"
    # Remove dangerous characters and paths
    filename="${filename//[^a-zA-Z0-9._-]/}"  # Keep only safe chars
    filename="${filename#.}"                   # Remove leading dot
    filename="${filename%.}"                   # Remove trailing dot
    
    # Ensure filename isn't empty after sanitization
    if [[ -z "$filename" ]]; then
        filename="safe_default_name"
    fi
    
    echo "$filename"
}


# Function to validate numeric input
validate_number() {
    local input="$1"
    local min="$2"
    local max="$3"
    
    # Check if input is a number
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "Error: '$input' is not a valid number" >&2
        return 1
    fi
    
    # Check range if specified
    if [[ -n "$min" && "$input" -lt "$min" ]]; then
        echo "Error: Number must be >= $min" >&2
        return 1
    fi
    
    if [[ -n "$max" && "$input" -gt "$max" ]]; then
        echo "Error: Number must be <= $max" >&2
        return 1
    fi
    
    return 0
}


# Example usage
echo "=== Input Validation Examples ==="

# Email validation
read -p "Enter email address: " user_email
if validate_email "$user_email"; then
    echo "Valid email: $user_email"
else
    echo "Invalid email format"
fi

# Filename sanitization
read -p "Enter filename: " user_filename
safe_filename=$(sanitize_filename "$user_filename")
echo "Original: '$user_filename' -> Sanitized: '$safe_filename'"

# Number validation
read -p "Enter age (1-120): " user_age
if validate_number "$user_age" 1 120; then
    echo "Valid age: $user_age"
else
    echo "Invalid age"
fi



#!/bin/bash
# command_injection_prevention.sh

# UNSAFE: Don't do this - vulnerable to command injection
unsafe_file_search() {
    local search_term="$1"
    # This is dangerous if search_term contains special characters
    eval "find . -name *$search_term*"  # NEVER use eval with user input
}

# SAFE: Proper quoting and parameter handling
safe_file_search() {
    local search_term="$1"
    
    # Validate input first
    if [[ -z "$search_term" ]]; then
        echo "Error: Search term cannot be empty" >&2
        return 1
    fi
    
    # Use proper quoting - variables are safely expanded
    find . -name "*${search_term}*" 2>/dev/null
}

# SAFE: Using arrays for command construction
safe_command_builder() {
    local file="$1"
    local options=("$@")  # All arguments as array
    
    # Build command safely using array
    local cmd=("grep" "-n")
    cmd+=("${options[@]:1}")  # Add options from second argument onward
    cmd+=("$file")
    
    # Execute safely
    "${cmd[@]}"
}

# Function to safely handle user paths
safe_path_handler() {
    local user_path="$1"
    
    # Validate path doesn't contain dangerous patterns
    if [[ "$user_path" =~ \.\./|\$\(|\`|\| ]]; then
        echo "Error: Path contains unsafe characters" >&2
        return 1
    fi
    
    # Resolve to absolute path safely
    local abs_path
    abs_path=$(realpath "$user_path" 2>/dev/null) || {
        echo "Error: Invalid path" >&2
        return 1
    }
    
    # Ensure path is within allowed directory
    local allowed_base="/home/user/safe_area"
    if [[ "$abs_path" != "$allowed_base"* ]]; then
        echo "Error: Path outside allowed area" >&2
        return 1
    fi
    
    echo "$abs_path"
}

# Examples of proper quoting
echo "=== Command Injection Prevention Examples ==="

# Safe variable usage in commands
filename="test file with spaces.txt"
touch "$filename"  # Proper quoting handles spaces

# Safe command substitution
current_date=$(date "+%Y-%m-%d")  # Use $() not backticks
echo "Today is: $current_date"

# Safe array usage
files=("file1.txt" "file with spaces.txt" "file-3.txt")
for file in "${files[@]}"; do  # Proper array iteration
    echo "Processing: $file"
done

# Cleanup
rm -f "$filename"


#!/bin/bash
# secure_file_handling.sh

# Function to create file with secure permissions
create_secure_file() {
    local filename="$1"
    local content="$2"
    
    # Set restrictive umask before file creation
    local old_umask=$(umask)
    umask 077  # Only owner can read/write
    
    # Create file safely
    if ! touch "$filename"; then
        echo "Error: Cannot create file $filename" >&2
        umask "$old_umask"
        return 1
    fi
    
    # Write content
    echo "$content" > "$filename" || {
        echo "Error: Cannot write to file $filename" >&2
        rm -f "$filename"
        umask "$old_umask"
        return 1
    }
    
    # Restore original umask
    umask "$old_umask"
    
    echo "Secure file created: $filename"
    ls -la "$filename"
}

# Function to verify file permissions
check_file_permissions() {
    local file="$1"
    local required_perms="$2"  # e.g., "600" for owner read/write only
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File $file does not exist" >&2
        return 1
    fi
    
    # Get current permissions
    local current_perms
    current_perms=$(stat -c "%a" "$file" 2>/dev/null) || {
        echo "Error: Cannot read permissions for $file" >&2
        return 1
    }
    
    if [[ "$current_perms" != "$required_perms" ]]; then
        echo "Warning: File $file has permissions $current_perms, expected $required_perms"
        return 1
    fi
    
    echo "File $file has correct permissions: $current_perms"
    return 0
}

# Function to safely copy files with permission preservation
secure_file_copy() {
    local src="$1"
    local dest="$2"
    
    # Validate source file
    if [[ ! -f "$src" ]]; then
        echo "Error: Source file $src does not exist" >&2
        return 1
    fi
    
    # Check if destination directory is writable
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -w "$dest_dir" ]]; then
        echo "Error: Destination directory $dest_dir is not writable" >&2
        return 1
    fi
    
    # Copy with permission preservation
    if cp -p "$src" "$dest"; then
        echo "Successfully copied $src to $dest"
        echo "Source permissions:"
        ls -la "$src"
        echo "Destination permissions:"
        ls -la "$dest"
    else
        echo "Error: Failed to copy $src to $dest" >&2
        return 1
    fi
}

# Function to handle sensitive configuration files
secure_config_handler() {
    local config_file="$1"
    
    # Create config directory with restricted permissions
    local config_dir="$HOME/.myapp"
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        chmod 700 "$config_dir"  # Only owner can access
        echo "Created secure config directory: $config_dir"
    fi
    
    local full_path="$config_dir/$config_file"
    
    # Create config file with secure permissions
    create_secure_file "$full_path" "# Secure configuration file
database_password=secret123
api_key=abc123xyz
admin_token=super_secret_token"
    
    # Verify permissions
    check_file_permissions "$full_path" "600"
}

echo "=== Secure File Handling Examples ==="

# Example usage
secure_config_handler "app.conf"

# Create a test file and copy it securely
echo "This is test content" > test_source.txt
chmod 644 test_source.txt
secure_file_copy "test_source.txt" "test_destination.txt"

# Cleanup
rm -f test_source.txt test_destination.txt


#!/bin/bash
# safe_temp_files.sh

# Function to create secure temporary file
create_secure_temp() {
    local temp_prefix="${1:-myapp}"
    local temp_dir="${TMPDIR:-/tmp}"
    
    # Create secure temporary file
    local temp_file
    temp_file=$(mktemp "$temp_dir/${temp_prefix}.XXXXXX") || {
        echo "Error: Cannot create temporary file" >&2
        return 1
    }
    
    # Set restrictive permissions
    chmod 600 "$temp_file" || {
        echo "Error: Cannot set permissions on $temp_file" >&2
        rm -f "$temp_file"
        return 1
    }
    
    echo "$temp_file"
}

# Function to create secure temporary directory
create_secure_temp_dir() {
    local temp_prefix="${1:-myapp_dir}"
    local temp_dir="${TMPDIR:-/tmp}"
    
    # Create secure temporary directory
    local temp_directory
    temp_directory=$(mktemp -d "$temp_dir/${temp_prefix}.XXXXXX") || {
        echo "Error: Cannot create temporary directory" >&2
        return 1
    }
    
    # Set restrictive permissions
    chmod 700 "$temp_directory" || {
        echo "Error: Cannot set permissions on $temp_directory" >&2
        rm -rf "$temp_directory"
        return 1
    }
    
    echo "$temp_directory"
}

# Function with automatic cleanup
temp_file_processor() {
    local data="$1"
    
    # Create temp file with automatic cleanup
    local temp_file
    temp_file=$(create_secure_temp "processor") || return 1
    
    # Set up cleanup trap
    trap "rm -f '$temp_file'" EXIT ERR INT TERM
    
    # Process data using temp file
    echo "$data" > "$temp_file"
    
    # Simulate processing
    echo "Processing data in secure temp file: $temp_file"
    echo "Data size: $(wc -c < "$temp_file") bytes"
    
    # Transform data
    tr '[:lower:]' '[:upper:]' < "$temp_file" > "${temp_file}.processed"
    
    # Show result
    echo "Processed result:"
    cat "${temp_file}.processed"
    
    # Cleanup happens automatically via trap
    rm -f "${temp_file}.processed"
}

# Function for working with temporary directories
temp_workspace_example() {
    # Create secure workspace
    local workspace
    workspace=$(create_secure_temp_dir "workspace") || return 1
    
    # Set up cleanup
    trap "rm -rf '$workspace'" EXIT ERR INT TERM
    
    echo "Working in secure temporary directory: $workspace"
    
    # Create some files in workspace
    echo "File 1 content" > "$workspace/file1.txt"
    echo "File 2 content" > "$workspace/file2.txt"
    mkdir "$workspace/subdir"
    echo "Subfile content" > "$workspace/subdir/subfile.txt"
    
    # Show workspace contents
    echo "Workspace contents:"
    find "$workspace" -type f -exec ls -la {} \;
    
    # Process files
    local file_count
    file_count=$(find "$workspace" -type f | wc -l)
    echo "Created $file_count files in workspace"
    
    # Cleanup happens automatically
}

# Advanced: Named pipe (FIFO) handling
secure_named_pipe() {
    local pipe_name="$1"
    local temp_dir
    temp_dir=$(create_secure_temp_dir "pipes") || return 1
    
    local pipe_path="$temp_dir/$pipe_name"
    
    # Set up cleanup
    trap "rm -rf '$temp_dir'" EXIT ERR INT TERM
    
    # Create named pipe
    if mkfifo "$pipe_path"; then
        chmod 600 "$pipe_path"
        echo "Created secure named pipe: $pipe_path"
        
        # Example usage (in background)
        echo "Hello through pipe" > "$pipe_path" &
        
        # Read from pipe
        echo "Reading from pipe:"
        timeout 2 cat "$pipe_path"
        
        wait  # Wait for background process
    else
        echo "Error: Cannot create named pipe" >&2
        return 1
    fi
}

echo "=== Safe Temporary File Examples ==="

# Example 1: Basic temp file usage
echo "Example 1: Basic temporary file"
temp_file=$(create_secure_temp "example")
echo "Created temp file: $temp_file"
echo "Hello, secure temp file!" > "$temp_file"
cat "$temp_file"
rm -f "$temp_file"

echo -e "\nExample 2: Temp file processing with cleanup"
temp_file_processor "Hello World! This is test data for processing."

echo -e "\nExample 3: Temporary workspace"
temp_workspace_example

echo -e "\nExample 4: Secure named pipe"
secure_named_pipe "test_pipe"


#!/bin/bash
# efficient_loops.sh

# INEFFICIENT: Reading file line by line with external commands
inefficient_file_processing() {
    local file="$1"
    local count=0
    
    echo "=== Inefficient Method ==="
    time {
        while read -r line; do
            # Using external command for each line (slow)
            if echo "$line" | grep -q "pattern"; then
                ((count++))
            fi
        done < "$file"
        echo "Found $count matches (inefficient method)"
    }
}

# EFFICIENT: Using built-in pattern matching
efficient_file_processing() {
    local file="$1"
    local count=0
    
    echo "=== Efficient Method ==="
    time {
        while read -r line; do
            # Using bash built-in pattern matching (fast)
            if [[ "$line" == *"pattern"* ]]; then
                ((count++))
            fi
        done < "$file"
        echo "Found $count matches (efficient method)"
    }
}

# MOST EFFICIENT: Single command processing
most_efficient_file_processing() {
    local file="$1"
    
    echo "=== Most Efficient Method ==="
    time {
        local count
        count=$(grep -c "pattern" "$file" 2>/dev/null || echo 0)
        echo "Found $count matches (most efficient method)"
    }
}

# Efficient array processing
efficient_array_operations() {
    echo "=== Efficient Array Operations ==="
    
    # Create large array for testing
    local large_array=()
    for i in {1..10000}; do
        large_array+=("item_$i")
    done
    
    # INEFFICIENT: Using external command in loop
    echo "Inefficient array processing:"
    time {
        local count=0
        for item in "${large_array[@]}"; do
            if echo "$item" | grep -q "_5"; then
                ((count++))
            fi
        done
        echo "Found $count items with '_5'"
    }
    
    # EFFICIENT: Using built-in pattern matching
    echo "Efficient array processing:"
    time {
        local count=0
        for item in "${large_array[@]}"; do
            if [[ "$item" == *"_5"* ]]; then
                ((count++))
            fi
        done
        echo "Found $count items with '_5'"
    }
}

# Loop optimization techniques
loop_optimization_examples() {
    echo "=== Loop Optimization Examples ==="
    
    # Technique 1: Break early when possible
    early_break_example() {
        local target="$1"
        local array=("apple" "banana" "cherry" "date" "elderberry")
        
        echo "Searching for '$target':"
        for i in "${!array[@]}"; do
            echo "  Checking: ${array[i]}"
            if [[ "${array[i]}" == "$target" ]]; then
                echo "  Found at index $i!"
                return 0  # Early exit
            fi
        done
        echo "  Not found"
        return 1
    }
    
    # Technique 2: Use appropriate loop construct
    range_loops() {
        echo "Range loop examples:"
        
        # C-style loop for numeric ranges with step
        echo "C-style loop (with step):"
        time {
            for ((i=0; i<=1000; i+=10)); do
                : # Do nothing, just count
            done
            echo "Processed with step of 10"
        }
        
        # Brace expansion for simple ranges
        echo "Brace expansion:"
        time {
            for i in {0..1000..10}; do
                : # Do nothing, just count
            done
            echo "Processed with brace expansion"
        }
    }
    
    # Technique 3: Minimize operations inside loops
    optimized_calculations() {
        local numbers=($(seq 1 1000))
        
        echo "Calculation optimization:"
        
        # INEFFICIENT: Recalculating constant inside loop
        echo "Inefficient (recalculating):"
        time {
            local sum=0
            for num in "${numbers[@]}"; do
                local multiplier=$((10 * 5))  # Calculated each iteration
                sum=$((sum + num * multiplier))
            done
            echo "Sum: $sum"
        }
        
        # EFFICIENT: Calculate constant outside loop
        echo "Efficient (precalculated):"
        time {
            local multiplier=$((10 * 5))  # Calculated once
            local sum=0
            for num in "${numbers[@]}"; do
                sum=$((sum + num * multiplier))
            done
            echo "Sum: $sum"
        }
    }
    
    early_break_example "cherry"
    range_loops
    optimized_calculations
}

# Create test file for demonstration
create_test_file() {
    local test_file="test_data.txt"
    {
        for i in {1..1000}; do
            if ((i % 100 == 0)); then
                echo "Line $i contains pattern"
            else
                echo "Line $i without match"
            fi
        done
    } > "$test_file"
    echo "$test_file"
}

# Main execution
echo "Creating test file..."
test_file=$(create_test_file)

echo -e "\nTesting file processing methods:"
inefficient_file_processing "$test_file"
efficient_file_processing "$test_file"
most_efficient_file_processing "$test_file"

echo -e "\nTesting array operations:"
efficient_array_operations

echo -e "\nTesting loop optimizations:"
loop_optimization_examples

# Cleanup
rm -f "$test_file"




#!/bin/bash
# command_substitution_optimization.sh

# Performance comparison: $() vs backticks
compare_substitution_methods() {
    echo "=== Command Substitution Comparison ==="
    
    # Method 1: Backticks (old style, avoid)
    echo "Backtick method:"
    time {
        for i in {1..100}; do
            result=`date +%s`
        done
        echo "Last result: $result"
    }
    
    # Method 2: $() (modern, preferred)
    echo "$() method:"
    time {
        for i in {1..100}; do
            result=$(date +%s)
        done
        echo "Last result: $result"
    }
}

# Efficient command substitution patterns
efficient_substitution_patterns() {
    echo "=== Efficient Substitution Patterns ==="
    
    # Pattern 1: Avoid repeated command substitution
    echo "Inefficient (repeated substitution):"
    time {
        for i in {1..50}; do
            if [[ $(date +%H) -gt 12 ]]; then
                echo "Afternoon: $(date +%H)"
            fi
        done > /dev/null
    }
    
    echo "Efficient (cached substitution):"
    time {
        local current_hour
        current_hour=$(date +%H)
        for i in {1..50}; do
            if [[ $current_hour -gt 12 ]]; then
                echo "Afternoon: $current_hour"
            fi
        done > /dev/null
    }
    
    # Pattern 2: Combining multiple commands
    echo -e "\nCombining commands efficiently:"
    
    # INEFFICIENT: Multiple separate command substitutions
    echo "Separate commands:"
    time {
        local user_name
        local user_home
        local user_shell
        user_name=$(whoami)
        user_home=$(echo ~)
        user_shell=$(echo $SHELL)
        echo "User: $user_name, Home: $user_home, Shell: $user_shell" > /dev/null
    }
    
    # EFFICIENT: Single command with multiple outputs
    echo "Combined command:"
    time {
        local user_info
        user_info=$(echo "$(whoami):$(echo ~):$SHELL")
        IFS=':' read -r user_name user_home user_shell <<< "$user_info"
        echo "User: $user_name, Home: $user_home, Shell: $user_shell" > /dev/null
    }
}

# Advanced command substitution techniques
advanced_substitution_techniques() {
    echo "=== Advanced Substitution Techniques ==="
    
    # Technique 1: Nested command substitution
    nested_substitution_example() {
        echo "Nested command substitution:"
        
        # Find the most recent file in the most recently modified directory
        most_recent_file=$(find $(ls -td */ | head -1) -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
        
        if [[ -n "$most_recent_file" ]]; then
            echo "Most recent file: $most_recent_file"
        else
            echo "No files found"
        fi
    }
    
    # Technique 2: Command substitution with error handling
    safe_substitution_example() {
        echo "Safe command substitution:"
        
        local git_branch
        if git_branch=$(git branch --show-current 2>/dev/null); then
            echo "Current Git branch: $git_branch"
        else
            echo "Not in a Git repository or Git not available"
        fi
        
        local system_load
        if system_load=$(uptime | awk -F'load average:' '{print $2}' 2>/dev/null); then
            echo "System load:$system_load"
        else
            echo "Cannot determine system load"
        fi
    }
    
    # Technique 3: Command substitution with arrays
    array_substitution_example() {
        echo "Command substitution with arrays:"
        
        # Convert command output to array
        local files_array
        mapfile -t files_array < <(find /etc -maxdepth 1 -type f -name "*.conf" 2>/dev/null)
        
        echo "Found ${#files_array[@]} .conf files in /etc:"
        for file in "${files_array[@]}"; do
            echo "  $(basename "$file")"
        done | head -5  # Show only first 5
    }
    
    # Technique 4: Process substitution (related but different)
    process_substitution_example() {
        echo "Process substitution examples:"
        
        # Compare two command outputs
        if command -v diff >/dev/null 2>&1; then
            echo "Comparing directory listings:"
            diff <(ls /etc | sort) <(ls /usr/bin | sort) | head -5
        fi
        
        # Multiple input sources
        echo "Reading multiple sources:"
        while read -r line; do
            echo "Line: $line"
        done < <(echo -e "Line 1\nLine 2\nLine 3")
    }
    
    nested_substitution_example
    safe_substitution_example
    array_substitution_example
    process_substitution_example
}

# Performance tips for command substitution
performance_tips() {
    echo "=== Performance Tips ==="
    
    # Tip 1: Use built-in variables when possible
    echo "Using built-in variables:"
    echo "Current directory (PWD): $PWD"
    echo "Home directory (HOME): $HOME"
    echo "User (USER): $USER"
    echo "Shell (SHELL): $SHELL"
    # Instead of: $(pwd), $(echo ~), $(whoami), etc.
    
    # Tip 2: Cache expensive operations
    echo -e "\nCaching expensive operations:"
    
    # Cache file count for multiple uses
    local file_count
    file_count=$(find /usr/bin -type f | wc -l)
    echo "Found $file_count files in /usr/bin"
    echo "Processing $file_count files..."
    
    # Tip 3: Use appropriate tools
    echo -e "\nUsing appropriate tools:"
    
    # For text processing, awk is often faster than multiple commands
    local cpu_info
    cpu_info=$(awk '/^processor/ {cores++} /^model name/ {if(!model) model=$0} END {print cores " cores, " model}' /proc/cpuinfo 2>/dev/null || echo "CPU info not available")
    echo "CPU: $cpu_info"
}

# Main execution
compare_substitution_methods
echo
efficient_substitution_patterns
echo
advanced_substitution_techniques
echo
performance_tips



#!/bin/bash
# builtin_commands_optimization.sh

# Performance comparison: built-ins vs external commands
compare_builtins_vs_external() {
    echo "=== Built-ins vs External Commands Performance ==="
    
    local test_file="performance_test.txt"
    
    # Create test file
    for i in {1..1000}; do
        echo "Line $i with some test content" >> "$test_file"
    done
    
    # Test 1: String length
    local test_string="This is a test string for length measurement"
    
    echo "String length comparison:"
    echo "Built-in method:"
    time {
        for i in {1..1000}; do
            length=${#test_string}  # Built-in parameter expansion
        done
        echo "Length: $length"
    }
    
    echo "External command method:"
    time {
        for i in {1..1000}; do
            length=$(echo "$test_string" | wc -c)  # External wc command
        done
        echo "Length: $((length - 1))"  # wc counts newline
    }
    
    # Test 2: Variable modification
    echo -e "\nVariable modification comparison:"
    local test_var="  hello world  "
    
    echo "Built-in parameter expansion:"
    time {
        for i in {1..1000}; do
            # Remove leading/trailing whitespace using parameter expansion
            trimmed="${test_var#"${test_var%%[![:space:]]*}"}"
            trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        done
        echo "Trimmed: '$trimmed'"
    }
    
    echo "External commands:"
    time {
        for i in {1..1000}; do
            trimmed=$(echo "$test_var" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        done
        echo "Trimmed: '$trimmed'"
    }
    
    # Cleanup
    rm -f "$test_file"
}

# Built-in command reference and examples
builtin_command_examples() {
    echo "=== Built-in Command Examples ==="
    
    # String manipulation built-ins
    echo "String manipulation:"
    local original="Hello World Example"
    
    echo "Original: $original"
    echo "Lowercase: ${original,,}"          # Convert to lowercase
    echo "Uppercase: ${original^^}"          # Convert to uppercase
    echo "Length: ${#original}"              # String length
    echo "Substring: ${original:6:5}"        # Extract "World"
    echo "Replace: ${original/World/Bash}"   # Replace first occurrence
    echo "Replace all: ${original//l/L}"     # Replace all occurrences
    
    # Array operations (built-in)
    echo -e "\nArray operations:"
    local fruits=("apple" "banana" "cherry" "date")
    
    echo "Array: ${fruits[*]}"
    echo "Length: ${#fruits[@]}"
    echo "First element: ${fruits[0]}"
    echo "Last element: ${fruits[-1]}"
    echo "Slice: ${fruits[@]:1:2}"          # Elements 1-2
    
    # Arithmetic operations (built-in)
    echo -e "\nArithmetic operations:"
    local a=10 b=5
    
    echo "a=$a, b=$b"
    echo "Addition: $((a + b))"
    echo "Subtraction: $((a - b))"
    echo "Multiplication: $((a * b))"
    echo "Division: $((a / b))"
    echo "Modulo: $((a % b))"
    echo "Power: $((a ** 2))"
    
    # Pattern matching (built-in)
    echo -e "\nPattern matching:"
    local filename="document.pdf"
    
    if [[ "$filename" == *.pdf ]]; then
        echo "$filename is a PDF file"
    fi
    
    case "$filename" in
        *.txt)  echo "Text file";;
    esac

}