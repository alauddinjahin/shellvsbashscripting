#!/bin/bash

# Basic usage
# ls /existing/path
# echo "ls exit code: $?"  # 0 = success

# Conditional execution based on exit code
# mkdir test_dir
# if [ $? -eq 0 ]; then
#     echo "Directory created successfully"
# else
#     echo "Failed to create directory"
# fi


# Chain commands with exit code checking
# grep "INFO" log.txt
# if [ $? -eq 0 ]; then
#     echo "Pattern found"
# elif [ $? -eq 1 ]; then
#     echo "Pattern not found"
# else
#     echo "Error occurred"
# fi

# Set custom exit codes in scripts
# if [ $# -eq 0 ]; then
#     echo "Error: No arguments"
#     exit 1  # Error exit code
# fi
# echo "Success"
# exit 0  # Success exit code

