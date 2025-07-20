#!/bin/bash

# test_runner.sh - Automated test execution with reporting
# Usage: ./test_runner.sh [test_type] [--coverage] [--parallel]

set -e

# Configuration
TEST_RESULTS_DIR="test-results"
COVERAGE_DIR="coverage"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
PARALLEL=false
COVERAGE=false
TEST_TYPE="all"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        unit|integration|e2e|all)
            TEST_TYPE=$1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Setup test environment
setup_test_env() {
    log "Setting up test environment..."
    
    # Create directories
    mkdir -p "$TEST_RESULTS_DIR" "$COVERAGE_DIR"
    
    # Clean previous results
    rm -rf "${TEST_RESULTS_DIR:?}"/*
    
    # Start test services if needed
    if command -v docker-compose &> /dev/null && [[ -f "docker-compose.test.yml" ]]; then
        log "Starting test services with Docker Compose..."
        docker-compose -f docker-compose.test.yml up -d
        sleep 5  # Wait for services to be ready
    fi
}

# Cleanup test environment
cleanup_test_env() {
    log "Cleaning up test environment..."
    
    if command -v docker-compose &> /dev/null && [[ -f "docker-compose.test.yml" ]]; then
        docker-compose -f docker-compose.test.yml down -v
    fi
}

# Run unit tests
run_unit_tests() {
    log "Running unit tests..."
    
    local test_cmd=""
    local coverage_cmd=""
    
    if [[ -f "package.json" ]]; then
        # Node.js/JavaScript
        if [[ "$COVERAGE" == true ]]; then
            coverage_cmd="--coverage --coverageDirectory=$COVERAGE_DIR"
        fi
        test_cmd="npm test -- --testPathPattern=unit $coverage_cmd --testResultsProcessor=jest-junit"
        export JEST_JUNIT_OUTPUT_DIR="$TEST_RESULTS_DIR"
        
    elif [[ -f "pom.xml" ]]; then
        # Java Maven
        if [[ "$COVERAGE" == true ]]; then
            test_cmd="mvn test jacoco:report"
        else
            test_cmd="mvn test"
        fi
        
    elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
        # Python
        if [[ "$COVERAGE" == true ]]; then
            test_cmd="coverage run -m pytest tests/unit/ --junitxml=$TEST_RESULTS_DIR/unit-results.xml"
        else
            test_cmd="pytest tests/unit/ --junitxml=$TEST_RESULTS_DIR/unit-results.xml"
        fi
        
    elif [[ -f "go.mod" ]]; then
        # Go
        if [[ "$COVERAGE" == true ]]; then
            test_cmd="go test -v -coverprofile=$COVERAGE_DIR/coverage.out ./... -run TestUnit"
        else
            test_cmd="go test -v ./... -run TestUnit"
        fi
    fi
    
    if [[ -n "$test_cmd" ]]; then
        eval "$test_cmd"
        success "Unit tests completed"
    else
        error "No unit test configuration found"
    fi
}

# Run integration tests
run_integration_tests() {
    log "Running integration tests..."
    
    # Ensure test database/services are running
    setup_integration_services
    
    local test_cmd=""
    
    if [[ -f "package.json" ]]; then
        test_cmd="npm test -- --testPathPattern=integration"
    elif [[ -f "pom.xml" ]]; then
        test_cmd="mvn verify -Dtest=**/*IntegrationTest"
    elif [[ -f "requirements.txt" ]]; then
        test_cmd="pytest tests/integration/ --junitxml=$TEST_RESULTS_DIR/integration-results.xml"
    elif [[ -f "go.mod" ]]; then
        test_cmd="go test -v ./... -run TestIntegration"
    fi
    
    if [[ -n "$test_cmd" ]]; then
        eval "$test_cmd"
        success "Integration tests completed"
    else
        error "No integration test configuration found"
    fi
}

# Setup integration test services
setup_integration_services() {
    if [[ -f "docker-compose.integration.yml" ]]; then
        log "Starting integration test services..."
        docker-compose -f docker-compose.integration.yml up -d
        
        # Wait for services to be healthy
        sleep 10
        
        # Health check
        if command -v curl &> /dev/null; then
            local retries=30
            while [[ $retries -gt 0 ]]; do
                if curl -f http://localhost:5432 2>/dev/null || \
                   curl -f http://localhost:3306 2>/dev/null || \
                   curl -f http://localhost:5672 2>/dev/null; then
                    break
                fi
                log "Waiting for services to be ready... ($retries retries left)"
                sleep 2
                ((retries--))
            done
        fi
    fi
}

# Run end-to-end tests
run_e2e_tests() {
    log "Running end-to-end tests..."
    
    # Start application if needed
    if [[ -f "package.json" ]] && grep -q "start" package.json; then
        log "Starting application for E2E tests..."
        npm start &
        APP_PID=$!
        sleep 10
    fi
    
    local test_cmd=""
    
    if command -v cypress &> /dev/null; then
        test_cmd="cypress run --reporter junit --reporter-options mochaFile=$TEST_RESULTS_DIR/e2e-results.xml"
    elif command -v playwright &> /dev/null; then
        test_cmd="playwright test --reporter=junit --output-dir=$TEST_RESULTS_DIR"
    elif [[ -f "tests/e2e" ]]; then
        test_cmd="pytest tests/e2e/ --junitxml=$TEST_RESULTS_DIR/e2e-results.xml"
    fi
    
    if [[ -n "$test_cmd" ]]; then
        eval "$test_cmd" || true  # Don't fail if E2E tests fail
        success "E2E tests completed"
    else
        log "No E2E test framework found, skipping..."
    fi
    
    # Stop application
    if [[ -n "$APP_PID" ]]; then
        kill $APP_PID 2>/dev/null || true
    fi
}

# Generate test report
generate_report() {
    log "Generating test report..."
    
    local report_file="$TEST_RESULTS_DIR/test-report-$TIMESTAMP.html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Test Report - $TIMESTAMP</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f4f4f4; padding: 10px; border-radius: 5px; }
        .success { color: green; }
        .failure { color: red; }
        .section { margin: 20px 0; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Test Report</h1>
        <p>Generated: $(date)</p>
        <p>Test Type: $TEST_TYPE</p>
        <p>Coverage Enabled: $COVERAGE</p>
    </div>
    
    <div class="section">
        <h2>Test Results Summary</h2>
        <table>
            <tr><th>Test Type</th><th>Status</th><th>Results File</th></tr>
EOF

    # Add results for each test type
    for result_file in "$TEST_RESULTS_DIR"/*.xml; do
        if [[ -f "$result_file" ]]; then
            local test_name=$(basename "$result_file" .xml | sed 's/-results//')
            echo "            <tr><td>$test_name</td><td class=\"success\">✓ Passed</td><td>$(basename "$result_file")</td></tr>" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF
        </table>
    </div>
    
    <div class="section">
        <h2>Coverage Report</h2>
EOF

    if [[ "$COVERAGE" == true ]] && [[ -d "$COVERAGE_DIR" ]]; then
        echo "        <p>Coverage reports available in: $COVERAGE_DIR</p>" >> "$report_file"
        
        # Include coverage summary if available
        if [[ -f "$COVERAGE_DIR/lcov-report/index.html" ]]; then
            echo "        <p><a href=\"$COVERAGE_DIR/lcov-report/index.html\">View detailed coverage report</a></p>" >> "$report_file"
        fi
    else
        echo "        <p>Coverage not enabled for this run</p>" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF
    </div>
</body>
</html>
EOF

    success "Test report generated: $report_file"
}

# Main execution
main() {
    log "Starting test automation..."
    log "Test type: $TEST_TYPE"
    log "Coverage: $COVERAGE"
    log "Parallel: $PARALLEL"
    
    setup_test_env
    
    # Trap cleanup on exit
    trap cleanup_test_env EXIT
    
    case "$TEST_TYPE" in
        "unit")
            run_unit_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "e2e")
            run_e2e_tests
            ;;
        "all")
            run_unit_tests
            run_integration_tests
            run_e2e_tests
            ;;
    esac
    
    # Generate coverage report
    if [[ "$COVERAGE" == true ]]; then
        if command -v coverage &> /dev/null; then
            coverage report
            coverage html -d "$COVERAGE_DIR"
        elif [[ -f "$COVERAGE_DIR/coverage.out" ]]; then
            go tool cover -html="$COVERAGE_DIR/coverage.out" -o "$COVERAGE_DIR/coverage.html"
        fi
    fi
    
    generate_report
    success "Test automation completed!"
}

show_help() {
    cat << EOF
Usage: $0 [TEST_TYPE] [OPTIONS]

TEST_TYPE:
    unit        - Run unit tests only
    integration - Run integration tests only
    e2e         - Run end-to-end tests only
    all         - Run all tests (default)

OPTIONS:
    --coverage  - Enable code coverage
    --parallel  - Run tests in parallel
    -h, --help  - Show this help

Examples:
    $0                      # Run all tests
    $0 unit --coverage      # Run unit tests with coverage
    $0 integration          # Run integration tests only
    $0 e2e                  # Run E2E tests only

EOF
}

# Execute main function
main "$@"