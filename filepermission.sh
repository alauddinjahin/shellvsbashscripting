
# ## What This Command Does
# ```bash
# chmod +r readonly.sh
# ```
# - **Adds read permission** (+r) for all users (owner, group, others)
# - **Does not affect** write or execute permissions
# - **Will work** if you're the file owner or root

# ## Potential Issues
# 1. **If the file is truly read-only**:
#    - Some systems set immutable flags (`chattr +i` in Linux)
#    - In this case, `chmod` won't work until you remove the immutable flag:
#      ```bash
#      sudo chattr -i readonly.sh
#      chmod +r readonly.sh
#      ```

# 2. **If you're not the owner**:
#    - Regular users can't change permissions of files they don't own
#    - Requires sudo:
#      ```bash
#      sudo chmod +r readonly.sh
#      ```

# ## Better Alternatives

# 1. **To make a file readable and also ensure it's writable**:
#    ```bash
#    chmod u+rw readonly.sh  # Give owner read+write
#    ```

# 2. **To make completely readable by everyone**:
#    ```bash
#    chmod a+r readonly.sh  # Explicitly set for all (a)ll users
#    ```

# 3. **To verify current permissions first**:
#    ```bash
#    ls -l readonly.sh  # Check current permissions
#    stat readonly.sh  # More detailed info
#    ```

# ## When You Might Need More
# ```bash
# # If you need to remove write-protection:
# chmod -w readonly.sh  # Remove write permission for all

# # If you need to reset to default:
# chmod 644 readonly.sh  # Common default for regular files
# ```

# Key Notes:
# - `+r` alone doesn't remove existing write protections
# - The command is safe to run (won't damage files)
# - May not work if there are deeper permission restrictions



# File Descriptors
# File descriptors are integer handles that represent open files or data streams. Every process starts with three standard file descriptors:

# 0 (stdin): Standard input
# 1 (stdout): Standard output
# 2 (stderr): Standard error


# Redirect stdout to file
echo "Hello World" > output.txt

# Redirect stderr to file
ls /nonexistent 2> error.log

# Redirect both stdout and stderr
command > output.txt 2>&1
# or using newer syntax
command &> output.txt

# Redirect stderr to stdout
command 2>&1

# Discard output
command > /dev/null 2>&1




# Open file descriptor 3 for writing
exec 3> logfile.txt

# Write to file descriptor 3
echo "Log entry 1" >&3
echo "Log entry 2" >&3

# Close file descriptor 3
exec 3>&-


# Open file descriptor 4 for reading
exec 4< logfile.txt

# Read from file descriptor 4
while read -u 4 line; do  # -u 4 tells read to get input from file descriptor 4 # -u is superior for complex file handling.
    echo "Read: $line"
done

# Close file descriptor 4
exec 4<&-


# # Duplicate file descriptors
# exec 3>&1    # Save stdout to fd 3
# exec 1>log   # Redirect stdout to file

# echo "This goes to log file"
# echo "This also goes to log" >&1
# echo "This goes to original stdout" >&3

# exec 1>&3    # Restore stdout
# exec 3>&-    # Close fd 3

# Using file descriptors for input/output separation
function process_data() {
    local input_fd=3
    local output_fd=4
    
    exec 3< "$1"    # Open input file
    exec 4> "$2"    # Open output file
    
    while read -u $input_fd line; do
        echo "Processed: $line" >&$output_fd
    done
    
    exec 3<&-       # Close input fd
    exec 4>&-       # Close output fd
}


