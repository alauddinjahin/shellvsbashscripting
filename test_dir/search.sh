# Regular Expressions

# grep usage: Pattern searching in files
# sed basics: Stream editor for filtering and transforming
# awk fundamentals: Pattern scanning and processing
# Pattern matching in conditionals: [[ string =~ pattern ]]


# Search for pattern in files
grep "error" logfile.txt
grep -i "error" logfile.txt          # Case-insensitive
grep -n "error" logfile.txt          # Show line numbers
grep -v "debug" logfile.txt          # Invert match (exclude lines)

# Multiple files
grep "TODO" *.py                     # Search in all Python files
grep -r "function" /path/to/code/    # Recursive search

# Extended regex
grep -E "error|warning|fatal" log.txt
grep -E "^[0-9]{3}-[0-9]{2}-[0-9]{4}$" file.txt  # Date pattern


# Context lines
grep -A 3 -B 2 "error" log.txt      # 3 lines after, 2 before
grep -C 2 "pattern" file.txt         # 2 lines context (before and after)

# Count and list files
grep -c "pattern" file.txt           # Count matching lines
grep -l "pattern" *.txt              # List files containing pattern
grep -L "pattern" *.txt              # List files NOT containing pattern

# Word boundaries and anchors
grep -w "test" file.txt              # Match whole word only
grep "^start" file.txt               # Lines starting with "start"
grep "end$" file.txt                 # Lines ending with "end"


# Basic substitution
sed 's/old/new/' file.txt            # Replace first occurrence per line
sed 's/old/new/g' file.txt           # Replace all occurrences (global)
sed 's/old/new/2' file.txt           # Replace only 2nd occurrence per line

# Case-insensitive substitution
sed 's/error/ERROR/gi' file.txt

# Using different delimiters
sed 's|/old/path|/new/path|g' file.txt
sed 's#http://old#https://new#g' file.txt

# Delete lines only as an output not the original ones
sed '/pattern/d' file.txt            # Delete lines matching pattern
sed '5d' file.txt                    # Delete line 5
sed '2,5d' file.txt                  # Delete lines 2-5
sed '$d' file.txt                    # Delete last line

# Insert and append
sed '3i\New line here' file.txt      # Insert before line 3
sed '3a\New line here' file.txt      # Append after line 3

# Print specific lines
sed -n '5,10p' file.txt              # Print only lines 5-10
sed -n '/pattern/p' file.txt         # Print only matching lines


# Multiple commands
sed -e 's/foo/bar/g' -e 's/old/new/g' file.txt
sed 's/foo/bar/g; s/old/new/g' file.txt

# Backreferences
sed 's/\([0-9]\{3\}\)-\([0-9]\{2\}\)-\([0-9]\{4\}\)/\3\/\2\/\1/g' dates.txt
# Converts 123-45-6789 to 6789/45/123

# In-place editing
sed -i 's/old/new/g' file.txt        # Modify file directly
sed -i.bak 's/old/new/g' file.txt    # Create backup first


# awk 'pattern { action }' file
awk '{ print $1, $3 }' file.txt      # Print columns 1 and 3
awk 'NR > 1 { print }' file.txt      # Skip first line
awk 'length($0) > 80' file.txt       # Lines longer than 80 characters

awk '{print NR, NF, $0}' file.txt    # Line number, field count, whole line
awk '{print "Line " NR ": " $1}' file.txt

# Field separator
awk -F: '{print $1, $3}' /etc/passwd # Use colon as separator
awk 'BEGIN{FS=","} {print $2}' file.csv

awk '/pattern/ {print $0}' file.txt  # Print lines matching pattern
awk '$3 ~ /^[0-9]+$/ {print}' file.txt # Third field is numeric
awk '$1 !~ /test/ {print}' file.txt   # First field doesn't contain "test"

# Field-specific patterns
awk '$2 == "active" {print $1}' status.txt
awk '$3 > 100 {print $1, $3}' numbers.txt


# BEGIN and END blocks
awk 'BEGIN{print "Report:"} {total+=$3} END{print "Total:", total}' file.txt

# Arrays and counting
awk '{count[$1]++} END{for(i in count) print i, count[i]}' file.txt

# Mathematical operations
awk '{sum += $2; count++} END {print "Average:", sum/count}' file.txt

# String functions
awk '{print toupper($1), length($2)}' file.txt
awk '{gsub(/old/, "new"); print}' file.txt


email="user@example.com"

if [[ $email =~ ^([a-zA-Z0-9._-]+)@([a-zA-Z0-9.-]+)$ ]]; then
    username="${BASH_REMATCH[1]}"
    domain="${BASH_REMATCH[2]}"
    echo "Username: $username, Domain: $domain"
fi


# Phone number validation
validate_phone() {
    local phone="$1"
    if [[ $phone =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]; then
        echo "Valid phone number"
        return 0
    else
        echo "Invalid phone number format"
        return 1
    fi
}

# IP address validation
validate_ip() {
    local ip="$1"
    local octet="([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"
    if [[ $ip =~ ^$octet\.$octet\.$octet\.$octet$ ]]; then
        echo "Valid IP address"
    else
        echo "Invalid IP address"
    fi
}



log_file="access.log"

echo "=== Log Analysis ==="
echo "Total requests: $(wc -l < "$log_file")"
echo "Unique IPs: $(awk '{print $1}' "$log_file" | sort -u | wc -l)"
echo "404 errors: $(grep " 404 " "$log_file" | wc -l)"

echo -e "\nTop 5 IPs:"
awk '{print $1}' "$log_file" | sort | uniq -c | sort -nr | head -5

echo -e "\nTop requested pages:"
awk '{print $7}' "$log_file" | sort | uniq -c | sort -nr | head -10



# Extract and process CSV data
process_sales_data() {
    local file="$1"
    
    # Skip header, calculate totals by region
    awk -F, '
    NR > 1 {
        region = $2
        sales = $4
        totals[region] += sales
    }
    END {
        print "Sales by Region:"
        for (r in totals) {
            printf "%-15s: $%10.2f\n", r, totals[r]
        }
    }' "$file"
}

# printf "%-15s: $%10.2f\n":
# %-15s: Left-align region name in 15-character width
# %10.2f: Right-align sales with 2 decimal places in 10-character width

# Clean and validate input file
clean_data() {
    sed 's/[[:space:]]*$//' "$1" |           # Remove trailing whitespace
    sed '/^$/d' |                            # Remove empty lines
    awk -F, 'NF == 5 {print}'               # Keep only lines with 5 fields
}

# Convert configuration format
convert_config() {
    sed -E 's/^([^=]+)=(.+)$/export \1="\2"/' old_config.txt > new_config.sh
}

# Extract URLs from HTML
extract_urls() {
    grep -o 'href="[^"]*"' "$1" | # -o: Only outputs matching portion and href="[^"]*": Matches href attributes (anything between quotes)
    sed 's/href="//; s/"//' |
    grep -E '^https?://' |
    sort -u

    # s/href="//: Removes href=" prefix
    # s/"//: Removes trailing quote
    # ^https?://: Matches HTTP/HTTPS URLs only
    # -u: Outputs unique URLs only
}