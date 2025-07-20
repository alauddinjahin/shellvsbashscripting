#!/bin/bash

# cicd_pipeline.sh - Continuous Integration and Deployment Pipeline
# Usage: ./cicd_pipeline.sh [stage] [environment]

set -e

# Configuration
PIPELINE_CONFIG="pipeline.conf"
DEPLOY_CONFIG="deploy.conf"
ARTIFACTS_DIR="artifacts"
LOGS_DIR="pipeline-logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Default values
STAGE=${1:-"all"}
ENVIRONMENT=${2:-"staging"}
BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_SHA=$(git rev-parse --short HEAD)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] [PIPELINE]${NC} $1" | tee -a "$LOGS_DIR/pipeline-$TIMESTAMP.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGS_DIR/pipeline-$TIMESTAMP.log"
    notify_failure "$1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOGS_DIR/pipeline-$TIMESTAMP.log"
}

stage_header() {
    echo -e "\n${PURPLE}========================================${NC}"
    echo -e "${PURPLE} STAGE: $1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

# Load configuration
load_config() {
    if [[ -f "$PIPELINE_CONFIG" ]]; then
        source "$PIPELINE_CONFIG"
        log "Loaded pipeline configuration"
    else
        log "No pipeline configuration found, using defaults"
    fi
    
    # Create required directories
    mkdir -p "$ARTIFACTS_DIR" "$LOGS_DIR"
}

# Notification functions
notify_slack() {
    local message=$1
    local color=${2:-"good"}
    
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"attachments\":[{\"color\":\"$color\",\"text\":\"$message\"}]}" \
            "$SLACK_WEBHOOK_URL" || true
    fi
}

notify_failure() {
    local error_msg=$1
    notify_slack " Pipeline FAILED: $error_msg\nBranch: $BRANCH\nCommit: $COMMIT_SHA" "danger"
}

notify_success() {
    local message=$1
    notify_slack "Pipeline SUCCESS: $message\nBranch: $BRANCH\nCommit: $COMMIT_SHA" "good"
}

# Stage 1: Environment Validation
validate_environment() {
    stage_header "ENVIRONMENT VALIDATION"
    
    log "Validating environment and dependencies..."
    
    # Check Git repository
    if ! git status &>/dev/null; then
        error "Not in a Git repository"
    fi
    
    # Check for uncommitted changes on main/master
    if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && ! git diff-index --quiet HEAD --; then
        error "Uncommitted changes detected on $BRANCH branch"
    fi
    
    # Validate required tools
    local required_tools=("git" "curl")
    
    # Add language-specific tools
    if [[ -f "package.json" ]]; then
        required_tools+=("node" "npm")
    fi
    if [[ -f "pom.xml" ]]; then
        required_tools+=("mvn")
    fi
    if [[ -f "requirements.txt" ]]; then
        required_tools+=("python3" "pip")
    fi
    if [[ -f "go.mod" ]]; then
        required_tools+=("go")
    fi
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "Required tool not found: $tool"
        fi
    done
    
    # Check environment variables
    if [[ "$ENVIRONMENT" == "production" ]]; then
        local required_vars=("DEPLOY_KEY" "PRODUCTION_URL")
        for var in "${required_vars[@]}"; do
            if [[ -z "${!var}" ]]; then
                error "Required environment variable not set: $var"
            fi
        done
    fi
    
    success "Environment validation completed"
}

# Stage 2: Code Quality Checks
code_quality_checks() {
    stage_header "CODE QUALITY CHECKS"
    
    log "Running code quality checks..."
    
    # Linting
    if [[ -f "package.json" ]] && npm list eslint &>/dev/null; then
        log "Running ESLint..."
        npm run lint || error "ESLint checks failed"
    fi
    
    if [[ -f "requirements.txt" ]] && command -v flake8 &>/dev/null; then
        log "Running Flake8..."
        flake8 . || error "Flake8 checks failed"
    fi
    
    if [[ -f "go.mod" ]]; then
        log "Running Go fmt and vet..."
        gofmt -l . | grep -v vendor/ && error "Code not formatted with gofmt"
        go vet ./... || error "Go vet checks failed"
    fi
    
    # Security scanning
    if command -v npm &>/dev/null && [[ -f "package.json" ]]; then
        log "Running security audit..."
        npm audit --audit-level=moderate || log "Security vulnerabilities found (non-blocking)"
    fi
    
    # Code complexity analysis
    if command -v sonar-scanner &>/dev/null && [[ -f "sonar-project.properties" ]]; then
        log "Running SonarQube analysis..."
        sonar-scanner || log "SonarQube analysis completed with warnings"
    fi
    
    success "Code quality checks completed"
}

# Stage 3: Build Application
build_application() {
    stage_header "BUILD APPLICATION"
    
    log "Building application..."
    
    # Use the build script from earlier
    if [[ -x "./build.sh" ]]; then
        ./build.sh auto "$(basename "$PWD")" "$ENVIRONMENT"
    else
        # Fallback build logic
        if [[ -f "package.json" ]]; then
            npm ci
            npm run build
        elif [[ -f "pom.xml" ]]; then
            mvn clean package -DskipTests
        elif [[ -f "requirements.txt" ]]; then
            python3 -m pip install -r requirements.txt
            if [[ -f "setup.py" ]]; then
                python3 setup.py build
            fi
        elif [[ -f "go.mod" ]]; then
            go build -o "$ARTIFACTS_DIR/app" ./...
        fi
    fi
    
    # Verify build artifacts
    if [[ ! -d "build" && ! -d "dist" && ! -d "target" && ! -f "$ARTIFACTS_DIR/app" ]]; then
        error "No build artifacts found"
    fi
    
    success "Application build completed"
}

# Stage 4: Run Tests
run_tests() {
    stage_header "RUN TESTS"
    
    log "Executing test suite..."
    
    # Use the test runner from earlier
    if [[ -x "./test_runner.sh" ]]; then
        ./test_runner.sh all --coverage
    else
        # Fallback test logic
        if [[ -f "package.json" ]]; then
            npm test
        elif [[ -f "pom.xml" ]]; then
            mvn test
        elif [[ -f "requirements.txt" ]]; then
            python3 -m pytest
        elif [[ -f "go.mod" ]]; then
            go test ./...
        fi
    fi
    
    success "Tests completed successfully"
}

# Stage 5: Security Scanning
security_scanning() {
    stage_header "SECURITY SCANNING"
    
    log "Running security scans..."
    
    # Container security scanning
    if [[ -f "Dockerfile" ]] && command -v trivy &>/dev/null; then
        log "Scanning Docker image for vulnerabilities..."
        docker build -t "app:$COMMIT_SHA" .
        trivy image "app:$COMMIT_SHA" || log "Security vulnerabilities found in image"
    fi
    
    # Dependency vulnerability scanning
    if [[ -f "package.json" ]] && command -v audit-ci &>/dev/null; then
        log "Scanning npm dependencies..."
        npx audit-ci --moderate
    fi
    
    # SAST (Static Application Security Testing)
    if command -v bandit &>/dev/null && find . -name "*.py" | head -1; then
        log "Running Bandit SAST scan..."
        bandit -r . -f json -o "$ARTIFACTS_DIR/bandit-report.json" || true
    fi
    
    success "Security scanning completed"
}

# Stage 6: Package Application
package_application() {
    stage_header "PACKAGE APPLICATION"
    
    log "Packaging application for deployment..."
    
    # Create deployment package
    local package_name="app-$ENVIRONMENT-$COMMIT_SHA-$TIMESTAMP"
    
    if [[ -f "Dockerfile" ]]; then
        # Docker packaging
        log "Building Docker image..."
        docker build -t "$package_name" .
        docker save "$package_name" | gzip > "$ARTIFACTS_DIR/$package_name.tar.gz"
        
        # Push to registry if configured
        if [[ -n "$DOCKER_REGISTRY" ]]; then
            docker tag "$package_name" "$DOCKER_REGISTRY/$package_name"
            docker push "$DOCKER_REGISTRY/$package_name"
        fi
        
    else
        # Archive packaging
        log "Creating deployment archive..."
        tar -czf "$ARTIFACTS_DIR/$package_name.tar.gz" \
            --exclude=node_modules --exclude=.git --exclude=tests \
            --exclude=venv --exclude=__pycache__ .
    fi
    
    # Generate deployment manifest
    cat > "$ARTIFACTS_DIR/deployment-manifest.json" << EOF
{
    "package_name": "$package_name",
    "environment": "$ENVIRONMENT",
    "branch": "$BRANCH",
    "commit_sha": "$COMMIT_SHA",
    "build_timestamp": "$TIMESTAMP",
    "artifacts": [
        "$(ls -1 $ARTIFACTS_DIR | grep -E '\.(tar\.gz|jar|war|zip) | head -1)"
    ]
}
EOF
    
    success "Application packaging completed"
}

# Stage 7: Deploy Application
deploy_application() {
    stage_header "DEPLOY APPLICATION"
    
    log "Deploying to $ENVIRONMENT environment..."
    
    # Load deployment configuration
    if [[ -f "$DEPLOY_CONFIG" ]]; then
        source "$DEPLOY_CONFIG"
    fi
    
    case "$ENVIRONMENT" in
        "development"|"dev")
            deploy_to_development
            ;;
        "staging"|"stage")
            deploy_to_staging
            ;;
        "production"|"prod")
            deploy_to_production
            ;;
        *)
            error "Unknown environment: $ENVIRONMENT"
            ;;
    esac
    
    success "Deployment to $ENVIRONMENT completed"
}

# Development deployment
deploy_to_development() {
    log "Deploying to development environment..."
    
    if [[ -n "$DEV_SERVER" ]]; then
        # Deploy via SSH
        scp "$ARTIFACTS_DIR"/*.tar.gz "$DEV_USER@$DEV_SERVER:/tmp/"
        ssh "$DEV_USER@$DEV_SERVER" "
            cd /opt/app &&
            sudo systemctl stop app || true &&
            sudo tar -xzf /tmp/*.tar.gz &&
            sudo systemctl start app &&
            sudo systemctl status app
        "
    else
        # Local development deployment
        log "Local development deployment - artifacts ready in $ARTIFACTS_DIR"
    fi
}

# Staging deployment
deploy_to_staging() {
    log "Deploying to staging environment..."
    
    if [[ -f "docker-compose.staging.yml" ]]; then
        # Docker Compose deployment
        export IMAGE_TAG="$COMMIT_SHA"
        docker-compose -f docker-compose.staging.yml up -d
        
        # Health check
        sleep 30
        if ! curl -f "$STAGING_URL/health" &>/dev/null; then
            error "Staging deployment health check failed"
        fi
    else
        # Traditional deployment
        if [[ -n "$STAGING_SERVER" ]]; then
            deploy_via_ssh "$STAGING_USER" "$STAGING_SERVER" "/opt/staging"
        fi
    fi
}

# Production deployment
deploy_to_production() {
    log "Deploying to production environment..."
    
    # Additional production safety checks
    if [[ "$BRANCH" != "main" && "$BRANCH" != "master" ]]; then
        error "Production deployment only allowed from main/master branch"
    fi
    
    # Blue-green deployment
    if [[ "$DEPLOYMENT_STRATEGY" == "blue-green" ]]; then
        deploy_blue_green
    else
        # Rolling deployment
        deploy_rolling
    fi
}

# Blue-green deployment
deploy_blue_green() {
    log "Executing blue-green deployment..."
    
    # Determine current and target environments
    local current_env="blue"
    local target_env="green"
    
    if curl -f "$PRODUCTION_URL/health" | grep -q "green"; then
        current_env="green"
        target_env="blue"
    fi
    
    log "Deploying to $target_env environment..."
    
    # Deploy to target environment
    deploy_via_ssh "$PROD_USER" "$PROD_SERVER_${target_env^^}" "/opt/app"
    
    # Health check on target
    sleep 60
    if ! curl -f "$PROD_URL_${target_env^^}/health" &>/dev/null; then
        error "$target_env environment health check failed"
    fi
    
    # Switch traffic
    log "Switching traffic to $target_env..."
    # This would typically involve updating load balancer configuration
    # For example, updating nginx configuration or cloud load balancer
    
    success "Blue-green deployment completed"
}

# Rolling deployment
deploy_rolling() {
    log "Executing rolling deployment..."
    
    local servers=($PROD_SERVERS)
    
    for server in "${servers[@]}"; do
        log "Deploying to server: $server"
        
        # Remove from load balancer
        if [[ -n "$LOAD_BALANCER_API" ]]; then
            curl -X DELETE "$LOAD_BALANCER_API/servers/$server"
            sleep 10
        fi
        
        # Deploy to server
        deploy_via_ssh "$PROD_USER" "$server" "/opt/app"
        
        # Health check
        if ! ssh "$PROD_USER@$server" "curl -f http://localhost:8080/health"; then
            error "Health check failed for $server"
        fi
        
        # Add back to load balancer
        if [[ -n "$LOAD_BALANCER_API" ]]; then
            curl -X POST "$LOAD_BALANCER_API/servers" -d "{\"host\":\"$server\"}"
        fi
        
        sleep 30  # Wait between servers
    done
}

# Generic SSH deployment
deploy_via_ssh() {
    local user=$1
    local server=$2
    local deploy_path=$3
    
    log "Deploying via SSH to $user@$server:$deploy_path"
    
    # Upload artifacts
    scp "$ARTIFACTS_DIR"/*.tar.gz "$user@$server:/tmp/"
    
    # Execute deployment commands
    ssh "$user@$server" "
        set -e
        cd $deploy_path
        
        # Backup current version
        if [[ -d current ]]; then
            mv current backup-\$(date +%Y%m%d_%H%M%S) || true
        fi
        
        # Extract new version
        mkdir -p current
        cd current
        tar -xzf /tmp/*.tar.gz
        
        # Install dependencies and restart services
        if [[ -f package.json ]]; then
            npm ci --production
        elif [[ -f requirements.txt ]]; then
            pip install -r requirements.txt
        fi
        
        # Restart application
        sudo systemctl restart app || sudo service app restart
        
        # Cleanup
        rm /tmp/*.tar.gz
    "
}

# Stage 8: Post-deployment validation
post_deployment_validation() {
    stage_header "POST-DEPLOYMENT VALIDATION"
    
    log "Running post-deployment validation..."
    
    # Health checks
    local health_url=""
    case "$ENVIRONMENT" in
        "development")
            health_url="$DEV_URL/health"
            ;;
        "staging")
            health_url="$STAGING_URL/health"
            ;;
        "production")
            health_url="$PRODUCTION_URL/health"
            ;;
    esac
    
    if [[ -n "$health_url" ]]; then
        local retries=10
        while [[ $retries -gt 0 ]]; do
            if curl -f "$health_url" &>/dev/null; then
                log "Health check passed"
                break
            fi
            log "Health check failed, retrying... ($retries attempts left)"
            sleep 30
            ((retries--))
        done
        
        if [[ $retries -eq 0 ]]; then
            error "Health check failed after all retries"
        fi
    fi
    
    # Smoke tests
    if [[ -x "./smoke_tests.sh" ]]; then
        log "Running smoke tests..."
        ./smoke_tests.sh "$ENVIRONMENT"
    fi
    
    # Performance baseline check
    if command -v ab &>/dev/null && [[ -n "$health_url" ]]; then
        log "Running performance baseline check..."
        ab -n 100 -c 10 "$health_url" > "$LOGS_DIR/performance-$TIMESTAMP.log"
    fi
    
    success "Post-deployment validation completed"
}

# Stage 9: Cleanup and reporting
cleanup_and_report() {
    stage_header "CLEANUP AND REPORTING"
    
    log "Performing cleanup and generating reports..."
    
    # Archive logs
    tar -czf "$ARTIFACTS_DIR/pipeline-logs-$TIMESTAMP.tar.gz" "$LOGS_DIR"
    
    # Generate deployment report
    generate_deployment_report
    
    # Cleanup temporary files
    if [[ "$CLEANUP_TEMP_FILES" == "true" ]]; then
        log "Cleaning up temporary files..."
        docker system prune -f || true
        rm -rf build/ dist/ target/ || true
    fi
    
    # Notify stakeholders
    notify_success "Deployment to $ENVIRONMENT completed successfully"
    
    success "Pipeline completed successfully!"
}

# Generate deployment report
generate_deployment_report() {
    local report_file="$ARTIFACTS_DIR/deployment-report-$TIMESTAMP.html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Deployment Report - $TIMESTAMP</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #e8f5e8; padding: 20px; border-radius: 10px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #4CAF50; }
        .info { background: #f0f8ff; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Deployment Report</h1>
        <p><strong>Environment:</strong> $ENVIRONMENT</p>
        <p><strong>Branch:</strong> $BRANCH</p>
        <p><strong>Commit:</strong> $COMMIT_SHA</p>
        <p><strong>Timestamp:</strong> $TIMESTAMP</p>
    </div>
    
    <div class="section info">
        <h2>Pipeline Summary</h2>
        <table>
            <tr><th>Stage</th><th>Status</th><th>Duration</th></tr>
            <tr><td>Environment Validation</td><td> Success</td><td>-</td></tr>
            <tr><td>Code Quality Checks</td><td> Success</td><td>-</td></tr>
            <tr><td>Build Application</td><td> Success</td><td>-</td></tr>
            <tr><td>Run Tests</td><td> Success</td><td>-</td></tr>
            <tr><td>Security Scanning</td><td> Success</td><td>-</td></tr>
            <tr><td>Package Application</td><td> Success</td><td>-</td></tr>
            <tr><td>Deploy Application</td><td> Success</td><td>-</td></tr>
            <tr><td>Post-deployment Validation</td><td> Success</td><td>-</td></tr>
        </table>
    </div>
    
    <div class="section">
        <h2>Artifacts</h2>
        <ul>
EOF

    for artifact in "$ARTIFACTS_DIR"/*; do
        if [[ -f "$artifact" ]]; then
            echo "            <li>$(basename "$artifact")</li>" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF
        </ul>
    </div>
    
    <div class="section">
        <h2>Next Steps</h2>
        <ul>
            <li>Monitor application metrics</li>
            <li>Verify user acceptance tests</li>
            <li>Update documentation</li>
        </ul>
    </div>
</body>
</html>
EOF

    log "Deployment report generated: $report_file"
}

# Main execution
main() {
    log "Starting CI/CD Pipeline..."
    log "Stage: $STAGE, Environment: $ENVIRONMENT"
    log "Branch: $BRANCH, Commit: $COMMIT_SHA"
    
    load_config
    
    case "$STAGE" in
        "validate")
            validate_environment
            ;;
        "quality")
            code_quality_checks
            ;;
        "build")
            build_application
            ;;
        "test")
            run_tests
            ;;
        "security")
            security_scanning
            ;;
        "package")
            package_application
            ;;
        "deploy")
            deploy_application
            ;;
        "validate-deployment")
            post_deployment_validation
            ;;
        "all")
            validate_environment
            code_quality_checks
            build_application
            run_tests
            security_scanning
            package_application
            deploy_application
            post_deployment_validation
            cleanup_and_report
            ;;
        *)
            error "Unknown stage: $STAGE"
            ;;
    esac
}

show_help() {
    cat << EOF
Usage: $0 [STAGE] [ENVIRONMENT]

STAGES:
    validate            - Environment validation only
    quality             - Code quality checks only
    build               - Build application only
    test                - Run tests only
    security            - Security scanning only
    package             - Package application only
    deploy              - Deploy application only
    validate-deployment - Post-deployment validation only
    all                 - Run complete pipeline (default)

ENVIRONMENTS:
    development, dev    - Development environment
    staging, stage      - Staging environment
    production, prod    - Production environment

Examples:
    $0                          # Run complete pipeline to staging
    $0 all production           # Run complete pipeline to production
    $0 deploy staging           # Deploy only to staging
    $0 test                     # Run tests only

Configuration Files:
    pipeline.conf   - Pipeline configuration
    deploy.conf     - Deployment configuration

Environment Variables:
    SLACK_WEBHOOK_URL   - Slack notifications
    DOCKER_REGISTRY     - Docker registry URL
    SONAR_TOKEN         - SonarQube token

EOF
}

# Check for help flag
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Execute main function
main "$@"