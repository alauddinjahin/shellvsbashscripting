# Method 1: while read loop (preferred)
while IFS= read -r line; do
    echo "Processing: $line"
done < file.txt

# Method 2: for loop with command substitution
for line in $(cat file.txt); do
    echo "Line: $line"
done  # Note: breaks on whitespace, not recommended for complex data

# Method 3: using file descriptor
exec 3< file.txt
while IFS= read -r line <&3; do
    echo "Read: $line"
done
exec 3<&-  # Close file descriptor

# exec: Bash builtin that executes commands in the current shell environment
# 3<: Opens file.txt for reading and assigns it to file descriptor 3

# File descriptors:
# 0 = stdin (standard input)
# 1 = stdout (standard output)
# 2 = stderr (standard error)
# 3-9 = available for custom use
# This makes the file available for reading through FD 3 without using pipes/subshells


# Read first line
first_line=$(head -n 1 file.txt)

# Read last line
last_line=$(tail -n 1 file.txt)

# Read line by line with line numbers
while IFS= read -r line; do
    echo "Line $((++count)): $line"
done < file.txt

# Skip header line
{ read header; while IFS= read -r line; do
    process_line "$line"
done; } < data.csv



# Overwrite (truncate and write)
echo "New content" > file.txt
printf "Formatted: %s\n" "$variable" > output.txt

# Append (add to end)
echo "Additional content" >> file.txt
date >> logfile.txt

# Writing multiple lines
cat > config.txt << EOF
server=localhost
port=8080
debug=true
EOF

# Append multiple lines
cat >> config.txt << 'EOF'
# Additional settings
timeout=30
retries=3
EOF




# Variable	Meaning	Example Use Case
# $$	Current shell PID	Unique temp files
# $!	Last background process PID	Tracking async processes
# $?	Exit status of last command	Error handling
# $0	Name of the script	Usage messages
# $#	Number of arguments	Input validation


# Atomic writing (write to temp, then move)
write_safely() {
    local target="$1"
    local temp="${target}.tmp.$$"

    # target="data.csv"
    # temp="${target}.tmp.$$" # $$ = PID
    # echo "$temp"  # Outputs: "data.csv.tmp.12345" (where 12345 is the PID)
    
    cat > "$temp" && mv "$temp" "$target"
}

# Write to multiple files simultaneously
echo "Logged at $(date)" | tee -a log1.txt log2.txt log3.txt



# Basic copy
cp source.txt destination.txt
cp file.txt /path/to/directory/

# Copy with options
cp -r directory/ backup/           # Recursive (for directories)
cp -p file.txt backup/             # Preserve permissions/timestamps
cp -u source.txt dest.txt          # Update only if source is newer
cp -i file.txt existing.txt        # Interactive (ask before overwrite)

# Copy multiple files
cp file1.txt file2.txt file3.txt /destination/
cp *.txt /backup/


# Basic move/rename
mv oldname.txt newname.txt
mv file.txt /new/location/

# Move multiple files
mv *.log /var/log/archive/
mv file1.txt file2.txt directory/

# Safe move with backup
mv file.txt file.txt.bak && mv newfile.txt file.txt


# Remove files
rm file.txt
rm -f file.txt                     # Force remove (no prompts)
rm -i *.txt                        # Interactive removal

# Remove directories
rmdir empty_directory              # Remove empty directory only
rm -r directory/                   # Remove directory and contents
rm -rf directory/                  # Force recursive removal

# Safe deletion function
safe_delete() {
    local file="$1"
    if [[ -f "$file" ]]; then
        mv "$file" "$file.deleted.$(date +%s)"
        echo "Moved $file to trash"
    fi
}

# Create single directory
mkdir new_directory

# Create nested directories
mkdir -p path/to/nested/directory

# Create with specific permissions
mkdir -m 755 public_dir
# Without -m, permissions are 777 - umask.
# The -m flag:
# Overrides umask to ensure exact permissions.
# Improves security by restricting access (e.g., 750 for private directories).


# Create multiple directories
mkdir dir1 dir2 dir3
mkdir -p project/{src,tests,docs,config}


# Basic listing
ls
ls -l                              # Long format
ls -la                             # Include hidden files
ls -lh                             # Human readable sizes
ls -lt                             # Sort by modification time
ls -lS                             # Sort by size

# Advanced listing
find . -type f -name "*.txt"       # Find all .txt files
find . -type d                     # Find all directories
ls -1                              # One file per line


# Method 3: recursive function
traverse_directory() {
    local dir="$1"
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            echo "Entering directory: $item"
            traverse_directory "$item"  # Recursive call
        elif [[ -f "$item" ]]; then
            echo "Processing file: $item"
        fi
    done
}


# Method 4: while with find
while IFS= read -r -d '' file; do
    echo "Found: $file"
done < <(find . -type f -print0)



#!/bin/bash
backup_files() {
    local source="$1"
    local backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    
    mkdir -p "$backup_dir"
    
    for file in "$source"/*.txt; do
        if [[ -f "$file" ]]; then
            cp -p "$file" "$backup_dir/"
            echo "Backed up: $(basename "$file")"
        fi
    done
    
    echo "Backup completed in: $backup_dir"
}


rotate_logs() {
    local logfile="$1"
    local max_size=${2:-10485760}  # 10MB default
    
    if [[ -f "$logfile" ]] && [[ $(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile") -gt $max_size ]]; then
        mv "$logfile" "$logfile.$(date +%Y%m%d)"
        touch "$logfile"
        echo "Rotated $logfile"
    fi
}


sync_directories() {
    local source="$1"
    local target="$2"
    
    # Create target if it doesn't exist
    mkdir -p "$target"
    
    # Copy new and updated files
    for file in "$source"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            if [[ ! -f "$target/$filename" ]] || [[ "$file" -nt "$target/$filename" ]]; then # -nt stands for "newer than".
                cp -p "$file" "$target/"
                echo "Synced: $filename"
            fi
        fi
    done
}


process_data_files() {
    local input_dir="$1"
    local output_dir="$2"
    
    mkdir -p "$output_dir"
    
    find "$input_dir" -name "*.csv" -type f | while IFS= read -r file; do
        filename=$(basename "$file" .csv)
        
        # Process CSV: remove empty lines, sort by first column
        grep -v '^$' "$file" | sort -t, -k1,1 > "$output_dir/${filename}_processed.csv"
        
        echo "Processed: $filename"
    done
    
    echo "Processing complete. Results in: $output_dir"
}