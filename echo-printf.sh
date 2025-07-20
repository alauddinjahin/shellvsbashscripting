# echo "Hello Bash Lover" # echo auto matically added \n that means new line but you can ignore by adding -n before text after echo
# echo -n "No newline"    # Works in Bash but not all shells
# echo -e "Line1\nLine2"  # Interpretation of escapes, with -e you can escape

# echo $HOME #echo with variable $HOME is a built in variable

# greeting(){
#     echo $1              # $1 received first arg
#     echo $2 "You are genious."
#     echo -e "$2\nYou are genious." # $2 value should show at newline
# }

# greeting "Welcome to bash programming" "Jahin" 27


# in bash function doesn't return value or result

# sum(){
#     return $(($1 + $2))
# }


# result=$(sum 2 50)
# echo $result




# sum 2 5

# $? : will exit the result if you want to hold the result need a variable
# echo $?
# or 
# echo "Sum of 2 and 5 is : $?" # but have limitation, it's not a good practice at all


# sum() {
#     echo $(($1 + $2))
# }
# result=$(sum 2 50)
# echo "The result is: $result"  # Outputs: The result is: 52


# sum() {
#     result=$(($1 + $2))
# }

# sum() {
#     local x=$(($1 + $2))
# }

# sum 2 7
# echo "The result is: $x"  # Outputs: The result is: 
# because you have used local variable to the outside of a function


# Shell functions can only return values 0-255 (1 byte)
# 200 + 56 = 256 becomes 256 % 256 = 0
# sum_broken() {
#     return $(($1 + $2)) # return only work 0-255 
# }

# sum_broken 2 50
# echo "2 + 50 = $?" # Correctly shows "2 + 50 = 52"


# # This fails (256 > 255)
# sum_broken 200 56
# echo "200 + 56 = $?"  # Shows "200 + 56 = 40" (WRONG! 256 wraps to 0, then +56)


# Correct Solution: Using Output

# sum_correct(){
#     echo $(($1 + $2))
# }

# result=$(sum_correct 200 65)
# echo $result


# Approach	Max Value	Correct?	How to Get Result	        Use Case
# return	    255	    ❌ No	    $?	                    Exit codes only
# echo	    Unlimited	✅ Yes	    $(function)	            Arithmetic results


# Success/failure status (0 = success, 1-255 = error codes)
# file_exists() {
#     [ -f "$1" ] && return 0 || return 1
# }

# echo $(file_exists "./loop.sh") # nothing will be returned, because return doesn't capture result

# file_exists() {
#     [ -f "$1" ]
#     # The [ ] command already returns the correct exit status
# }

# file_exists "./loops.sh"
# status=$? # capture status
# if [ $status -eq 0 ]; then
#     echo "File exists"
# else
#     echo "File does not exist (status: $status)"
# fi



# file_exists() {
#     [ -f "$1" ] # Simple test that returns proper exit status
# }

# if file_exists "./loops.sh"; then
#     echo "File exists"
# else
#     echo "File does not exist"
# fi

# Approach	    Returns	        How to Check	Best For
# Exit status	0/1	            $? or if	    Conditional execution

# return vs Output:
# return which sets an exit status (0-255)
# $(...) captures stdout output, not the exit status
# Since your function doesn't echo anything, it captures nothing






# Use printf for:

# More complex formatting
# When you need consistent behavior across shells
# When you need precise control over output
# When writing production scripts


# with printf Format Specifiers Cheatsheet:
# %s - String
# %d - Decimal integer
# %f - Floating point (not in all shells)
# %x - Hexadecimal
# %% - Literal percent sign

# 1. 
# sum(){
#     printf $(($1 + $2))
# }

# result=$(sum 2 10)
# echo $result

# sum() {
#     printf "%d" $(($1 + $2))
# }

# # sum 20 20
# output=$(sum 20 20) # if you assign and capture output from the function values it will not print inside the function
# echo "$output is the sum of 20 + 20" # echo is working here


# file_checker(){
#     [ -f $1 ] #it will return automatic 0 or 1 if the file exists then 1 otherwise 0
#  }

# if file_checker "./loops.sh"; then 
#     printf "File exists\n"
# else 
#     printf "File does not exit"
# fi 


# file_exists() {
#     [ -f "$1" ]
# }

# file_exists "./loops.sh"
# result=$?
# printf "Exist status: $result" #0 means success


# file_exists() {
#     if [ -f "$1" ]; then
#         printf "%s\n" "File exists"
#     else
#         printf "%s\n" "File not found" >&2  # Error to stderr
#     fi
# }

# file_exists "./loop.sh"


# Use >&2 for error messages
# sum_large() {
#     printf "%d\n" "$(($1 + $2))"
# }

# big_result=$(sum_large 1000000 5000000)
# printf "Result: %'d\n" "$big_result"  # Outputs: Result: 6,000,000



# safe_num(){

#     local pattern=^[0-9]+$
#     if ! [[ $1 =~ $pattern ]] || ! [[ $2 =~ $pattern ]]; then 
#         printf "Error: non-numeric arguments found"
#         # printf "Error: non-numeric arguments found" >&2
#         return 1
#     fi

#     printf "%d\n" "$(($1 + $2))"
# }


# safe_num(){

#     local pattern=^[0-9]+$
#     pattern_matcher(){
#         [[ $1 =~ $pattern ]]
#     }

#     if ! pattern_matcher $1  || ! pattern_matcher $2; then 
#         printf "Error: non-numeric arguments found"
#         # printf "Error: non-numeric arguments found" >&2
#         return 1
#     fi

#     printf "%d\n" "$(($1 + $2))"
# }


# result=$(safe_num 100 "01a")
# result2=$(safe_num 100 "01")
# printf "Invalid: $result\n Valid: $result2"


# sumWithReturn(){
#     return $(($1 + $2))
# }

# sumWithReturn 5 2
# r=$?
# echo "5+2=$r"

# f=$(($r + 4))

# printf "%d\n" "$f"




# printf " - %s\n" "Apple" "Banana" "Cherry"
# # echo " - %s\n" "Apple" "Banana" "Cherry" #error you can't format with echo 

# # Leftside 10-character width space
# printf " - %10s\n" "Apple"  # Output: " -      Apple"

# # right side with 10-character width space
# printf " - %-10s\n" "Apple" # Output: " - Apple     "














