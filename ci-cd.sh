### CI/CD Integration Script

```bash
#!/bin/bash
# cicd_integration.sh - Continuous Integration/Continuous Deployment automation

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI_CONFIG_DIR="$PROJECT_ROOT/.ci"
PIPELINE_LOG="$PROJECT_ROOT/pipeline.log"
ARTIFACT_DIR="$PROJECT_ROOT/artifacts"

# CI/CD Configuration
BRANCH_PROTECTION_RULES=("main" "master" "develop")
NOTIFICATION_WEBHOOK=""  # Slack/Discord webhook URL
DOCKER_REGISTRY="docker.io"
DOCKER_IMAGE_NAME="myapp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to log pipeline events
log_pipeline() {
    local level="$1"
    local stage="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case "$level" in
        "INFO") color="$BLUE" ;;
        "SUCCESS") color="$GREEN" ;;
        "WARNING") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        "STAGE") color="$PURPLE" ;;
    esac
    
    local log_entry="[$timestamp] [$level] [$stage] $message"
    echo -e "${color}$log_entry${NC}" | tee -a "$PIPELINE_LOG"
    
    # Send to external logging service if configured
    if [[ -n "$LOG_ENDPOINT" ]]; then
        curl -s -X POST "$LOG_ENDPOINT" \
            -H "Content-Type: application/json" \
            -d "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"stage\":\"$stage\",\"message\":\"$message\"}" \
            > /dev/null 2>&1 || true
    fi
}

# Function to send notifications
send_notification() {
    local status="$1"
    local stage="$2"
    local message="$3"
    
    if [[ -n "$NOTIFICATION_WEBHOOK" ]]; then
        local color=""
        case "$status" in
            "success") color="good" ;;
            "failure") color="danger" ;;
            "warning") color="warning" ;;
            *) color="#439FE0" ;;
        esac
        
        local payload=$(cat << EOF
{
    "attachments": [
        {
            "color": "$color",
            "title": "CI/CD Pipeline - $stage",
            "text": "$message",
            "fields": [
                {
                    "title": "Project",
                    "value": "$(basename "$PROJECT_ROOT")",
                    "short": true
                },
                {
                    "title": "Branch",
                    "value": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
                    "short": true
                },
                {
                    "title": "Commit",
                    "value": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
                    "short": true
                },
                {
                    "title": "Timestamp",
                    "value": "$(date)",
                    "short": true
                }
            ]
        }
    ]
}
EOF
        )
        
        curl -s -X POST "$NOTIFICATION_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "$payload" > /dev/null 2>&1 || true
    fi
}

# Function to validate environment
validate_environment() {
    log_pipeline "STAGE" "VALIDATION" "Starting environment validation"
    
    local validation_failed=false
    
    # Check required tools
    local required_tools=("git" "curl" "jq")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_pipeline "ERROR" "VALIDATION" "Required tool missing: $tool"
            validation_failed=true
        fi
    done
    
    # Check Git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_pipeline "ERROR" "VALIDATION" "Not a Git repository"
        validation_failed=true
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_pipeline "WARNING" "VALIDATION" "Uncommitted changes detected"
    fi
    
    # Validate branch
    local current_branch=$(git branch --show-current)
    log_pipeline "INFO" "VALIDATION" "Current branch: $current_branch"
    
    if [[ "$validation_failed" == true ]]; then
        log_pipeline "ERROR" "VALIDATION" "Environment validation failed"
        return 1
    fi
    
    log_pipeline "SUCCESS" "VALIDATION" "Environment validation passed"
    return 0
}

# Function to run code quality checks
run_quality_checks() {
    log_pipeline "STAGE" "QUALITY" "Starting code quality checks"
    
    local quality_score=0
    local max_score=0
    
    # Security scanning
    if command -v bandit &> /dev/null && find . -name "*.py" | head -1 > /dev/null; then
        log_pipeline "INFO" "QUALITY" "Running Bandit security scan"
        ((max_score++))
        if bandit -r . -f json -o "$ARTIFACT_DIR/bandit-report.json" 2>/dev/null; then
            ((quality_score++))
            log_pipeline "SUCCESS" "QUALITY" "Security scan passed"
        else
            log_pipeline "WARNING" "QUALITY" "Security issues detected"
        fi
    fi
    
    # Dependency vulnerability scanning
    if [[ -f "package.json" ]] && command -v npm &> /dev/null; then
        log_pipeline "INFO" "QUALITY" "Running npm audit"
        ((max_score++))
        if npm audit --audit-level=high; then
            ((quality_score++))
            log_pipeline "SUCCESS" "QUALITY" "Dependency audit passed"
        else
            log_pipeline "WARNING" "QUALITY" "Dependency vulnerabilities found"
        fi
    fi
    
    # Code complexity analysis
    if command -v sonar-scanner &> /dev/null && [[ -f "sonar-project.properties" ]]; then
        log_pipeline "INFO" "QUALITY" "Running SonarQube analysis"
        ((max_score++))
        if sonar-scanner; then
            ((quality_score++))
            log_pipeline "SUCCESS" "QUALITY" "Code quality analysis passed"
        else
            log_pipeline "WARNING" "QUALITY" "Code quality issues detected"
        fi
    fi
    
    # Calculate quality percentage
    if [[ $max_score -gt 0 ]]; then
        local quality_percentage=$((quality_score * 100 / max_score))
        log_pipeline "INFO" "QUALITY" "Quality score: $quality_score/$max_score ($quality_percentage%)"
        
        if [[ $quality_percentage -lt 70 ]]; then
            log_pipeline "WARNING" "QUALITY" "Quality score below threshold"
            return 1
        fi
    fi
    
    log_pipeline "SUCCESS" "QUALITY" "Code quality checks completed"
    return 0
}

# Function to build Docker image
build_docker_image() {
    log_pipeline "STAGE" "BUILD" "Starting Docker image build"
    
    if [[ ! -f "Dockerfile" ]]; then
        log_pipeline "WARNING" "BUILD" "No Dockerfile found, skipping Docker build"
        return 0
    fi
    
    local image_tag="${DOCKER_IMAGE_NAME}:$(git rev-parse --short HEAD)"
    local latest_tag="${DOCKER_IMAGE_NAME}:latest"
    
    # Build image
    log_pipeline "INFO" "BUILD" "Building Docker image: $image_tag"
    if docker build -t "$image_tag" -t "$latest_tag" .; then
        log_pipeline "SUCCESS" "BUILD" "Docker image built successfully"
    else
        log_pipeline "ERROR" "BUILD" "Docker image build failed"
        return 1
    fi
    
    # Save image info
    echo "$image_tag" > "$ARTIFACT_DIR/docker-image.txt"
    docker inspect "$image_tag" > "$ARTIFACT_DIR/docker-inspect.json"
    
    # Security scan of Docker image
    if command -v trivy &> /dev/null; then
        log_pipeline "INFO" "BUILD" "Scanning Docker image for vulnerabilities"
        trivy image --format json --output "$ARTIFACT_DIR/trivy-report.json" "$image_tag"
    fi
    
    return 0
}

# Function to run integration tests
run_integration_tests() {
    log_pipeline "STAGE" "INTEGRATION" "Starting integration tests"
    
    # Start test services with Docker Compose
    if [[ -f "docker-compose.test.yml" ]]; then
        log_pipeline "INFO" "INTEGRATION" "Starting test environment"
        if docker-compose -f docker-compose.test.yml up -d; then
            sleep 30  # Wait for services to start
            
            # Run integration tests
            local test_result=0
            if [[ -f "test/integration" ]]; then
                log_pipeline "INFO" "INTEGRATION" "Running integration test suite"
                if ! npm run test:integration; then
                    test_result=1
                fi
            fi
            
            # Cleanup test environment
            docker-compose -f docker-compose.test.yml down
            
            if [[ $test_result -eq 0 ]]; then
                log_pipeline "SUCCESS" "INTEGRATION" "Integration tests passed"
                return 0
            else
                log_pipeline "ERROR" "INTEGRATION" "Integration tests failed"
                return 1
            fi
        else
            log_pipeline "ERROR" "INTEGRATION" "Failed to start test environment"
            return 1
        fi
    else
        log_pipeline "INFO" "INTEGRATION" "No integration tests configured"
        return 0
    fi
}

# Function to deploy to staging
deploy_staging() {
    log_pipeline "STAGE" "STAGING" "Deploying to staging environment"
    
    local staging_config="$CI_CONFIG_DIR/staging.env"
    if [[ -f "$staging_config" ]]; then
        source "$staging_config"
    fi
    
    # Deploy using various methods
    if [[ -n "$KUBERNETES_CONTEXT" ]]; then
        # Kubernetes deployment
        log_pipeline "INFO" "STAGING" "Deploying to Kubernetes"
        kubectl --context="$KUBERNETES_CONTEXT" apply -f k8s/staging/
        kubectl --context="$KUBERNETES_CONTEXT" rollout status deployment/"$APP_NAME" --timeout=300s
    elif [[ -n "$DOCKER_SWARM_MANAGER" ]]; then
        # Docker Swarm deployment
        log_pipeline "INFO" "STAGING" "Deploying to Docker Swarm"
        docker stack deploy -c docker-stack.staging.yml "$APP_NAME"
    elif [[ -n "$STAGING_HOST" ]]; then
        # Traditional server deployment
        log_pipeline "INFO" "STAGING" "Deploying to staging server"
        rsync -avz --exclude='.git' . "$STAGING_USER@$STAGING_HOST:$STAGING_PATH"
        ssh "$STAGING_USER@$STAGING_HOST" "cd $STAGING_PATH && ./deploy.sh staging"
    fi
    
    log_pipeline "SUCCESS# Complete Bash Scripts Guide: System Administration, Development Tools & Data Processing

## 24. System Administration

### Log Rotation Script

```bash
#!/bin/bash
# log_rotator.sh - Automated log management and rotation

# Configuration
LOG_DIR="/var/log/myapp"
MAX_SIZE="100M"  # Maximum log file size
KEEP_DAYS=30     # Days to keep old logs
COMPRESS=true    # Compress old logs

# Function to rotate a single log file
rotate_log() {
    local logfile="$1"
    local basename=$(basename "$logfile")
    local dirname=$(dirname "$logfile")
    
    # Check if log file exists and size
    if [[ -f "$logfile" ]]; then
        local size=$(du -h "$logfile" | cut -f1)
        echo "Processing $logfile (Size: $size)"
        
        # Rotate if file is larger than MAX_SIZE
        if [[ $(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile") -gt $(echo $MAX_SIZE | sed 's/M/000000/') ]]; then
            # Create timestamp
            local timestamp=$(date +%Y%m%d_%H%M%S)
            
            # Move current log to timestamped version
            mv "$logfile" "${logfile}.${timestamp}"
            
            # Create new empty log file
            touch "$logfile"
            
            # Set appropriate permissions
            chmod 644 "$logfile"
            
            # Compress if enabled
            if [[ "$COMPRESS" == true ]]; then
                gzip "${logfile}.${timestamp}"
                echo "Compressed ${logfile}.${timestamp}"
            fi
            
            echo "Rotated $logfile"
        fi
    fi
}

# Function to clean old logs
cleanup_old_logs() {
    echo "Cleaning up logs older than $KEEP_DAYS days..."
    find "$LOG_DIR" -name "*.log.*" -mtime +$KEEP_DAYS -delete
    find "$LOG_DIR" -name "*.gz" -mtime +$KEEP_DAYS -delete
}

# Main execution
main() {
    echo "Starting log rotation at $(date)"
    
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"
    
    # Find and rotate all .log files
    find "$LOG_DIR" -name "*.log" -type f | while read logfile; do
        rotate_log "$logfile"
    done
    
    # Clean up old logs
    cleanup_old_logs
    
    echo "Log rotation completed at $(date)"
}

# Run main function
main "$@"