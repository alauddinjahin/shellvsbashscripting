# String Manipulation

# String length: ${#string}
# Substring extraction: ${string:position:length}
# String replacement: ${string/pattern/replacement}
# Case conversion: ${string^^}, ${string,,}


text="Hello World"
echo ${#text}           # 11

# Works with variables
name="Alice"
echo ${#name}           # 5

# Useful for validation
if [ ${#password} -lt 8 ]; then
    echo "Password too short"
fi


text="Hello World"

# ${string:position:length}
echo ${text:0:5}        # "Hello" (start at 0, length 5)
echo ${text:6:5}        # "World" (start at 6, length 5)
echo ${text:6}          # "World" (from position 6 to end)

# Negative positions (Bash 4.2+)
echo ${text: -5}        # "World" (last 5 characters, note the space)
echo ${text: -5:3}      # "Wor" (from 5th-to-last, length 3)

# From end
echo ${text:0:-6}       # "Hello" (from start, excluding last 6)


text="Hello World World"
echo ${text/World/Universe}     # "Hello Universe World" (first match only)
echo ${text//World/Universe}    # "Hello Universe Universe" (all matches)


filename="document.pdf"
echo ${filename%.*}             # "document" (remove shortest match from end)
echo ${filename%%.*}            # "document" (remove longest match from end)

path="/home/user/documents/file.txt"
echo ${path#*/}                 # "home/user/documents/file.txt" (remove shortest from start)
echo ${path##*/}                # "file.txt" (remove longest from start - basename)
echo ${path%/*}                 # "/home/user/documents" (dirname equivalent)


text="abc123def456"
echo ${text//[0-9]/X}           # "abcXXXdefXXX" (replace all digits)
echo ${text//[^0-9]/}           # "123456" (keep only digits)


text="Hello World"
echo ${text^^}          # "HELLO WORLD" (all uppercase)
echo ${text,,}          # "hello world" (all lowercase)

# First character only
echo ${text^}           # "Hello World" (first char uppercase)
echo ${text,}           # "hello World" (first char lowercase)

# Specific patterns
mixed="hELLo WoRLd"
echo ${mixed^^[hw]}     # "HELLo WoRLd" (uppercase h and w)
echo ${mixed,,[EL]}     # "hello World" (lowercase E and L)


# ${variable:-default} - use default if variable is unset or empty
echo ${name:-"Anonymous"}

# ${variable:=default} - assign default if variable is unset or empty
echo ${USER:=nobody}

# ${variable:+alternate} - use alternate if variable is set
echo ${HOME:+"Home is set"}


# Check if variable is set and non-empty
${variable:?error message}
# Example
filename=${1:?"Please provide a filename"}


files=("document.txt" "image.jpg" "script.sh")

# Remove extensions from all files
names=("${files[@]%.*}")
echo "${names[@]}"      # "document image script"

# Convert to uppercase
upper=("${files[@]^^}")
echo "${upper[@]}"      # "DOCUMENT.TXT IMAGE.JPG SCRIPT.SH"


filepath="/home/user/documents/report.pdf"

directory=${filepath%/*}        # "/home/user/documents"
filename=${filepath##*/}        # "report.pdf"
basename=${filename%.*}         # "report"
extension=${filename##*.}       # "pdf"

echo "Dir: $directory, File: $basename, Ext: $extension"


clean_input() {
    local input="$1"
    # Remove leading/trailing whitespace and convert to lowercase
    input="${input#"${input%%[![:space:]]*}"}"  # Remove leading whitespace
    input="${input%"${input##*[![:space:]]}"}"  # Remove trailing whitespace
    echo "${input,,}"
}

user_input="  Hello World  "
cleaned=$(clean_input "$user_input")
echo "'$cleaned'"       # "'hello world'"



url="https://example.com:8080/path/to/page?param=value"

# Extract components
protocol=${url%%://*}           # "https"
temp=${url#*://}               # "example.com:8080/path/to/page?param=value"
host=${temp%%/*}               # "example.com:8080"
path=${temp#*/}                # "path/to/page?param=value"

echo "Protocol: $protocol, Host: $host, Path: $path"