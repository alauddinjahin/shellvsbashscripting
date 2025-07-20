#!/bin/bash

# Basic here document
cat <<EOF
This is a here document.
It can contain multiple lines.
Variables like $USER are expanded.
EOF


# Here document with custom delimiter
cat <<DELIMITER
You can use any word as a delimiter.
Just make sure it's unique and appears alone on the final line.
DELIMITER



name="Alice"
age=30

# Variables are expanded by default
cat <<EOF
Hello, $name!
You are $age years old.
Today is $(date +%Y-%m-%d)
EOF

# Prevent variable expansion with quotes
cat <<'EOF'
Hello, $name!
This will print literally: $name
Today is $(date +%Y-%m-%d)
EOF



# Generate configuration files
create_config() {
    cat <<EOF > /etc/myapp.conf
# MyApp Configuration
server_name=$1
port=$2
debug_mode=${3:-false}
log_level=info
EOF
}

# Send email with here document
send_notification() {
    local recipient="$1"
    local subject="$2"
    
    mail -s "$subject" "$recipient" <<EOF
Dear User,

This is an automated notification.
System status: OK
Timestamp: $(date)

Best regards,
System Administrator
EOF
}

# Multi-line SQL query
mysql -u root -p database_name <<SQL
USE mydb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (username, email) VALUES ('john', 'john@example.com');
SQL




# Remove leading tabs with <<-
function generate_script() {
    cat <<-'SCRIPT' > myscript.sh
	#!/bin/bash
	
	echo "Starting process..."
	for i in {1..5}; do
	    echo "Step $i"
	    sleep 1
	done
	echo "Process complete"
	SCRIPT
    
    chmod +x myscript.sh
}


cat <<NOTICE
=========================
IMPORTANT: Backup required
=========================
NOTICE

# Best Practices
# Choose delimiters that won't appear in your text (e.g., __EOF__ for complex content)
# Use quoted delimiters (<<'MARKER') when you need literal text
# Indent content for readability (Bash 4.0+ supports <<-EOF with tab stripping)