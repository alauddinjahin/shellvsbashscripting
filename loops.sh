# # Bash Loops Guide

# ## For Loops

# ### Basic For Loop Syntax
# ```bash
# # Iterate over a list of items
# for item in list; do
#     # commands
# done

# # Examples
# for name in Alice Bob Charlie; do
#     echo "Hello $name"
# done

# # Iterate over command line arguments
# for arg in "$@"; do
#     echo "Argument: $arg"
# done
# ```

# ### For Loop with Ranges
# ```bash
# # C-style for loop
# for (( i=1; i<=10; i++ )); do
#     echo "Number: $i"
# done

# # Countdown
# for (( i=10; i>=1; i-- )); do
#     echo "Countdown: $i"
# done

# # Step increment
# for (( i=0; i<=100; i+=10 )); do
#     echo "Value: $i"
# done

# # Using brace expansion for ranges
# for i in {1..10}; do
#     echo "Item $i"
# done

# # Range with step
# for i in {1..20..2}; do  # 1, 3, 5, 7, ..., 19
#     echo "Odd number: $i"
# done

# # Letters
# for letter in {A..Z}; do
#     echo "Letter: $letter"
# done
# ```

# ### For Loop with Files and Directories
# ```bash
# # Iterate over files in current directory
# for file in *; do
#     if [ -f "$file" ]; then
#         echo "File: $file"
#     fi
# done

# # Iterate over specific file types
# for txtfile in *.txt; do
#     if [ -f "$txtfile" ]; then
#         echo "Processing: $txtfile"
#         wc -l "$txtfile"
#     fi
# done

# # Iterate over files recursively
# for file in $(find . -name "*.sh"); do
#     echo "Shell script: $file"
#     chmod +x "$file"
# done

# # Iterate over directories
# for dir in */; do
#     echo "Directory: ${dir%/}"  # Remove trailing slash
#     ls -la "$dir"
# done

# # Process files with spaces in names
# find . -name "*.log" -print0 | while IFS= read -r -d '' file; do
#     echo "Log file: $file"
# done
# ```

# ### Advanced For Loop Examples
# ```bash
# # Iterate over array
# fruits=("apple" "banana" "orange" "grape")
# for fruit in "${fruits[@]}"; do
#     echo "Fruit: $fruit"
# done

# # Iterate with index
# for i in "${!fruits[@]}"; do
#     echo "Index $i: ${fruits[i]}"
# done

# # Multiple variables
# for entry in name:Alice age:30 city:NYC; do
#     key=${entry%:*}
#     value=${entry#*:}
#     echo "$key = $value"
# done

# # Nested for loops
# for i in {1..3}; do
#     for j in {1..3}; do
#         echo "$i x $j = $((i * j))"
#     done
# done

# # Process CSV-like data
# data="John,25,Engineer Mary,30,Doctor Bob,35,Teacher"
# IFS=' ' read -ra entries <<< "$data"
# for entry in "${entries[@]}"; do
#     IFS=',' read -ra person <<< "$entry"
#     echo "Name: ${person[0]}, Age: ${person[1]}, Job: ${person[2]}"
# done
# ```

# ## While Loops

# ### Basic While Loop
# ```bash
# # Basic syntax
# while [ condition ]; do
#     # commands
# done

# # Counter example
# count=1
# while [ $count -le 5 ]; do
#     echo "Count: $count"
#     ((count++))
# done

# # Reading user input
# while true; do
#     read -p "Enter command (quit to exit): " cmd
#     if [ "$cmd" = "quit" ]; then
#         break
#     fi
#     echo "You entered: $cmd"
# done
# ```

# ### While Loop with File Processing
# ```bash
# # Read file line by line
# while IFS= read -r line; do
#     echo "Line: $line"
# done < "input.txt"

# # Process command output
# ps aux | while read user pid cpu mem vsz rss tty stat start time command; do
#     if [ "$cpu" != "CPU" ] && (( $(echo "$cpu > 50.0" | bc -l) )); then
#         echo "High CPU process: $command ($cpu%)"
#     fi
# done

# # Monitor file changes
# logfile="/var/log/system.log"
# while [ ! -f "$logfile" ]; do
#     echo "Waiting for log file to appear..."
#     sleep 1
# done

# # Wait for service to start
# service_name="nginx"
# while ! systemctl is-active --quiet $service_name; do
#     echo "Waiting for $service_name to start..."
#     sleep 2
# done
# echo "$service_name is now running"
# ```

# ### Advanced While Loop Examples
# ```bash
# # Menu system
# while true; do
#     echo "=== Main Menu ==="
#     echo "1. List files"
#     echo "2. Show date"
#     echo "3. Show users"
#     echo "4. Exit"
#     read -p "Select option: " choice
    
#     case $choice in
#         1) ls -la ;;
#         2) date ;;
#         3) who ;;
#         4) echo "Goodbye!"; break ;;
#         *) echo "Invalid option" ;;
#     esac
#     echo
# done

# # Process monitoring
# process_name="httpd"
# max_attempts=60
# attempts=0

# while [ $attempts -lt $max_attempts ]; do
#     if pgrep "$process_name" > /dev/null; then
#         echo "Process $process_name is running"
#         break
#     else
#         echo "Process $process_name not found. Attempt $((attempts + 1))/$max_attempts"
#         sleep 5
#         ((attempts++))
#     fi
# done

# if [ $attempts -eq $max_attempts ]; then
#     echo "Process $process_name failed to start within timeout"
# fi

# # Password validation
# while true; do
#     read -s -p "Enter password: " password
#     echo
    
#     if [ ${#password} -lt 8 ]; then
#         echo "Password must be at least 8 characters"
#         continue
#     fi
    
#     if [[ ! "$password" =~ [A-Z] ]]; then
#         echo "Password must contain uppercase letter"
#         continue
#     fi
    
#     if [[ ! "$password" =~ [0-9] ]]; then
#         echo "Password must contain a number"
#         continue
#     fi
    
#     echo "Password accepted"
#     break
# done
# ```

# ## Until Loops

# ### Basic Until Loop
# ```bash
# # Basic syntax - runs until condition becomes true
# until [ condition ]; do
#     # commands
# done

# # Counter example
# count=1
# until [ $count -gt 5 ]; do
#     echo "Count: $count"
#     ((count++))
# done

# # Wait until file exists
# filename="important.txt"
# until [ -f "$filename" ]; do
#     echo "Waiting for $filename to appear..."
#     sleep 1
# done
# echo "File $filename found!"
# ```

# ### Until Loop Examples
# ```bash
# # Wait for network connectivity
# until ping -c 1 google.com &> /dev/null; do
#     echo "No internet connection. Retrying in 5 seconds..."
#     sleep 5
# done
# echo "Internet connection established"

# # Wait for disk space to be available
# required_space=1000000  # 1GB in KB
# until [ $(df / | tail -1 | awk '{print $4}') -gt $required_space ]; do
#     echo "Insufficient disk space. Cleaning up..."
#     # Cleanup commands here
#     sleep 10
# done
# echo "Sufficient disk space available"

# # Wait for user confirmation
# until [ "$response" = "yes" ]; do
#     read -p "Are you ready to proceed? (yes/no): " response
#     if [ "$response" = "no" ]; then
#         echo "Operation cancelled"
#         exit 1
#     elif [ "$response" != "yes" ]; then
#         echo "Please enter 'yes' or 'no'"
#     fi
# done
# echo "Proceeding with operation..."

# # Wait for service to stop
# service_name="apache2"
# until ! systemctl is-active --quiet $service_name; do
#     echo "Waiting for $service_name to stop..."
#     sleep 2
# done
# echo "$service_name has stopped"
# ```

# ## Loop Control: break and continue

# ### Break Statement
# ```bash
# # Exit loop early
# for i in {1..10}; do
#     if [ $i -eq 6 ]; then
#         echo "Breaking at $i"
#         break
#     fi
#     echo "Number: $i"
# done

# # Break from nested loops
# for i in {1..3}; do
#     for j in {1..3}; do
#         if [ $i -eq 2 ] && [ $j -eq 2 ]; then
#             echo "Breaking from nested loop at $i,$j"
#             break 2  # Break from 2 levels
#         fi
#         echo "$i,$j"
#     done
# done

# # Menu with break
# while true; do
#     echo "1. Option 1"
#     echo "2. Option 2" 
#     echo "3. Exit"
#     read -p "Choice: " choice
    
#     case $choice in
#         1) echo "Option 1 selected" ;;
#         2) echo "Option 2 selected" ;;
#         3) echo "Exiting..."; break ;;
#         *) echo "Invalid choice" ;;
#     esac
# done
# ```

# ### Continue Statement
# ```bash
# # Skip current iteration
# for i in {1..10}; do
#     if [ $((i % 2)) -eq 0 ]; then
#         continue  # Skip even numbers
#     fi
#     echo "Odd number: $i"
# done

# # Process files, skip directories
# for item in *; do
#     if [ -d "$item" ]; then
#         continue  # Skip directories
#     fi
#     echo "Processing file: $item"
#     # Process file here
# done

# # Skip empty lines when reading file
# while IFS= read -r line; do
#     if [ -z "$line" ]; then
#         continue  # Skip empty lines
#     fi
#     echo "Processing: $line"
# done < "input.txt"

# # Validation loop with continue
# while IFS= read -r email; do
#     if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
#         echo "Invalid email: $email"
#         continue
#     fi
#     echo "Valid email: $email"
#     # Process valid email
# done < "email_list.txt"
# ```

# ## Real-World Loop Examples

# ### System Administration
# ```bash
# #!/bin/bash
# # Server monitoring script

# servers=("web1.example.com" "web2.example.com" "db1.example.com")

# for server in "${servers[@]}"; do
#     echo "Checking server: $server"
    
#     if ping -c 1 "$server" &> /dev/null; then
#         echo "✓ $server is reachable"
        
#         # Check specific services
#         for port in 22 80 443; do
#             if timeout 5 bash -c "echo >/dev/tcp/$server/$port" &> /dev/null; then
#                 echo "  ✓ Port $port is open"
#             else
#                 echo "  ✗ Port $port is closed or filtered"
#             fi
#         done
#     else
#         echo "✗ $server is unreachable"
#     fi
#     echo
# done

# # Log rotation
# log_dir="/var/log/myapp"
# max_size=100000000  # 100MB

# for logfile in "$log_dir"/*.log; do
#     if [ -f "$logfile" ]; then
#         size=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile")
#         if [ "$size" -gt "$max_size" ]; then
#             echo "Rotating large log file: $logfile"
#             mv "$logfile" "$logfile.$(date +%Y%m%d)"
#             touch "$logfile"
#         fi
#     fi
# done
# ```

# ### File Processing
# ```bash
# #!/bin/bash
# # Batch file processor

# # Process images in directory
# image_dir="./images"
# output_dir="./thumbnails"

# mkdir -p "$output_dir"

# for image in "$image_dir"/*.{jpg,jpeg,png,gif}; do
#     if [ ! -f "$image" ]; then
#         continue  # Skip if no files match pattern
#     fi
    
#     filename=$(basename "$image")
#     name="${filename%.*}"
#     ext="${filename##*.}"
    
#     echo "Processing: $filename"
    
#     # Create thumbnail (requires ImageMagick)
#     if command -v convert &> /dev/null; then
#         convert "$image" -resize 150x150 "$output_dir/${name}_thumb.$ext"
#         echo "Created thumbnail for $filename"
#     else
#         echo "ImageMagick not found, skipping $filename"
#     fi
# done

# # CSV processing
# csv_file="data.csv"
# line_num=0

# while IFS=',' read -r name age city; do
#     ((line_num++))
    
#     if [ $line_num -eq 1 ]; then
#         continue  # Skip header
#     fi
    
#     echo "Record $((line_num-1)): $name (Age: $age, City: $city)"
    
#     # Validate age
#     if ! [[ "$age" =~ ^[0-9]+$ ]]; then
#         echo "  Warning: Invalid age format"
#         continue
#     fi
    
#     if [ "$age" -lt 18 ]; then
#         echo "  Minor detected"
#     elif [ "$age" -ge 65 ]; then
#         echo "  Senior detected"
#     fi
    
# done < "$csv_file"
# ```

# ### Interactive Scripts
# ```bash
# #!/bin/bash
# # Interactive file manager

# current_dir=$(pwd)

# while true; do
#     clear
#     echo "=== Simple File Manager ==="
#     echo "Current directory: $current_dir"
#     echo
    
#     # List files with numbers
#     files=(*)
#     for i in "${!files[@]}"; do
#         if [ -d "${files[i]}" ]; then
#             echo "$((i+1)). [DIR] ${files[i]}"
#         else
#             echo "$((i+1)). ${files[i]}"
#         fi
#     done
    
#     echo
#     echo "Commands: ls, cd <dir>, exit"
#     read -p "> " command args
    
#     case $command in
#         "ls")
#             ls -la
#             read -p "Press Enter to continue..."
#             ;;
#         "cd")
#             if [ -n "$args" ] && [ -d "$args" ]; then
#                 cd "$args"
#                 current_dir=$(pwd)
#             else
#                 echo "Directory not found: $args"
#                 read -p "Press Enter to continue..."
#             fi
#             ;;
#         "exit")
#             echo "Goodbye!"
#             break
#             ;;
#         *)
#             if [[ "$command" =~ ^[0-9]+$ ]] && [ "$command" -le "${#files[@]}" ]; then
#                 selected="${files[$((command-1))]}"
#                 if [ -d "$selected" ]; then
#                     cd "$selected"
#                     current_dir=$(pwd)
#                 else
#                     echo "Selected file: $selected"
#                     read -p "Press Enter to continue..."
#                 fi
#             else
#                 echo "Unknown command: $command"
#                 read -p "Press Enter to continue..."
#             fi
#             ;;
#     esac
# done
# ```



# for ((i=0; i < 5; i++)){
#     SL=$((i + 1))
#     echo "SL. (${SL})"
# }

# fruits=("Apple" "Banana" "Mango")
# len=${#fruits[@]}

# echo $len;
# fruits+=("Orange" "pinapple")
# echo ${#fruits[@]};
# echo $len;


# for item in "${fruits[@]}"; do 
#     # unset 'fruits[0]'
#     echo -e "${item}"
# done 

# echo -e "unseted:\n ${fruits[@]}"

# for itemIndex in "${!fruits[@]}"; do #index
#     echo -e "${fruits[$itemIndex]}"
# done 


# exit;

# for ((i=0; i < "${len}"; i++)){
#     SL=$((i + 1))

#     (( SL == 1)) && {
#         unset 'fruits[i]' 

#         continue
#     }

#     echo "(${SL}) ${fruits[$i]}"

#     fruits+=("Orange" "pinapple")

#     ((len == $SL)) && {
#         printf "Updated list:\n"
#         printf "%s\n" "${fruits[@]}"
#     }

#     # ((len == $SL)) && echo -e "updated list:\n ${fruits[@]}"
    
# }

# newArray=(${fruits[@]}) # copy and reindexing
# echo "Array indexes:"
# echo "${!newArray[@]}"


# for param in $@; do 
#     echo "param -> ${param}"
# done

# read -p "Enter fruits: " input
# Split the input into an array
# fruits=($input)  # Note: no quotes around $input to enable word splitting

# IFS=", " read -ra fruits <<< $input # remove , if users provide.
# tmp="${input// /}" ## Remove all spaces then split on commas
# IFS=',' read -ra fruits <<< "$tmp"
# echo $input
# echo ${fruits[@]}

# input=${input#*${BASH_REMATCH[2]}} # Remove processed part 
# input=${input## }  # Trim leading space

# for index in ${!fruits[@]}; do 
#     echo "($index) -> ${fruits[index]}"
# done

# for((i=10; i>=1; i--)){
#     echo "reverse counter: $i"
# }


# for(( i=0; i<= 10; i+=2)){
#     echo "step: $i"
# }

# numbers=({1..10})
# for num in "${numbers[@]}"; do
#     echo "$num"
# done

# for num in {1..10..2}; do  #range and step
#     echo "step-> $num"
# done 

# Letters

# for letter in {A..Z}; do #letter iterator
#     echo "Letter: $letter"
# done


# for letter in {A..Z..2}; do # with steps
#     echo "Step: $letter"
# done

# echo *  # * means current dir files

# for file in *; do 
#     echo "file: $file"
# done


# # Iterate over files in current directory
# for file in *; do
#     if [ -f "$file" ]; then
#         echo "File: $file"
#     fi
# done

# Iterate over specific file types
# txt_files=*.txt
# rm -rf $txt_files
# for txtfile in *.txt; do
#     if [ -f "$txtfile" ]; then
#         echo "Processing: $txtfile"
#         wc -l "$txtfile"
#     fi
# done

# error_files=(err*.log)
# echo ${error_files[@]}
# rm -rf $error_files

# Iterate over directories
# for dir in */; do
#     echo "Directory: ${dir%/}"  # Remove trailing slash
#     ls -la "$dir"
# done

# Process files with spaces in names
# find . -name "*.log" -print0 | while IFS= read -r -d '' file; do
#     echo "Log file: ${file}"
# done

# find . -name "*.log" -print0 | while IFS= read -r -d '' file; do
#     clean_file="${file#./}"  # Remove ./ prefix
#     echo "Log file: $clean_file"
# done

# find . -name "*.log" -printf "%f\n"
# echo $(find . -name "*.log" -printf "%f\n") # no loop nedded
# echo $(find . -name "*.log" -printf "Log file: %f\n") # no loop nedded

# mapfile -t files < <(find . -name "*.log" -printf "%f\n")
# printf "Log file: %s\n" "${files[@]}"


# Most reliable for all cases
# find . -name "*.log" -print0 | while IFS= read -r -d '' file; do
#     echo "Log file: ${file##*/}"
# done

# find . -name "*.log" -print

# Multiple variables
# key-value string name:Alice
# for entry in name:Alice age:30 city:NYC; do
#     key=${entry%:*} #remove suffix output -> name
#     value=${entry#*:} #remove prefix, output -> Alice
#     echo "$key = $value"
# done

# Nested for loops
for i in {1..3}; do
    for j in {1..3}; do
        echo "$i x $j = $((i * j))"
    done
done