# Dynamic programming: Complex algorithm implementation
# State machines: Implementing stateful logic
# Protocol implementation: Custom protocol handling
# Embedded systems: Resource-constrained environments



#!/bin/bash

# =============================================================================
# DEVELOPMENT ENVIRONMENT AUTOMATION SCRIPTS
# =============================================================================
# This collection provides comprehensive bash scripts for:
# 1. Environment setup automation
# 2. Data processing utilities
# 3. CSV file manipulation
# 4. JSON data handling
# 5. Database operations
# 6. API integration tools
# =============================================================================

# =============================================================================
# 1. ENVIRONMENT SETUP AUTOMATION
# =============================================================================

setup_development_environment() {
    echo "=== Development Environment Setup ==="
    
    # Set up logging
    LOG_FILE="/tmp/env_setup_$(date +%Y%m%d_%H%M%S).log"
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$LOG_FILE" >&2)
    
    echo "Starting environment setup at $(date)"
    echo "Log file: $LOG_FILE"
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        PACKAGE_MANAGER="apt"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PACKAGE_MANAGER="brew"
    else
        echo "Unsupported OS: $OSTYPE"
        return 1
    fi
    
    echo "Detected OS: $OS"
    
    # Update system packages
    echo "Updating system packages..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt update && sudo apt upgrade -y
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew update && brew upgrade
    fi
    
    # Install essential development tools
    echo "Installing development tools..."
    TOOLS=(
        "git"
        "curl"
        "wget"
        "jq"           # JSON processor
        "sqlite3"      # SQLite database
        "python3"      # Python
        "nodejs"       # Node.js
        "docker"       # Docker
    )
    
    for tool in "${TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Installing $tool..."
            if [[ "$OS" == "linux" ]]; then
                sudo apt install -y "$tool"
            elif [[ "$OS" == "macos" ]]; then
                brew install "$tool"
            fi
        else
            echo "$tool already installed"
        fi
    done
    
    # Set up Python virtual environment
    echo "Setting up Python virtual environment..."
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install --upgrade pip
    pip install pandas requests sqlalchemy psycopg2-binary mysql-connector-python
    
    # Set up Git configuration
    echo "Configuring Git..."
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    
    # Create project directory structure
    echo "Creating project structure..."
    mkdir -p {src,tests,docs,data/{raw,processed,output},scripts,logs,config}
    
    # Create .env template
    cat > .env.template << 'EOF'
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=username
DB_PASSWORD=password

# API Configuration
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here

# Environment
ENVIRONMENT=development
LOG_LEVEL=INFO
EOF
    
    echo "Environment setup completed successfully!"
    echo "Log saved to: $LOG_FILE"
}

# =============================================================================
# 2. DATA PROCESSING UTILITIES
# =============================================================================

process_data_files() {
    local source_dir="${1:-./data/raw}"
    local output_dir="${2:-./data/processed}"
    local log_file="${3:-./logs/data_processing_$(date +%Y%m%d_%H%M%S).log}"
    
    echo "=== Data Processing Utilities ==="
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    mkdir -p "$(dirname "$log_file")"
    
    # Initialize log
    exec 3>&1 4>&2
    exec 1> >(tee -a "$log_file")
    exec 2> >(tee -a "$log_file" >&2)
    
    echo "Starting data processing at $(date)"
    echo "Source directory: $source_dir"
    echo "Output directory: $output_dir"
    
    # Check if source directory exists
    if [[ ! -d "$source_dir" ]]; then
        echo "Error: Source directory '$source_dir' does not exist"
        return 1
    fi
    
    # Process different file types
    local processed_count=0
    local error_count=0
    
    # Find all data files
    find "$source_dir" -type f \( -name "*.csv" -o -name "*.json" -o -name "*.txt" -o -name "*.log" \) | while read -r file; do
        echo "Processing: $file"
        
        filename=$(basename "$file")
        extension="${filename##*.}"
        basename_no_ext="${filename%.*}"
        
        case "$extension" in
            "csv")
                # Process CSV files
                if process_csv_file "$file" "$output_dir/${basename_no_ext}_processed.csv"; then
                    ((processed_count++))
                else
                    ((error_count++))
                fi
                ;;
            "json")
                # Process JSON files
                if process_json_file "$file" "$output_dir/${basename_no_ext}_processed.json"; then
                    ((processed_count++))
                else
                    ((error_count++))
                fi
                ;;
            "txt"|"log")
                # Process text/log files
                if process_text_file "$file" "$output_dir/${basename_no_ext}_processed.txt"; then
                    ((processed_count++))
                else
                    ((error_count++))
                fi
                ;;
        esac
    done
    
    echo "Data processing completed at $(date)"
    echo "Files processed: $processed_count"
    echo "Errors: $error_count"
    
    # Restore original stdout/stderr
    exec 1>&3 2>&4
    exec 3>&- 4>&-
}

# =============================================================================
# 3. CSV PROCESSING FUNCTIONS
# =============================================================================

process_csv_file() {
    local input_file="$1"
    local output_file="$2"
    
    echo "Processing CSV file: $input_file"
    
    # Validate CSV file
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found"
        return 1
    fi
    
    # Check if file is actually CSV
    if ! head -n 1 "$input_file" | grep -q ","; then
        echo "Warning: File may not be in CSV format"
    fi
    
    # Create temporary file for processing
    local temp_file=$(mktemp)
    
    # Remove empty lines and normalize line endings
    sed '/^[[:space:]]*$/d' "$input_file" | tr -d '\r' > "$temp_file"
    
    # Add row numbers
    awk 'BEGIN{OFS=","} NR==1{print "row_id", $0; next} {print NR-1, $0}' "$temp_file" > "$output_file"
    
    # Clean up
    rm "$temp_file"
    
    echo "CSV processing completed: $output_file"
    return 0
}

csv_statistics() {
    local csv_file="$1"
    
    if [[ ! -f "$csv_file" ]]; then
        echo "Error: CSV file '$csv_file' not found"
        return 1
    fi
    
    echo "=== CSV File Statistics ==="
    echo "File: $csv_file"
    echo "Total rows: $(wc -l < "$csv_file")"
    echo "Header row: $(head -n 1 "$csv_file")"
    echo "Number of columns: $(head -n 1 "$csv_file" | tr ',' '\n' | wc -l)"
    echo "File size: $(du -h "$csv_file" | cut -f1)"
    echo "Last modified: $(stat -c %y "$csv_file" 2>/dev/null || stat -f %Sm "$csv_file")"
}

csv_filter() {
    local input_file="$1"
    local column_name="$2"
    local filter_value="$3"
    local output_file="$4"
    
    if [[ $# -ne 4 ]]; then
        echo "Usage: csv_filter <input_file> <column_name> <filter_value> <output_file>"
        return 1
    fi
    
    # Get column index
    local column_index=$(head -n 1 "$input_file" | tr ',' '\n' | nl -v 0 | grep -w "$column_name" | cut -f1)
    
    if [[ -z "$column_index" ]]; then
        echo "Error: Column '$column_name' not found"
        return 1
    fi
    
    # Filter CSV
    awk -v col="$column_index" -v val="$filter_value" -F',' 'NR==1 || $col==val' "$input_file" > "$output_file"
    
    echo "Filtered CSV created: $output_file"
}

# =============================================================================
# 4. JSON HANDLING FUNCTIONS
# =============================================================================

process_json_file() {
    local input_file="$1"
    local output_file="$2"
    
    echo "Processing JSON file: $input_file"
    
    # Validate JSON file
    if ! jq empty "$input_file" 2>/dev/null; then
        echo "Error: Invalid JSON file '$input_file'"
        return 1
    fi
    
    # Pretty print and add metadata
    jq '. + {
        "processed_at": now | strftime("%Y-%m-%d %H:%M:%S"),
        "source_file": "'$(basename "$input_file")'",
        "record_count": (if type == "array" then length else 1 end)
    }' "$input_file" > "$output_file"
    
    echo "JSON processing completed: $output_file"
    return 0
}

json_extract() {
    local json_file="$1"
    local jq_query="${2:-.}"
    local output_file="$3"
    
    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file '$json_file' not found"
        return 1
    fi
    
    if [[ -n "$output_file" ]]; then
        jq "$jq_query" "$json_file" > "$output_file"
        echo "Extracted data saved to: $output_file"
    else
        jq "$jq_query" "$json_file"
    fi
}

json_to_csv() {
    local json_file="$1"
    local output_file="$2"
    
    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file '$json_file' not found"
        return 1
    fi
    
    # Convert JSON array to CSV
    if jq -e 'type == "array"' "$json_file" > /dev/null; then
        jq -r '(.[0] | keys_unsorted) as $keys | $keys, (.[] as $row | $keys | map($row[.])) | @csv' "$json_file" > "$output_file"
    else
        jq -r '[keys_unsorted[] as $k | {key: $k, value: .[$k]}] | (.[0] | keys_unsorted), (.[] | [.key, .value]) | @csv' "$json_file" > "$output_file"
    fi
    
    echo "JSON converted to CSV: $output_file"
}

# =============================================================================
# 5. DATABASE OPERATIONS
# =============================================================================

execute_sql_script() {
    local db_type="$1"
    local connection_string="$2"
    local sql_script="$3"
    local log_file="${4:-./logs/sql_execution_$(date +%Y%m%d_%H%M%S).log}"
    
    echo "=== SQL Script Execution ==="
    
    # Create log directory
    mkdir -p "$(dirname "$log_file")"
    
    # Validate inputs
    if [[ ! -f "$sql_script" ]]; then
        echo "Error: SQL script '$sql_script' not found"
        return 1
    fi
    
    echo "Executing SQL script: $sql_script" | tee -a "$log_file"
    echo "Database type: $db_type" | tee -a "$log_file"
    echo "Started at: $(date)" | tee -a "$log_file"
    
    case "$db_type" in
        "sqlite")
            sqlite3 "$connection_string" < "$sql_script" 2>&1 | tee -a "$log_file"
            ;;
        "mysql")
            mysql -h "${connection_string%/*}" -u "$DB_USER" -p"$DB_PASSWORD" "${connection_string##*/}" < "$sql_script" 2>&1 | tee -a "$log_file"
            ;;
        "postgresql")
            psql "$connection_string" -f "$sql_script" 2>&1 | tee -a "$log_file"
            ;;
        *)
            echo "Error: Unsupported database type '$db_type'"
            return 1
            ;;
    esac
    
    local exit_code=$?
    echo "Completed at: $(date)" | tee -a "$log_file"
    echo "Exit code: $exit_code" | tee -a "$log_file"
    
    return $exit_code
}

backup_database() {
    local db_type="$1"
    local connection_string="$2"
    local backup_dir="${3:-./backups}"
    
    mkdir -p "$backup_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    case "$db_type" in
        "sqlite")
            cp "$connection_string" "$backup_dir/backup_$timestamp.sqlite"
            ;;
        "mysql")
            mysqldump -h "${connection_string%/*}" -u "$DB_USER" -p"$DB_PASSWORD" "${connection_string##*/}" > "$backup_dir/backup_$timestamp.sql"
            ;;
        "postgresql")
            pg_dump "$connection_string" > "$backup_dir/backup_$timestamp.sql"
            ;;
    esac
    
    echo "Database backup created: $backup_dir/backup_$timestamp.*"
}

# =============================================================================
# 6. API INTEGRATION FUNCTIONS
# =============================================================================

api_request() {
    local method="${1^^}"
    local url="$2"
    local data="$3"
    local headers="$4"
    local output_file="$5"
    local log_file="${6:-./logs/api_requests_$(date +%Y%m%d_%H%M%S).log}"
    
    echo "=== API Request ==="
    
    # Create log directory
    mkdir -p "$(dirname "$log_file")"
    
    # Build curl command
    local curl_cmd="curl -s -w '\nHTTP_STATUS:%{http_code}\nTIME_TOTAL:%{time_total}\n'"
    
    # Add method
    curl_cmd="$curl_cmd -X $method"
    
    # Add headers
    if [[ -n "$headers" ]]; then
        while IFS= read -r header; do
            curl_cmd="$curl_cmd -H '$header'"
        done <<< "$headers"
    fi
    
    # Add data for POST/PUT requests
    if [[ "$method" == "POST" || "$method" == "PUT" ]] && [[ -n "$data" ]]; then
        curl_cmd="$curl_cmd -d '$data'"
    fi
    
    # Add URL
    curl_cmd="$curl_cmd '$url'"
    
    # Log the request
    echo "$(date): $method $url" >> "$log_file"
    
    # Execute request
    local response
    if [[ -n "$output_file" ]]; then
        response=$(eval "$curl_cmd" | tee "$output_file")
    else
        response=$(eval "$curl_cmd")
    fi
    
    # Parse response
    local body=$(echo "$response" | sed '/^HTTP_STATUS:/,$d')
    local http_status=$(echo "$response" | grep '^HTTP_STATUS:' | cut -d: -f2)
    local time_total=$(echo "$response" | grep '^TIME_TOTAL:' | cut -d: -f2)
    
    # Log response details
    echo "$(date): Response Status: $http_status, Time: ${time_total}s" >> "$log_file"
    
    # Output response
    if [[ -z "$output_file" ]]; then
        echo "$body"
    fi
    
    # Return appropriate exit code based on HTTP status
    if [[ "$http_status" -ge 200 && "$http_status" -lt 300 ]]; then
        return 0
    else
        return 1
    fi
}

api_batch_requests() {
    local config_file="$1"
    local output_dir="${2:-./data/api_responses}"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file '$config_file' not found"
        return 1
    fi
    
    mkdir -p "$output_dir"
    
    echo "=== Batch API Requests ==="
    echo "Config file: $config_file"
    echo "Output directory: $output_dir"
    
    local request_count=0
    local success_count=0
    
    # Read config file (JSON format expected)
    jq -c '.[]' "$config_file" | while read -r request; do
        ((request_count++))
        
        local method=$(echo "$request" | jq -r '.method // "GET"')
        local url=$(echo "$request" | jq -r '.url')
        local data=$(echo "$request" | jq -r '.data // empty')
        local headers=$(echo "$request" | jq -r '.headers[]? // empty')
        local output_file="$output_dir/response_$request_count.json"
        
        echo "Processing request $request_count: $method $url"
        
        if api_request "$method" "$url" "$data" "$headers" "$output_file"; then
            ((success_count++))
            echo "Success: $output_file"
        else
            echo "Failed: Request $request_count"
        fi
        
        # Add delay between requests
        sleep 1
    done
    
    echo "Batch processing completed: $success_count/$request_count successful"
}

# =============================================================================
# TEXT FILE PROCESSING (Helper function)
# =============================================================================

process_text_file() {
    local input_file="$1"
    local output_file="$2"
    
    echo "Processing text file: $input_file"
    
    # Basic text processing: remove empty lines, normalize whitespace
    sed '/^[[:space:]]*$/d' "$input_file" | \
    sed 's/[[:space:]]\+/ /g' | \
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' > "$output_file"
    
    # Add metadata
    {
        echo "# Processed on: $(date)"
        echo "# Source: $(basename "$input_file")"
        echo "# Lines: $(wc -l < "$output_file")"
        echo ""
        cat "$output_file"
    } > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"
    
    echo "Text processing completed: $output_file"
    return 0
}

# =============================================================================
# MAIN EXECUTION FUNCTIONS
# =============================================================================

show_help() {
    cat << 'EOF'
Development Environment Automation Scripts

Usage: source this_script.sh

Available functions:

1. Environment Setup:
   setup_development_environment    - Complete dev environment setup

2. Data Processing:
   process_data_files <source_dir> <output_dir> <log_file>
   
3. CSV Operations:
   process_csv_file <input> <output>
   csv_statistics <csv_file>
   csv_filter <input> <column> <value> <output>

4. JSON Operations:
   process_json_file <input> <output>
   json_extract <json_file> <jq_query> [output_file]
   json_to_csv <json_file> <output_file>

5. Database Operations:
   execute_sql_script <db_type> <connection> <script> [log_file]
   backup_database <db_type> <connection> [backup_dir]

6. API Integration:
   api_request <method> <url> [data] [headers] [output_file] [log_file]
   api_batch_requests <config_file> [output_dir]

Examples:
   setup_development_environment
   csv_statistics data/sample.csv
   json_extract data/api_response.json '.results[]'
   api_request GET "https://api.github.com/users/octocat"
EOF
}

# Load environment variables if .env exists
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
    echo "Loaded environment variables from .env"
fi

# If script is executed directly (not sourced), show help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_help
fi



#!/bin/bash

# =============================================================================
# LEVEL 10: MASTERY & SPECIALIZATION
# Advanced Bash Scripting Examples
# =============================================================================

# =============================================================================
# 27. ADVANCED SYSTEM INTEGRATION
# =============================================================================

# -----------------------------------------------------------------------------
# Container Orchestration - Docker Management
# -----------------------------------------------------------------------------
manage_containers() {
    echo "=== Docker Container Management ==="
    
    # Build and deploy application
    cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
EOF
    
    # Docker management functions
    docker_build() {
        local image_name="$1"
        local tag="${2:-latest}"
        docker build -t "${image_name}:${tag}" .
    }
    
    docker_deploy() {
        local image="$1"
        local port="${2:-8080}"
        docker run -d -p "${port}:80" --name "app-$(date +%s)" "$image"
    }
    
    # Kubernetes deployment script
    cat > k8s-deploy.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:latest
        ports:
        - containerPort: 80
EOF
    
    kubectl apply -f k8s-deploy.yaml
}

# -----------------------------------------------------------------------------
# Cloud Automation - AWS Integration
# -----------------------------------------------------------------------------
aws_automation() {
    echo "=== AWS Cloud Automation ==="
    
    # EC2 instance management
    launch_ec2() {
        local instance_type="${1:-t2.micro}"
        local ami_id="${2:-ami-0abcdef1234567890}"
        
        aws ec2 run-instances \
            --image-id "$ami_id" \
            --instance-type "$instance_type" \
            --key-name "my-keypair" \
            --security-group-ids "sg-12345678" \
            --subnet-id "subnet-12345678" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=AutoLaunched}]"
    }
    
    # S3 backup automation
    s3_backup() {
        local source_dir="$1"
        local bucket="$2"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        
        tar -czf "backup_${timestamp}.tar.gz" "$source_dir"
        aws s3 cp "backup_${timestamp}.tar.gz" "s3://${bucket}/backups/"
        rm "backup_${timestamp}.tar.gz"
    }
    
    # Auto-scaling based on CloudWatch metrics
    auto_scale() {
        local asg_name="$1"
        local cpu_threshold=70
        
        current_cpu=$(aws cloudwatch get-metric-statistics \
            --namespace "AWS/EC2" \
            --metric-name "CPUUtilization" \
            --start-time "$(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S)" \
            --end-time "$(date -u +%Y-%m-%dT%H:%M:%S)" \
            --period 300 \
            --statistics Average \
            --query 'Datapoints[0].Average' \
            --output text)
        
        if (( $(echo "$current_cpu > $cpu_threshold" | bc -l) )); then
            aws autoscaling set-desired-capacity \
                --auto-scaling-group-name "$asg_name" \
                --desired-capacity 3
        fi
    }
}

# -----------------------------------------------------------------------------
# Infrastructure as Code - Terraform Integration
# -----------------------------------------------------------------------------
terraform_integration() {
    echo "=== Terraform Integration ==="
    
    # Generate Terraform configuration
    generate_tf_config() {
        cat > main.tf << 'EOF'
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name = "WebServer"
    Environment = var.environment
  }
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}
EOF
    }
    
    # Terraform workflow automation
    tf_deploy() {
        local env="$1"
        
        echo "Initializing Terraform..."
        terraform init
        
        echo "Planning deployment for $env..."
        terraform plan -var="environment=$env" -out="$env.tfplan"
        
        echo "Applying changes..."
        terraform apply "$env.tfplan"
        
        echo "Cleaning up plan file..."
        rm "$env.tfplan"
    }
    
    # Infrastructure validation
    validate_infrastructure() {
        terraform validate
        terraform fmt -check
        
        # Check for security issues
        if command -v tfsec &> /dev/null; then
            tfsec .
        fi
    }
}

# -----------------------------------------------------------------------------
# Monitoring Integration - Prometheus & Grafana
# -----------------------------------------------------------------------------
monitoring_setup() {
    echo "=== Monitoring Integration ==="
    
    # Prometheus configuration
    setup_prometheus() {
        cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'app_metrics'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: /metrics
    scrape_interval: 5s
EOF
        
        # Start Prometheus
        docker run -d -p 9090:9090 \
            -v "$PWD/prometheus.yml:/etc/prometheus/prometheus.yml" \
            prom/prometheus
    }
    
    # Custom metrics exporter
    create_metrics_exporter() {
        cat > metrics_exporter.sh << 'EOF'
#!/bin/bash
# Simple metrics exporter for custom application

METRICS_PORT=8080
METRICS_PATH="/tmp/metrics"

generate_metrics() {
    {
        echo "# HELP app_requests_total Total number of requests"
        echo "# TYPE app_requests_total counter"
        echo "app_requests_total $(cat /tmp/request_count 2>/dev/null || echo 0)"
        
        echo "# HELP app_cpu_usage CPU usage percentage"
        echo "# TYPE app_cpu_usage gauge"
        echo "app_cpu_usage $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')"
        
        echo "# HELP app_memory_usage Memory usage in MB"
        echo "# TYPE app_memory_usage gauge"
        echo "app_memory_usage $(free -m | awk 'NR==2{print $3}')"
    } > "$METRICS_PATH"
}

# Simple HTTP server for metrics
serve_metrics() {
    while true; do
        generate_metrics
        echo -e "HTTP/1.1 200 OK\nContent-Type: text/plain\n\n$(cat $METRICS_PATH)" | nc -l -p $METRICS_PORT -q 1
    done
}

serve_metrics &
EOF
        chmod +x metrics_exporter.sh
        ./metrics_exporter.sh &
    }
    
    # Grafana dashboard provisioning
    setup_grafana_dashboard() {
        cat > dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(app_requests_total[1m])",
            "legendFormat": "Requests/sec"
          }
        ]
      },
      {
        "title": "CPU Usage",
        "type": "singlestat",
        "targets": [
          {
            "expr": "app_cpu_usage",
            "legendFormat": "CPU %"
          }
        ]
      }
    ]
  }
}
EOF
    }
}

# =============================================================================
# 28. PERFORMANCE & SCALABILITY
# =============================================================================

# -----------------------------------------------------------------------------
# Parallel Processing - Background Job Management
# -----------------------------------------------------------------------------
parallel_processing() {
    echo "=== Parallel Processing ==="
    
    # Job queue manager
    declare -a job_queue=()
    declare -a active_jobs=()
    MAX_CONCURRENT_JOBS=4
    
    add_job() {
        local job_command="$1"
        job_queue+=("$job_command")
        echo "Job added to queue: $job_command"
    }
    
    process_jobs() {
        while [ ${#job_queue[@]} -gt 0 ] || [ ${#active_jobs[@]} -gt 0 ]; do
            # Clean up finished jobs
            for i in "${!active_jobs[@]}"; do
                local pid="${active_jobs[$i]}"
                if ! kill -0 "$pid" 2>/dev/null; then
                    wait "$pid"
                    echo "Job $pid completed with status $?"
                    unset "active_jobs[$i]"
                fi
            done
            active_jobs=("${active_jobs[@]}")  # Reindex array
            
            # Start new jobs if slots available
            while [ ${#active_jobs[@]} -lt $MAX_CONCURRENT_JOBS ] && [ ${#job_queue[@]} -gt 0 ]; do
                local job="${job_queue[0]}"
                job_queue=("${job_queue[@]:1}")  # Remove first element
                
                eval "$job" &
                local new_pid=$!
                active_jobs+=("$new_pid")
                echo "Started job $new_pid: $job"
            done
            
            sleep 1
        done
    }
    
    # Parallel file processing example
    parallel_file_processing() {
        local input_dir="$1"
        local output_dir="$2"
        
        mkdir -p "$output_dir"
        
        for file in "$input_dir"/*; do
            if [ -f "$file" ]; then
                add_job "process_file '$file' '$output_dir/$(basename "$file").processed'"
            fi
        done
        
        process_jobs
    }
    
    process_file() {
        local input="$1"
        local output="$2"
        
        # Simulate intensive processing
        echo "Processing $input..."
        sleep $((RANDOM % 5 + 1))
        cp "$input" "$output"
        echo "Completed processing $input"
    }
}

# -----------------------------------------------------------------------------
# Load Balancing - Task Distribution
# -----------------------------------------------------------------------------
load_balancing() {
    echo "=== Load Balancing ==="
    
    # Simple round-robin load balancer
    declare -a servers=("server1:8080" "server2:8080" "server3:8080")
    current_server=0
    
    get_next_server() {
        local server="${servers[$current_server]}"
        current_server=$(((current_server + 1) % ${#servers[@]}))
        echo "$server"
    }
    
    # Health check for servers
    check_server_health() {
        local server="$1"
        local host="${server%:*}"
        local port="${server#*:}"
        
        if timeout 5 bash -c "</dev/tcp/$host/$port"; then
            return 0
        else
            return 1
        fi
    }
    
    # Weighted load balancing
    declare -A server_weights=(["server1:8080"]=3 ["server2:8080"]=2 ["server3:8080"]=1)
    
    weighted_server_selection() {
        local total_weight=0
        local weighted_servers=()
        
        for server in "${!server_weights[@]}"; do
            if check_server_health "$server"; then
                local weight="${server_weights[$server]}"
                for ((i=0; i<weight; i++)); do
                    weighted_servers+=("$server")
                done
                total_weight=$((total_weight + weight))
            fi
        done
        
        if [ $total_weight -gt 0 ]; then
            local random_index=$((RANDOM % total_weight))
            echo "${weighted_servers[$random_index]}"
        else
            echo "No healthy servers available"
            return 1
        fi
    }
    
    # Proxy request to selected server
    proxy_request() {
        local path="$1"
        local server
        
        server=$(weighted_server_selection)
        if [ $? -eq 0 ]; then
            echo "Routing request to: $server$path"
            curl -s "http://$server$path"
        else
            echo "Service unavailable"
            return 503
        fi
    }
}

# -----------------------------------------------------------------------------
# Resource Optimization
# -----------------------------------------------------------------------------
resource_optimization() {
    echo "=== Resource Optimization ==="
    
    # Memory-efficient file processing
    process_large_file_efficiently() {
        local file="$1"
        local chunk_size=1024
        
        # Process file in chunks to minimize memory usage
        while IFS= read -r -n $chunk_size chunk || [ -n "$chunk" ]; do
            # Process chunk without loading entire file into memory
            echo "$chunk" | process_chunk
        done < "$file"
    }
    
    process_chunk() {
        # Simulate chunk processing
        wc -c
    }
    
    # CPU usage monitoring and throttling
    cpu_throttling() {
        local max_cpu_percent=80
        local pid="${1:-$$}"
        
        monitor_and_throttle() {
            while kill -0 "$pid" 2>/dev/null; do
                local cpu_usage
                cpu_usage=$(ps -o %cpu= -p "$pid" | tr -d ' ')
                
                if (( $(echo "$cpu_usage > $max_cpu_percent" | bc -l) )); then
                    echo "High CPU usage ($cpu_usage%), throttling process $pid"
                    kill -STOP "$pid"
                    sleep 1
                    kill -CONT "$pid"
                fi
                
                sleep 5
            done
        }
        
        monitor_and_throttle &
    }
    
    # Memory leak detection
    memory_monitor() {
        local pid="$1"
        local threshold_mb=500
        
        while kill -0 "$pid" 2>/dev/null; do
            local mem_usage
            mem_usage=$(ps -o rss= -p "$pid" | tr -d ' ')
            mem_usage_mb=$((mem_usage / 1024))
            
            echo "Process $pid memory usage: ${mem_usage_mb}MB"
            
            if [ $mem_usage_mb -gt $threshold_mb ]; then
                echo "WARNING: Process $pid exceeding memory threshold"
                # Log stack trace or take corrective action
            fi
            
            sleep 10
        done
    }
}

# -----------------------------------------------------------------------------
# Scalable Architectures
# -----------------------------------------------------------------------------
scalable_architecture() {
    echo "=== Scalable Architecture Design ==="
    
    # Microservice orchestration
    start_microservices() {
        local services=("auth-service" "user-service" "order-service" "notification-service")
        
        for service in "${services[@]}"; do
            echo "Starting $service..."
            
            # Start service in background
            (
                cd "$service" || exit 1
                ./start.sh
            ) &
            
            echo "$!" > "/tmp/${service}.pid"
        done
        
        # Wait for all services to be healthy
        wait_for_services_ready
    }
    
    wait_for_services_ready() {
        local services=("auth-service:8001" "user-service:8002" "order-service:8003")
        local max_wait=60
        local waited=0
        
        while [ $waited -lt $max_wait ]; do
            local all_ready=true
            
            for service in "${services[@]}"; do
                local host="${service%:*}"
                local port="${service#*:}"
                
                if ! timeout 2 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
                    all_ready=false
                    break
                fi
            done
            
            if [ "$all_ready" = true ]; then
                echo "All services are ready!"
                return 0
            fi
            
            echo "Waiting for services to be ready... (${waited}s)"
            sleep 5
            waited=$((waited + 5))
        done
        
        echo "Services failed to start within timeout"
        return 1
    }
    
    # Circuit breaker pattern implementation
    declare -A circuit_states=()
    declare -A failure_counts=()
    
    circuit_breaker() {
        local service="$1"
        local command="$2"
        local failure_threshold=3
        local timeout=30
        
        # Check circuit state
        local state="${circuit_states[$service]:-CLOSED}"
        local failures="${failure_counts[$service]:-0}"
        
        case $state in
            "OPEN")
                echo "Circuit breaker OPEN for $service"
                return 1
                ;;
            "HALF_OPEN")
                echo "Circuit breaker HALF_OPEN for $service, testing..."
                ;;
            "CLOSED")
                echo "Circuit breaker CLOSED for $service"
                ;;
        esac
        
        # Execute command
        if eval "$command"; then
            # Success - reset failure count and close circuit
            failure_counts[$service]=0
            circuit_states[$service]="CLOSED"
            echo "Command succeeded, circuit CLOSED"
            return 0
        else
            # Failure - increment count and potentially open circuit
            failures=$((failures + 1))
            failure_counts[$service]=$failures
            
            if [ $failures -ge $failure_threshold ]; then
                circuit_states[$service]="OPEN"
                echo "Circuit breaker OPENED for $service after $failures failures"
                
                # Schedule circuit to half-open after timeout
                (
                    sleep $timeout
                    circuit_states[$service]="HALF_OPEN"
                    echo "Circuit breaker HALF_OPEN for $service"
                ) &
            fi
            
            return 1
        fi
    }
}

# =============================================================================
# 29. CROSS-PLATFORM COMPATIBILITY
# =============================================================================

# -----------------------------------------------------------------------------
# OS Detection and Compatibility
# -----------------------------------------------------------------------------
cross_platform_compatibility() {
    echo "=== Cross-Platform Compatibility ==="
    
    # Comprehensive OS detection
    detect_os() {
        local os_type
        local os_version
        local architecture
        
        case "$OSTYPE" in
            linux-gnu*) 
                os_type="Linux"
                if [ -f /etc/os-release ]; then
                    os_version=$(. /etc/os-release && echo "$PRETTY_NAME")
                elif [ -f /etc/redhat-release ]; then
                    os_version=$(cat /etc/redhat-release)
                elif [ -f /etc/debian_version ]; then
                    os_version="Debian $(cat /etc/debian_version)"
                fi
                ;;
            darwin*) 
                os_type="macOS"
                os_version=$(sw_vers -productVersion)
                ;;
            cygwin*|msys*|mingw*)
                os_type="Windows"
                os_version=$(cmd.exe /c ver 2>/dev/null | grep -o "Version [0-9.]*")
                ;;
            *) 
                os_type="Unknown"
                os_version="Unknown"
                ;;
        esac
        
        architecture=$(uname -m)
        
        echo "OS: $os_type"
        echo "Version: $os_version"
        echo "Architecture: $architecture"
        
        # Export for use in other functions
        export OS_TYPE="$os_type"
        export OS_VERSION="$os_version"
        export OS_ARCH="$architecture"
    }
    
    # Platform-specific command execution
    run_platform_command() {
        local command="$1"
        
        case "$OS_TYPE" in
            "Linux")
                case "$command" in
                    "open_file")
                        xdg-open "$2" 2>/dev/null || gnome-open "$2" 2>/dev/null
                        ;;
                    "copy_to_clipboard")
                        echo "$2" | xclip -selection clipboard 2>/dev/null || echo "$2" | xsel --clipboard 2>/dev/null
                        ;;
                    "get_cpu_count")
                        nproc
                        ;;
                esac
                ;;
            "macOS")
                case "$command" in
                    "open_file")
                        open "$2"
                        ;;
                    "copy_to_clipboard")
                        echo "$2" | pbcopy
                        ;;
                    "get_cpu_count")
                        sysctl -n hw.ncpu
                        ;;
                esac
                ;;
            "Windows")
                case "$command" in
                    "open_file")
                        cmd.exe /c start "$2"
                        ;;
                    "copy_to_clipboard")
                        echo "$2" | clip.exe
                        ;;
                    "get_cpu_count")
                        echo "$NUMBER_OF_PROCESSORS"
                        ;;
                esac
                ;;
        esac
    }
}

# -----------------------------------------------------------------------------
# Shell Portability - POSIX Compliance
# -----------------------------------------------------------------------------
posix_compatibility() {
    echo "=== POSIX Compliance ==="
    
    # POSIX-compliant string operations
    posix_string_ops() {
        local string="$1"
        local pattern="$2"
        
        # String length (POSIX way)
        string_length() {
            printf '%s' "$1" | wc -c
        }
        
        # Substring extraction (POSIX way)
        substring() {
            local str="$1"
            local start="$2"
            local length="$3"
            
            printf '%s' "$str" | cut -c "${start}-$((start + length - 1))"
        }
        
        # Pattern matching (POSIX way)
        match_pattern() {
            case "$1" in
                *"$2"*) return 0 ;;
                *) return 1 ;;
            esac
        }
        
        echo "String: $string"
        echo "Length: $(string_length "$string")"
        echo "Substring (3-5): $(substring "$string" 3 3)"
        
        if match_pattern "$string" "$pattern"; then
            echo "Pattern '$pattern' found in string"
        else
            echo "Pattern '$pattern' not found in string"
        fi
    }
    
    # POSIX-compliant array simulation (using space-separated strings)
    posix_array_ops() {
        local array_data="apple orange banana grape"
        
        # Add element
        array_add() {
            local current="$1"
            local new_element="$2"
            echo "$current $new_element"
        }
        
        # Get element by index (1-based)
        array_get() {
            local array="$1"
            local index="$2"
            echo "$array" | cut -d' ' -f"$index"
        }
        
        # Get array length
        array_length() {
            local array="$1"
            echo "$array" | wc -w
        }
        
        # Iterate over array
        array_foreach() {
            local array="$1"
            local old_ifs="$IFS"
            IFS=' '
            
            for element in $array; do
                echo "Processing: $element"
            done
            
            IFS="$old_ifs"
        }
        
        echo "Original array: $array_data"
        array_data=$(array_add "$array_data" "kiwi")
        echo "After adding kiwi: $array_data"
        echo "Second element: $(array_get "$array_data" 2)"
        echo "Array length: $(array_length "$array_data")"
        echo "Iterating:"
        array_foreach "$array_data"
    }
}

# -----------------------------------------------------------------------------
# Package Management Cross-Platform
# -----------------------------------------------------------------------------
cross_platform_packages() {
    echo "=== Cross-Platform Package Management ==="
    
    # Universal package installer
    install_package() {
        local package="$1"
        
        # Detect package manager
        if command -v apt-get >/dev/null 2>&1; then
            echo "Using apt-get to install $package"
            sudo apt-get update && sudo apt-get install -y "$package"
        elif command -v yum >/dev/null 2>&1; then
            echo "Using yum to install $package"
            sudo yum install -y "$package"
        elif command -v dnf >/dev/null 2>&1; then
            echo "Using dnf to install $package"
            sudo dnf install -y "$package"
        elif command -v pacman >/dev/null 2>&1; then
            echo "Using pacman to install $package"
            sudo pacman -S --noconfirm "$package"
        elif command -v brew >/dev/null 2>&1; then
            echo "Using Homebrew to install $package"
            brew install "$package"
        elif command -v chocolatey >/dev/null 2>&1; then
            echo "Using Chocolatey to install $package"
            choco install -y "$package"
        else
            echo "No supported package manager found"
            return 1
        fi
    }
    
    # Package mapping for different distributions
    declare -A package_map=(
        ["curl_ubuntu"]="curl"
        ["curl_centos"]="curl"
        ["curl_arch"]="curl"
        ["curl_macos"]="curl"
        ["curl_windows"]="curl"
        
        ["python_ubuntu"]="python3"
        ["python_centos"]="python3"
        ["python_arch"]="python"
        ["python_macos"]="python3"
        ["python_windows"]="python"
    )
    
    install_mapped_package() {
        local package="$1"
        local os_key="${package}_$(echo "$OS_TYPE" | tr '[:upper:]' '[:lower:]')"
        local actual_package="${package_map[$os_key]:-$package}"
        
        echo "Installing $actual_package (mapped from $package)"
        install_package "$actual_package"
    }
}

# -----------------------------------------------------------------------------
# Cross-Platform Path Handling
# -----------------------------------------------------------------------------
cross_platform_paths() {
    echo "=== Cross-Platform Path Handling ==="
    
    # Path separator detection and conversion
    get_path_separator() {
        case "$OS_TYPE" in
            "Windows") echo "\\" ;;
            *) echo "/" ;;
        esac
    }
    
    # Normalize path for current platform
    normalize_path() {
        local path="$1"
        local separator
        separator=$(get_path_separator)
        
        # Convert all separators to current platform
        if [ "$OS_TYPE" = "Windows" ]; then
            echo "$path" | sed 's|/|\\|g'
        else
            echo "$path" | sed 's|\\|/|g'
        fi
    }
    
    # Join path components
    join_path() {
        local separator
        separator=$(get_path_separator)
        
        local result=""
        for component in "$@"; do
            if [ -z "$result" ]; then
                result="$component"
            else
                result="${result}${separator}${component}"
            fi
        done
        
        normalize_path "$result"
    }
    
    # Get absolute path (cross-platform)
    get_absolute_path() {
        local path="$1"
        
        case "$OS_TYPE" in
            "Windows")
                # Convert to absolute path on Windows
                cmd.exe /c "for %A in (\"$path\") do @echo %~fA" 2>/dev/null
                ;;
            *)
                # Use realpath on Unix-like systems
                if command -v realpath >/dev/null 2>&1; then
                    realpath "$path"
                else
                    # Fallback for systems without realpath
                    cd "$(dirname "$path")" && pwd -P && basename "$path"
                fi
                ;;
        esac
    }
    
    # Example usage
    demo_path_operations() {
        local base_path="home"
        local sub_path="user"
        local file_name="document.txt"
        
        local full_path
        full_path=$(join_path "$base_path" "$sub_path" "$file_name")
        
        echo "Joined path: $full_path"
        echo "Normalized: $(normalize_path "$full_path")"
        echo "Path separator: $(get_path_separator)"
    }
}

# =============================================================================
# 30. EXPERT-LEVEL TECHNIQUES
# =============================================================================



