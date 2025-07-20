#!/bin/bash

# set -euo pipefail

# echo "=== BASIC VARIABLE DECLARATIONS ==="
# # Simple variable declaration
# simple_var="Hello World"
# # echo "Simple variable: $simple_var"

# # DECLARE COMMAND - BASIC SYNTAX
# echo -e "\n=== DECLARE COMMAND BASICS ==="
# declare basic_declare="Basic value"
# # echo "Basic declare: $basic_declare"

# # Declare without value (creates empty variable)
# # declare empty_var   # if i use set -euo pipefail then it will throw an error without using it, it will work
# # echo "Empty variable: '${empty_var}'"


# echo -e "\n=== DECLARE FLAGS AND TYPES ==="
# declare indexed_array_declaration # without -a flag index array declaration
# # declare -a indexed_array_declaration # -a for index array declaration

# indexed_array_declaration[0]="Jahin"
# indexed_array_declaration[1]="Sahin"
# indexed_array_declaration["name"]="Khan"

# echo ${indexed_array_declaration[@]} # all array items 
# echo ${#indexed_array_declaration[@]} # get array length
# echo ${indexed_array_declaration[0]} # get by index


# -A : Associative array (hash/dictionary)
# declare -A associative_array=()

# declare -A associative_array=(
#     [key1]="value1"
#     [key2]="value2"
#     [key3]="value3"
# )

# associative_array["name"]="John Doe"
# associative_array["age"]=20
# associative_array["city"]="New York"

# Declare a separate indexed array for tags
# declare -a tags=("js" "javascript" "typescript" "node")
# # associative_array["tags"]="tags"

# 1. way to get nested array
# -n for ref and now tags original value get and assigned value to temp and echo
# declare -n temp_ref_array=${associative_array[tags]}
# echo ${temp_ref_array[@]}


# 2. way to get nested array values
# Serialize/Deserialize (More portable)


# $(printf "%s\n" "js" "javascript" "typescript" "node" | paste -sd, -)
# printf "%s\n" "js" "javascript" "typescript" "node"
# - printf formats and prints data
# - %s means "insert as string"
# - \n adds a newline after each string
# - The Pipe (|) Takes the output of the left command (printf) and feeds it as input to the right command (paste)
# - paste merges lines from input
# - -s = serial (combines all lines into one line)
# - d, = sets comma (,) as the delimiter
# - = tells paste to read from stdin (the pipe)

# printf output       paste transformation
# -------------       --------------------
# js                  js,javascript,typescript,node
# javascript
# typescript
# node

# Alternative Way:
# arr=("js" "javascript" "typescript" "node")
# (IFS=','; echo "${arr[*]}")

# declare -a tags=("js" "javascript" "typescript" "node")
# associative_array["tags"]=$(printf "%s\n" "${tags[@]}" | paste -sd, -) # converted array to string with , delimeter: e,g js, javascript 
# echo ${associative_array["tags"]} #echo as a string because in this stage tags values are not array anymore

# Retrieve and convert back to array
# IFS=',' read -ra tags <<< "${associative_array[tags]}"

# IFS="," read -r tags <<< ${associative_array[tags]}
# printf "All Tags\n"
# printf "${tags[@]}"
# printf "\n"



# 3. way to retrive nested array
# Create array keys
# for i in "${!tags[@]}"; do
#     associative_array["tags,$i"]="${tags[$i]}"
# done

# # Retrieve all tags
# printf "All tags:\n"
# for key in "${!associative_array[@]}"; do
#     if [[ $key == tags,* ]]; then
#         printf "  - %s\n" "${associative_array[$key]}"
#     fi
# done



# exit 0





# associative_array["tags"]=("js" "javascript" "typescript" "node")

# echo ${associative_array[@]}

# if you loop through associative array with keys then you need ! to get keys and values
# for key in ${!associative_array[@]}; do 
# # echo "key: $key"
# # echo "value: ${associative_array[$key]}"
# echo "{ $key: ${associative_array[$key]}}"
# done


# not working due to format issues
# while IFS= read -r key; do 
#     echo "$key"
# done < <(printf "\n${!associative_array[@]}")

# %s is a format specifier in printf that means "insert the next argument as a string."

# declare -A associative_array=(
#     ["name"]="John Doe"
#     ["age"]="30"
#     ["city"]="New York"
# )

# while IFS= read -r key; do
#     value="${associative_array[$key]}"
#     echo "Key: $key, Value: $value"
# done < <(printf "%s\n" "${!associative_array[@]}")


# declare -a my_array
# my_array=("apple" "banana" "cherry")

# # Modify Elements
# my_array[0]="orange"

# # Add Elements (append)
# my_array+=("malta" "xyz")

# Access Elements
# echo ${my_array[0]}      # → "js" (first element)
# echo ${my_array[-1]}     # →  (last element)
# echo ${my_array[@]}      # → All elements

# Get Array Length
# echo "${#my_array[@]}"

# printf " + %s\n" ${my_array[@]}
# unset my_array[1]  # Remove "banana"
# echo "Indices: ${!my_array[@]}" # print indexes 

# my_array=("${my_array[@]}")  # Reindex
# echo "ReIndexing: ${!my_array[@]}"

# my_array=("${my_array[@]:1}") # remove first 1 item 
# my_array=("${my_array[@]:2}") # remove first 2 items 

# printf " - %s\n" ${my_array[@]}


# -i : Integer variable
# declare -i integer_var
# integer_var=20
# echo "integer value: $integer_var"
# integer_var="50 + 20" # if i couldn't declare with -i, it would treat as a string then the operation would be 50 + 20 
# echo "sum=${integer_var}"


# -r : Read-only variable (constant)
# declare -r readonly_var="Cannot change this"
# echo "Read-only variable: $readonly_var"
# readonly_var="Hello ReadOnly"


# -x : Export variable (environment variable)
# declare -x exported_var="This is a exported variable"
# echo "Exported variable: $exported_var"

# -l : Convert to lowercase
# declare -l str="Hello JS"
# echo "$str"
# str="KHAN"
# echo $str


# # -L : Convert to Uppercase
# declare -u str="Hello JS"
# echo "$str"

# -n : Name reference (variable reference)
# original_var="Original value"
# declare -n username=original_var
# echo $username

# username="Modified through reference"
# echo "Original after modification: $original_var"


# echo -e "\n=== COMBINING FLAGS ==="

# # Read-only integer
# declare -ri readonly_integer=100
# echo "$readonly_integer"
# # readonly_integer=200

# # Exported uppercase variable
# declare -ux exported_uppercase="exported and uppercase"
# echo "Exported uppercase: $exported_uppercase"


# Read-only associative array
# declare -rA readonly_assoc_array=(
#     ["key1"]="value1"
#     ["key2"]="value2"
# )
# echo "Read-only associative array: ${readonly_assoc_array[key1]}"

# readonly_assoc_array[key1]="Jahin"


echo -e "\n=== FUNCTION DECLARATIONS ==="

# declare -f 

# myfunction(){
#     echo "my function"
# }

# Show specific function
# echo "Function definition:"
# declare -f myfunction

# -F : Function names only
# echo "Function names only:"
# declare -F

echo -e "\n=== PRINT ATTRIBUTES ==="
# -p : Print variable attributes and values
# declare -p simple_var
# declare -p indexed_array
# declare -p associative_array
# declare -p integer_var
# declare -p readonly_var


echo -e "\n=== ADVANCED DECLARE USAGE ==="
# Declare multiple variables at once
# declare var1="value1" var2="value2" var3="value3"
# echo "Multiple variables: $var1, $var2, $var3"

# declare v1="v1.0" v2="v2.1"
# echo "$v1, $v2"
# echo "${$v1, $v2}" #syntax error: bad substitution

# Declare with default values using parameter expansion
# declare config_file="${CONFIG:-/etc/hosts}"
# echo "Config file: $config_file"


# Declare associative array with initial values
# declare -A person=(
#     ["first_name"]="John"
#     ["last_name"]="Doe"
#     ["email"]="john@example.com"
#     ["phone"]="123-456-7890"
# )
# echo "Person info: ${person[first_name]} ${person[last_name]}"



# demo_local_declare() {
#     # Local variable (only exists within function)
#     local local_var="I'm local"
    
#     # Local integer
#     local -i local_int=42
    
#     # Local array
#     local -a local_array=("a" "b" "c")
    
#     # Local associative array
#     local -A local_assoc=(["key"]="value")
    
#     # Local read-only
#     local -r local_readonly="Cannot change in function"
    
#     echo "Local variable: $local_var"
#     echo "Local integer: $local_int"
#     echo "Local array: ${local_array[@]}"
#     echo "Local associative: ${local_assoc[key]}"
#     echo "Local read-only: $local_readonly"
# }

# demo_local_declare



# Declare only if variable doesn't exist
DATABASE_URL="test.db"
declare database_url="${DATABASE_URL:-postgresql://localhost:5432/mydb}"
echo "Database URL: $database_url"


#  Declare with validation
get_port_number(){

    declare -i port_number="${1:-}"

    if [ -z "$1" ]; then
        echo "Error: No port number provided. Using default port 8080." >&2
        port_number=8080
    # Check if argument is a valid port number
    elif [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]; then
        port_number=$1
    else
        port_number=8080
    fi

    echo "Port number: $port_number"
}


# Usage: Safe for missing $1
# port="$(get_port_number "${1:-}")" # Works even if $1 is unset
# echo "Selected port: $port"

# Call the function and check its return status
# if ! get_port_number "$1"; then
#     echo "Failed to get valid port number" >&2
#     exit 1
# fi

# get_port_number $? #get the port from terminal as a param



echo -e "\n=== REAL-WORLD EXAMPLES ==="

# Configuration management
# declare -r APP_NAME="MyApplication"
# declare -r APP_VERSION="1.0.0"

# LOG_LEVEL="WARNING"
# declare -x LOG_LEVEL="${LOG_LEVEL:-INFO}"
# # LOG_LEVEL="WARNING2"
# declare -i MAX_CONNECTIONS=100

# # echo $LOG_LEVEL

# # User data structure
# declare -A user_profile=(
#     ["username"]="admin"
#     ["email"]="admin@example.com"
#     ["role"]="administrator"
#     ["last_login"]="2024-01-15"
# )


# Command-line argument processing
declare -A cli_args
declare -i arg_count=0

process_arguments(){

    while [[ $# -gt 0 ]]; do 
        case $1 in
            --name=*)
            cli_args["name"]="${1#*=}"
            ;;
            --port=*)
            cli_args["port"]="${1#*=}"
            ;;
            --debug)
            cli_args["debug"]="true"
            ;;
            *)
            echo "Unknown argument: $1"
            ;;
        esac
        shift
        ((arg_count++))
    done

    echo "${cli_args[@]} and count arg: ${arg_count}"
}

# Example usage (uncomment to test with arguments)
# process_arguments ${1:-} ${2:-} ${3:-}

# --name=myapp --port=8080 --debug


# Database connection configuration
declare -rA db_config=(
    ["host"]="localhost"
    ["port"]="5432"
    ["database"]="myapp"
    ["username"]="dbuser"
)

# Application settings
declare -r CONFIG_DIR="/etc/myapp"
declare -r LOG_DIR="/var/log/myapp"
declare -ri MAX_LOG_SIZE=1048576  # 1MB in bytes

# Feature flags
declare -A features=(
    ["auth"]="enabled"
    ["cache"]="disabled"
    ["debug"]="false"
)

# System information
declare -x SYSTEM_INFO="$(uname -s)-$(uname -m)"
# declare -i AVAILABLE_MEMORY=$(free -m | awk 'NR==2{print $7}')

echo "Database host: ${db_config[host]}"
echo "Config directory: $CONFIG_DIR"
echo "Auth feature: ${features[auth]}"
echo "System info: $SYSTEM_INFO"
echo "Available memory: ${AVAILABLE_MEMORY}MB"


echo -e "\n=== DECLARE REFERENCE GUIDE ==="

cat << EOF
DECLARE FLAGS SUMMARY:
======================

-a    : Indexed array
-A    : Associative array (hash/dictionary)
-f    : Function names and definitions
-F    : Function names only
-i    : Integer variable (arithmetic evaluation)
-l    : Convert to lowercase
-n    : Name reference (variable reference)
-p    : Print variable attributes and values
-r    : Read-only variable (constant)
-u    : Convert to uppercase
-x    : Export variable (environment variable)

COMBINING FLAGS:
================
-ri   : Read-only integer
-ux   : Exported uppercase variable
-rA   : Read-only associative array
-xa   : Exported indexed array

VARIABLE TYPES:
===============
1. Simple variables    : declare var="value"
2. Integers           : declare -i num=42
3. Arrays             : declare -a arr=("a" "b" "c")
4. Associative arrays : declare -A hash=([key]="value")
5. Read-only          : declare -r const="unchangeable"
6. Environment vars   : declare -x env_var="exported"
7. Case-converted     : declare -l/-u var="text"
8. Name references    : declare -n ref=other_var

SCOPE:
======
- Global: declare (outside functions)
- Local:  local (inside functions)
- Export: declare -x (available to child processes)

USAGE EXAMPLES:
===============
declare -A config=([host]="localhost" [port]="8080")
declare -ri MAX_USERS=100
declare -x PATH="/usr/local/bin:$PATH"
local -a temp_array=("temp" "data")
EOF



