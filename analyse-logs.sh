#!/bin/bash
# this is called shebang: #!/bin/bash

set -euo pipefail  # All protections in one line


# set -o errexit  # Exit on errors
# set -o nounset  # Fail on undefined vars
# set -o pipefail # Bonus: Catch pipeline errors
# set -e  # Your existing errexit
# set -u  # nounset: Triggers on undefined variables
# set -o pipefail  # Fail if any step in a pipeline fails

# set -e
# declare LOG_DIR
# declare APP_LOG
# declare SYS_LOG

# ERROR_PATTERNS=("INFO" "ERROR" "FATAL")
# output of <(find . -name "*.sh" -mtime -1) assign as an input of FILE_TO_ACTUAL_ARRAY 
# -t ensures clean array entries without unexpected whitespace. 
# find . -name "*.sh" -newermt "$(date -d '20 seconds ago' +'%Y-%m-%d %H:%M:%S')"
# find . -name "*.sh" -newermt "$(date -d '120000 seconds ago' +'%Y-%m-%d %H:%M:%S')"
# find . -name "*.sh" -mmin -0.333  # 20 seconds = 0.333 minutes
# mapfile -t FILE_TO_ACTUAL_ARRAY < <(find . -name "*.sh" -mmin -20)
# touch test.sh && sleep 0.5 && find . -name "*.sh" -newermt "$(date -d '0.5 seconds ago' +'%Y-%m-%d %H:%M:%S')"

# set -e
# mapfile -t FILE_TO_ACTUAL_ARRAY < <(find . -name "*.sh" -mtime -1)

# LOG_FILE=log.text
# touch $LOG_FILE

# print_files(){
#     for file in ${FILE_TO_ACTUAL_ARRAY[@]}; do
#         for pattern in ${ERROR_PATTERNS[@]}; do
#         # echo -e "\nfound ${file}" > $LOG_FILE # > means inserting but the file will replace with next inserted value
#         # echo "${pattern}" > $LOG_FILE

#         echo -e "\nfound ${file}" >> $LOG_FILE  # >> means append
#         echo "${pattern}" >> $LOG_FILE
        
#         done
#     done

#     # echo ${#$FIND_LOG_FILES[@]}

# }

# log(){
# echo "
# ${ERROR_PATTERNS[0]}
# [2023-11-15 14:23:45] [${ERROR_PATTERNS[0]}] Starting script execution

# ${ERROR_PATTERNS[1]}
# [2023-11-15 14:23:47] [${ERROR_PATTERNS[1]}] File not found: config.ini

# ${ERROR_PATTERNS[2]}
# [2023-11-15 14:23:49] [${ERROR_PATTERNS[2]}] Critical system failure
# "
# }

# log

# print_files

# set -x

create_multi_files(){
    for i in {1..100}; do 
        touch "log_${i}_$(date +'%y_%m_%d_%H_%M').txt"; 
    done
}

# check files by matching pattern: ls -l log_*.txt | wc -l
delete_log(){

    echo "Creating 100 log files"
    create_multi_files
    echo "100 log files have created"
    
    sleep 1
    # exit 0

    local target_dir=$1
    local error_count=0
    local file_deleted=0
    # set -x

    # check directory exits or not
    [[ -d $target_dir ]] || {
        echo "$target_dir doesn't exist" >&2
        return 1
    }


    [[ -r $target_dir &&  -w $target_dir ]] || {
        echo "Insufficient permissions for $target_dir" >&2
        return 1
    }

    # IFS= (Input Field Separator) Controls how input is split into fields
    # -r : Prevents backslash (\) interpretation (e.g., \n remains as literal characters)

    # Initialize counters explicitly (required for nounset)
    echo "Start deleting..."
    while IFS= read -r file; do 
        if rm -f "$file"; then
            ((file_deleted++)) || true
            # echo "$file is deleted"
            echo "✓ Deleted: ${file##*/}"  # Show filename only
        else 
            (( error_count++ )) || true
            echo "Unable to deletem ${file}"
        fi

    done < <(find "$target_dir" -name "*log*.txt" -type f 2>/dev/null | sort -V)
    # find "$target_dir" -name "*log*.txt" 2>/dev/null
    # -type f ensures that it's a file type not directory if need directory -type d
    # sort -t '_' -k2,2n -k3,3n  # Sorts by 2nd and 3rd fields numerically
    # find . -name "*log*.txt" | sort -Vr   --------------desc
    # find . -name "*log*.txt" | sort -V    -------------- asc
    # or find . -name "*log*.txt" | sort -t '_' -k2,2n         --------------asc 
    # or find . -name "*log*.txt" | sort -t '_' -k2,2nr        - desc

    echo "Deletion complete:"
    echo "Successfully deleted: $file_deleted files"
    echo "Failed to delete: $error_count files"

    return $((error_count > 0 ? 1 : 0))

}


delete_log "."

# readonly ERROR_PATTERNS=("ERROR" "INFO" "FATAL")
# readonly LOG_FILE=log_$(date +"%y_%m_%d_%H_%M").txt

# mapfile -t ARRAY_FILES < <(find . -name "*.sh" -mtime -1 2>/dev/null)

# find . -name "log_*.txt" -delete
# # find . -name "*log_*.txt"
# # find . -regextype posix-extended -regex ".*/log_([0-9]{2}_){4}[0-9]{2}\.text"
# # find . -regex ".*/log_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}\.text" -print
# # find . -maxdepth 1 -regex ".*/log_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}\.text" -delete

# touch $LOG_FILE


# echo "Logging started"

# for file in "${ARRAY_FILES[@]}"; do 

#     # if [[ ! -f $LOG_FILE ]]; then
#     #     echo "There is no file with the name: $LOG_FILE" >&2
#     #     exit 1
#     # fi

#     # if [[ ! -r $file ]]; then 
#     #     echo "You don't have permission to read the file!" >&2
#     #     exit 1
#     # fi 

#     # if [[ ! -w $file ]]; then
#     #     echo "You don't have writable permission!" >&2
#     #     exit 1
#     # fi

#     # shortcut
#     [[ -f "$LOG_FILE" ]] || { echo "Error: Log file missing" >&2; exit 1; }
#     [[ -r "$file" ]] || { echo "Warning: Can't read '$file'" >&2; continue; }
#     [[ -w "$file" ]] || { echo "Warning: No write permission '$file'" >&2; continue; }

#     echo "Found: $file" >> $LOG_FILE

# done 
#     echo "Logging completed"



