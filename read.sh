# Get user input interactively from terminal.
# Basic input
# read name  #get input from user
# echo "Hello $name"

# read -p "Enter your age:" age    #-p is displayed text before read
# echo "Your are ${age} years old"



# Command	Option	Effect	Use Case
# read	-p	Shows prompt	User-friendly input
# read	-n	Limits input length	PIN codes, quick confirmations
# echo	-n	No newline	Building output line-by-line


# read -n 3 -p "Enter a 3-letter code: " pincode # limit with -n and it will auto submit after length is fulfilled
# echo -n "Your pin: ${pincode}"

# echo -n "Hello " # bring immediate next echos in a single line with -n
# echo "World" # it will work only but not rest ones
# echo "Jahin"
# echo "How are you?"

# read -n 1 -p "Continue? (y/n): " answer
# printf "\n%s" "You selected: ${answer}"


# Read multiple variables
# read first last
# echo "Name: $first $last"


# Silent input (passwords)
# read -s -p "Password: " passwd
# echo -e "\nPassword entered"

# Read with timeout
# read -t 5 -p "Enter within 5 seconds: " input
# echo "You entered: $input"


# # Read single character
# read -n 1 -p "Press any key: " key
# echo -e "\nYou pressed: $key"

# /read.sh arg0 arg1 arg2 arg3 
# echo "Script name: $0"
# echo "First argument: $1"
# echo "Second argument: $2" 
# echo "Third argument: $3"
# echo "All arguments: $@" 
# echo "Number of arguments: $#"


# for arg in "$@"; do 
#     echo "Arg with no index -> : $arg"
# done


# for ((i=1; i<=$#; i++)); do
#     arg="${!i}"  # Indirect reference to positional parameter
#     echo "Arg $i: $arg"
# done


# args=("$@")  # Store arguments in an array

# for ((i=0; i<${#args[@]}; i++)); do
#     echo "Arg $((i+1)): ${args[i]}"
# done


# i=1
# for arg in "$@"; do
#     echo "Arg $i: $arg"
#     ((i++))
# done




