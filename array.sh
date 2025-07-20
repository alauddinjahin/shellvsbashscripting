#!/bin/bash

# Method 1: Direct assignment
arr=(apple banana cherry)

# Method 2: Individual assignment
arr[0]="apple"
arr[1]="banana"
arr[2]="cherry"

# Method 3: Empty array
arr=()


echo ${arr[0]}        # First element
echo ${arr[2]}        # Third element
echo ${arr[@]}        # All elements
echo ${arr[*]}        # All elements (different quoting behavior)
echo ${#arr[@]}       # Array length

arr=(one two three four)
echo ${#arr[@]}       # Number of elements: 4
echo ${#arr[2]}       # Length of element at index 2: 5 ("three")


arr+=(new_element)    # Append single element
arr+=(elem1 elem2)    # Append multiple elements
arr[${#arr[@]}]=new   # Manual append


arr=(a b c d e f)
echo ${arr[@]:2:3}    # Elements from index 2, count 3: "c d e"
echo ${arr[@]:1}      # Elements from index 1 to end: "b c d e f"


# Method 1: For loop with elements
for item in "${arr[@]}"; do
    echo "$item"
done

# Method 2: For loop with indices
for i in "${!arr[@]}"; do
    echo "Index $i: ${arr[$i]}"
done

declare -A assoc_arr
assoc_arr[key1]="value1"
assoc_arr[key2]="value2"

# Or initialize directly
declare -A colors=([red]="#FF0000" [green]="#00FF00" [blue]="#0000FF")

echo ${assoc_arr[key1]}     # Access by key
echo ${assoc_arr[@]}        # All values
echo ${!assoc_arr[@]}       # All keys
echo ${#assoc_arr[@]}       # Number of key-value pairs

# Check if key exists
if [[ -v assoc_arr[key1] ]]; then
    echo "Key exists"
fi

# -v checks existence, while:
# -z checks if a variable/array element is empty ("").
# -n checks if it is non-empty.


# IFS=',' read -ra arr <<< "one,two,three"

# arr=(1 2 3 4 5)
# unset arr[2]              # Remove element at index 2
# arr=("${arr[@]:0:2}" "${arr[@]:3}")  # Remove and compact
# Remove elements
# unset arr[1]          # Remove element at index 1
# unset arr             # Remove entire array

# # Replace/substitute
# echo ${arr[@]/old/new}  # Replace 'old' with 'new' in all elements

