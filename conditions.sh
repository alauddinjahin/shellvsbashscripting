#!/bin/bash

# declare -i age

# if [ $age -ge 18 ]; then
#     echo "Adult"
# else
#     echo "Minor"
# fi

# read -p "Enter your age: " age

#short version
# [ $age -ge 18 ] && echo "You're adult" || echo "You're minor"


# declare -i score
# read -p "Enter Your Number: " score

# if [ $score -ge 90 ]; then
#     echo "Grade: A"
# elif [ $score -ge 80 ]; then
#     echo "Grade: B"
# elif [ $score -ge 70 ]; then
#     echo "Grade: C"
# elif [ $score -ge 60 ]; then
#     echo "Grade: D"
# else
#     echo "Grade: F"
# fi



# Multiple elif example with different conditions
# user_input="admin"
# if [ "$user_input" = "admin" ]; then
#     echo "Administrator access granted"
# elif [ "$user_input" = "user" ]; then
#     echo "User access granted"
# elif [ "$user_input" = "guest" ]; then
#     echo "Guest access granted"
# else
#     echo "Access denied"
# fi

# set -x



# num1=10
# num2=101

# Equal to
# [ $num1 -eq $num2 ] && echo "$num1 equals $num2" &> err.log

# (( num1 == num2 )) && echo "$num1 equals $num2" 2> err.log
# (( num1 == num2 )) && echo "$num1 equals $num2" 2> err.log

# [ "$num1" -eq "$num2" ] && echo "$num1 equals $num2" >&2 err.log


# if [ $num1 -eq $num2 ]; then
#     echo "$num1 equals $num2"
# else
#     echo "$num1 does not equal $num2" >&2  # Print to stderr
# fi > output.log 2> err.log



# Not equal to
# if [ $num1 -ne $num2 ]; then
#     echo "$num1 does not equal $num2"
# fi

# # Greater than
# if [ $num2 -gt $num1 ]; then
#     echo "$num2 is greater than $num1"
# fi

# # Less than
# if [ $num1 -lt $num2 ]; then
#     echo "$num1 is less than $num2"
# fi

# # Greater than or equal to
# if [ $num2 -ge $num1 ]; then
#     echo "$num2 is greater than or equal to $num1"
# fi

# # Less than or equal to
# if [ $num1 -le $num2 ]; then
#     echo "$num1 is less than or equal to $num2"
# fi


# Traditional test syntax
# if [ "$num2" -ge "$num1" ]; then
#     echo "$num2 is greater than or equal to $num1"
# fi

# Arithmetic syntax (preferred for numbers)
# if (( num2 >= num1 )); then
#     echo "$num2 is greater than or equal to $num1"
# fi


# Range checking
# temperature=75
# if [ $temperature -ge 70 ] && [ $temperature -le 80 ]; then
#     echo "Perfect temperature!"
# fi



# name="Alice"
# password=""
# input="hello"

# # String equality
# if [ "$name" = "Alice" ]; then
#     echo "Welcome Alice!"
# fi

# # String inequality
# if [ "$input" != "quit" ]; then
#     echo "Continue processing..."
# fi

# # Empty string check (-z: zero length)
# if [ -z "$password" ]; then
#     echo "Password is empty"
# fi

# # Non-empty string check (-n: non-zero length)
# if [ -n "$name" ]; then
#     echo "Name is provided: $name"
# fi

# Practical examples
# read -p "Enter username: " username
# read -s -p "Enter password: " password
# echo

# if [ -z "$username" ]; then
#     echo "Error: Username cannot be empty"
# elif [ -z "$password" ]; then
#     echo "Error: Password cannot be empty"
# elif [ "$username" = "admin" ] && [ "$password" = "secret" ]; then
#     echo "Login successful"
# else
#     echo "Invalid credentials"
# fi

# Case-insensitive comparison
# user_choice="YES"
# if [ "${user_choice,,}" = "yes" ]; then  # Convert to lowercase
#     echo "User confirmed: ${user_choice,,}"
# fi


# Explanation of Parameter Expansion:
# ${var,,} - Converts entire string to lowercase

# echo "${user_choice,,}"  # Output: "yes"
# ${var^} - Capitalizes first character only

# echo "${user_choice^}"   # Output: "Yes"
# ${var^^} - Converts entire string to uppercase

# echo "${user_choice^^}"  # Output: "YES"



# user_choice="yEs"

# Convert to lowercase for comparison
# if [ "${user_choice,,}" = "yes" ]; then
#     echo "Original: $user_choice"
#     echo "Lowercase: ${user_choice,,}"
#     echo "Capitalized: ${user_choice^}"
#     echo "Uppercase: ${user_choice^^}"
#     # capitalized=$(echo "${user_choice,,}" | tr '[:lower:]' '[:upper:]' <<< "${user_choice:0:1}") #upper first letter
#     # rest=${user_choice:1}
#     # echo $capitalized${rest,,} # then adjust

#     # lower=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]') # if upper then lower
#     # echo $lower
# fi


# user_choice="yEs"
# echo "${user_choice^^}"

# capitalized=$(echo "${user_choice}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')

# echo $capitalized

# user_choice="yes"
# first_char="${user_choice:0:1}"  # Get first character
# rest_chars="${user_choice:1}"    # Get remaining characters
# capitalized="${first_char^^}${rest_chars,,}"
# echo "$capitalized"  # Output: "Yes"

# capitalized=$(echo "$user_choice" | sed 's/.*/\u&/')
# echo $capitalized

# WC word
# echo "john-doe" | sed 's/\(^\|-\)\(.\)/\1\u\2/g' #Output: John-Doe



# # Pattern matching with wildcards
# filename="document.pdf"
# if [[ "$filename" == *.pdf ]]; then
#     echo "PDF file detected"
# fi

# # String length comparison
# message="Hello World"
# if [ ${#message} -gt 10 ]; then
#     echo "Long message"
# fi



# file="test.txt"
# directory="mydir"
# script="script.sh"

# # File exists (-e)
# if [ -e "$file" ]; then
#     echo "File exists"
# fi

# # Regular file (-f)
# if [ -f "$file" ]; then
#     echo "It's a regular file"
# fi

# # Directory (-d)
# if [ -d "$directory" ]; then
#     echo "It's a directory"
# fi

# # Readable (-r)
# if [ -r "$file" ]; then
#     echo "File is readable"
# fi

# # Writable (-w)
# if [ -w "$file" ]; then
#     echo "File is writable"
# fi

# # Executable (-x)
# if [ -x "$script" ]; then
#     echo "File is executable"
# fi

# # Practical file operations
# config_file="/etc/myapp.conf"

# if [ ! -f "$config_file" ]; then
#     echo "Error: Config file not found"
#     exit 1
# elif [ ! -r "$config_file" ]; then
#     echo "Error: Config file not readable"
#     exit 1
# else
#     echo "Loading configuration..."
#     source "$config_file"
# fi

# # Backup script example
# backup_dir="/backup"
# source_file="important.txt"

# if [ ! -d "$backup_dir" ]; then
#     echo "Creating backup directory..."
#     mkdir -p "$backup_dir"
# fi

# if [ -f "$source_file" ]; then
#     if [ -r "$source_file" ]; then
#         cp "$source_file" "$backup_dir/"
#         echo "Backup completed"
#     else
#         echo "Error: Cannot read source file"
#     fi
# else
#     echo "Error: Source file does not exist"
# fi


file1="file1.txt"
file2="file2.txt"

# File is not empty (-s)
# if [ -s "$file1" ]; then #-s check file hase content or not
#     echo "File has content"
# fi

# # File1 is newer than file2 (-nt)
# if [ "$file2" -nt "$file1" ]; then
#     echo "$file2 is newer than $file1"
# fi

# # File1 is older than file2 (-ot)
# if [ "$file1" -ot "$file2" ]; then
#     echo "original.txt is older than copy.txt"
# fi

# Same file (same device and inode) (-ef)

# Create test files
# echo "Same content" > file1.txt
# echo "Same content" > file2.txt
# ln file1.txt hardlink.txt  # Creates a hardlink

# # Tests
# [ "file1.txt" -ef "hardlink.txt" ] && echo "Hardlinked!"      # TRUE
# [ "file1.txt" -ef "file2.txt" ]    || echo "Different files"  # FALSE
# cmp -s "file1.txt" "file2.txt"     && echo "Same content"     # TRUE

# if [ "$file1" -ef "$file2" ]; then
#     echo "Files are the same"
# fi

# compare both file contents are same or not
# if cmp -s "$file1" "$file2"; then
#     echo "Contents are identical"
# fi

# if ! diff "$file1" "$file2" >/dev/null; then
#     echo "Files differ"
# fi

# Checksums (md5sum/sha256sum)
# if [ "$(md5sum < "$file1")" = "$(md5sum < "$file2")" ]; then
#     echo "Contents match"
# fi



# Special file types
# device="/dev/sda1"
# if [ -b "$device" ]; then
#     echo "Block device"
# fi

# What it does:
# Checks if /dev/sda1 is a block device (storage devices like disks, partitions)
# -b test returns true if:
# The file exists AND
# It's a special block device file (buffered I/O, typically in /dev)


# pipe="/tmp/mypipe"
# if [ -p "$pipe" ]; then
#     echo "Named pipe"
# fi

# What it does:
# Checks if /tmp/mypipe is a named pipe (FIFO)
# -p test returns true if:
# The file exists AND
# It was created with mkfifo


# Socket file (-S)
# socket="/tmp/socket"
# if [ -S "$socket" ]; then
#     echo "Socket file"
# fi

# What it does:
# Checks if /tmp/socket is a Unix domain socket
# -S test returns true if:
# The file exists AND
# It's a socket file (created by applications for IPC)



# Combining multiple conditions
# username="admin"
# password="secret"
# ip="192.168.1.100"

# if [ "$username" = "admin" ] && [ "$password" = "secret" ] && [[ "$ip" =~ ^192\.168\. ]]; then
#     echo "Admin access from local network"
# elif [ "$username" = "user" ] && [ -n "$password" ]; then
#     echo "Regular user access"
# else
#     echo "Access denied"
# fi

# Nested conditions
# system_type="Linux"
# architecture="x86_64"

# if [ "$system_type" = "Linux" ]; then
#     if [ "$architecture" = "x86_64" ]; then
#         echo "64-bit Linux system"
#     elif [ "$architecture" = "i386" ]; then
#         echo "32-bit Linux system"
#     else
#         echo "Unknown Linux architecture"
#     fi
# elif [ "$system_type" = "Windows" ]; then
#     echo "Windows system detected"
# else
#     echo "Unknown operating system"
# fi



# System health check script

# Check disk usage
# disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
# if [ $disk_usage -gt 90 ]; then
#     echo "WARNING: Disk usage is $disk_usage%"
# elif [ $disk_usage -gt 80 ]; then
#     echo "CAUTION: Disk usage is $disk_usage%"
# else
#     echo "Disk usage OK: $disk_usage%"
# fi



# Check if service is running
# service_name="nginx"
# if systemctl is-active --quiet $service_name; then
#     echo "Service $service_name is running"
# else
#     echo "Service $service_name is not running"
#     if [ -w /etc/systemd/system ]; then
#         echo "Attempting to start service..."
#         systemctl start $service_name
#     else
#         echo "No permission to start service"
#     fi
# fi



# File validation script
input_file="$1"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
elif [ ! -e "$input_file" ]; then
    echo "Error: File '$input_file' does not exist"
    exit 1
elif [ ! -f "$input_file" ]; then
    echo "Error: '$input_file' is not a regular file"
    exit 1
elif [ ! -r "$input_file" ]; then
    echo "Error: No read permission for '$input_file'"
    exit 1
else
    echo "Processing file: $input_file"
    wc -l "$input_file" #wc means word count
fi







