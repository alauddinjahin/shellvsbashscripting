#!/bin/bash

# build.sh - Universal build script for multiple programming languages
# Usage: ./build.sh [language] [project_name] [environment]

set -e  # Exit on any error

# Configuration
BUILD_DIR="build"
DIST_DIR="dist"
LOG_FILE="build.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Clean previous builds
clean_build() {
    log "Cleaning previous builds..."
    rm -rf "$BUILD_DIR" "$DIST_DIR"
    mkdir -p "$BUILD_DIR" "$DIST_DIR"
}

# Node.js/React build
build_nodejs() {
    log "Building Node.js/React project..."
    
    if [[ ! -f "package.json" ]]; then
        error "package.json not found!"
    fi
    
    # Install dependencies
    log "Installing dependencies..."
    npm ci || npm install
    
    # Run tests
    if npm run test --silent > /dev/null 2>&1; then
        log "Running tests..."
        npm test
    else
        warn "No test script found, skipping tests"
    fi
    
    # Build project
    log "Building project..."
    npm run build
    
    # Create distribution package
    tar -czf "$DIST_DIR/${PROJECT_NAME:-app}_${TIMESTAMP}.tar.gz" build/
    success "Node.js build completed"
}

# Java build
build_java() {
    log "Building Java project..."
    
    if [[ -f "pom.xml" ]]; then
        # Maven project
        log "Maven project detected"
        mvn clean compile package -DskipTests=false
        cp target/*.jar "$DIST_DIR/"
    elif [[ -f "build.gradle" ]]; then
        # Gradle project
        log "Gradle project detected"
        ./gradlew clean build
        cp build/libs/*.jar "$DIST_DIR/"
    else
        # Plain Java compilation
        log "Compiling Java files..."
        find src -name "*.java" > sources.txt
        javac -d "$BUILD_DIR" -cp "lib/*" @sources.txt
        jar cvf "$DIST_DIR/${PROJECT_NAME:-app}.jar" -C "$BUILD_DIR" .
        rm sources.txt
    fi
    
    success "Java build completed"
}

# Python build
build_python() {
    log "Building Python project..."
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        log "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    if [[ -f "requirements.txt" ]]; then
        log "Installing dependencies..."
        pip install -r requirements.txt
    fi
    
    # Run tests
    if [[ -d "tests" ]] || [[ -f "test_*.py" ]]; then
        log "Running tests..."
        python -m pytest tests/ || python -m unittest discover
    fi
    
    # Create distribution
    if [[ -f "setup.py" ]]; then
        python setup.py sdist bdist_wheel
        cp dist/* "$DIST_DIR/"
    else
        # Create a simple package
        tar -czf "$DIST_DIR/${PROJECT_NAME:-app}_${TIMESTAMP}.tar.gz" \
            --exclude=venv --exclude=__pycache__ --exclude=.git .
    fi
    
    deactivate
    success "Python build completed"
}

# Go build
build_go() {
    log "Building Go project..."
    
    # Get dependencies
    if [[ -f "go.mod" ]]; then
        go mod tidy
        go mod download
    else
        go get ./...
    fi
    
    # Run tests
    log "Running tests..."
    go test ./...
    
    # Build binary
    BINARY_NAME="${PROJECT_NAME:-app}"
    log "Building binary: $BINARY_NAME"
    
    # Build for multiple platforms
    for GOOS in linux windows darwin; do
        for GOARCH in amd64 arm64; do
            if [[ "$GOOS" == "windows" ]]; then
                BINARY_EXT=".exe"
            else
                BINARY_EXT=""
            fi
            
            log "Building for $GOOS/$GOARCH..."
            GOOS=$GOOS GOARCH=$GOARCH go build -o "$DIST_DIR/${BINARY_NAME}_${GOOS}_${GOARCH}${BINARY_EXT}"
        done
    done
    
    success "Go build completed"
}

# Main execution
main() {
    local LANGUAGE=${1:-"auto"}
    PROJECT_NAME=${2:-$(basename "$PWD")}
    local ENVIRONMENT=${3:-"production"}
    
    log "Starting build process..."
    log "Language: $LANGUAGE"
    log "Project: $PROJECT_NAME"
    log "Environment: $ENVIRONMENT"
    
    clean_build
    
    # Auto-detect language if not specified
    if [[ "$LANGUAGE" == "auto" ]]; then
        if [[ -f "package.json" ]]; then
            LANGUAGE="nodejs"
        elif [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
            LANGUAGE="java"
        elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
            LANGUAGE="python"
        elif [[ -f "go.mod" ]] || [[ -f "main.go" ]]; then
            LANGUAGE="go"
        else
            error "Cannot auto-detect language. Please specify explicitly."
        fi
        log "Auto-detected language: $LANGUAGE"
    fi
    
    # Execute appropriate build function
    case "$LANGUAGE" in
        "nodejs"|"node"|"react")
            build_nodejs
            ;;
        "java")
            build_java
            ;;
        "python"|"py")
            build_python
            ;;
        "go"|"golang")
            build_go
            ;;
        *)
            error "Unsupported language: $LANGUAGE"
            ;;
    esac
    
    log "Build artifacts created in: $DIST_DIR"
    ls -la "$DIST_DIR"
    
    success "Build process completed successfully!"
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [LANGUAGE] [PROJECT_NAME] [ENVIRONMENT]

LANGUAGE:
    auto        - Auto-detect language (default)
    nodejs      - Node.js/React projects
    java        - Java projects (Maven/Gradle)
    python      - Python projects
    go          - Go projects

PROJECT_NAME:   Name of the project (default: current directory name)
ENVIRONMENT:    Target environment (default: production)

Examples:
    $0                          # Auto-detect and build
    $0 nodejs myapp production  # Build Node.js app
    $0 java myservice          # Build Java service
    $0 python mypackage dev    # Build Python package for dev

EOF
}

# Check for help flag
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Execute main function
main "$@"