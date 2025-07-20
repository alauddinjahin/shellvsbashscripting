#!/bin/bash

# setup_dev_env.sh - Development Environment Setup Automation
# Usage: ./setup_dev_env.sh [project_type] [--docker] [--minimal]

set -e

# Configuration
PROJECT_TYPE=${1:-"auto"}
USE_DOCKER=false
MINIMAL_SETUP=false
SETUP_LOG="setup-$(date +%Y%m%d_%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)
            USE_DOCKER=true
            shift
            ;;
        --minimal)
            MINIMAL_SETUP=true
            shift
            ;;
        nodejs|python|java|go|fullstack)
            PROJECT_TYPE=$1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$SETUP_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$SETUP_LOG"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$SETUP_LOG"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$SETUP_LOG"
}

section() {
    echo -e "\n${PURPLE}========== $1 ==========${NC}\n"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="ubuntu"
            PACKAGE_MANAGER="apt"
        elif command -v yum &> /dev/null; then
            OS="centos"
            PACKAGE_MANAGER="yum"
        elif command -v pacman &> /dev/null; then
            OS="arch"
            PACKAGE_MANAGER="pacman"
        else
            OS="linux"
            PACKAGE_MANAGER="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PACKAGE_MANAGER="brew"
    else
        OS="unknown"
        PACKAGE_MANAGER="unknown"
    fi
    
    log "Detected OS: $OS with package manager: $PACKAGE_MANAGER"
}

# Install system dependencies
install_system_deps() {
    section "INSTALLING SYSTEM DEPENDENCIES"
    
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt update
            sudo apt install -y curl wget git vim build-essential \
                software-properties-common apt-transport-https ca-certificates \
                gnupg lsb-release unzip
            ;;
        "yum")
            sudo yum update -y
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y curl wget git vim unzip
            ;;
        "brew")
            if ! command -v brew &> /dev/null; then
                log "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew update
            brew install curl wget git vim
            ;;
        "pacman")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm base-devel curl wget git vim unzip
            ;;
    esac
    
    success "System dependencies installed"
}

# Setup Git configuration
setup_git() {
    section "SETTING UP GIT"
    
    if ! git config --global user.name &>/dev/null; then
        read -p "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi
    
    if ! git config --global user.email &>/dev/null; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi
    
    # Set up useful Git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    
    # Set up Git hooks directory
    mkdir -p .git/hooks
    
    # Pre-commit hook template
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook to run linting and tests

set -e

echo "Running pre-commit checks..."

# Check for large files
if git diff --cached --name-only | xargs ls -la 2>/dev/null | awk '$5 > 5242880 { print $9 ": " $5/1048576 " MB" }' | grep .; then
    echo "ERROR: Large files detected (>5MB). Please use Git LFS."
    exit 1
fi

# Language-specific checks
if [[ -f "package.json" ]]; then
    npm run lint || exit 1
    npm test || exit 1
fi

if [[ -f "requirements.txt" ]]; then
    flake8 . || exit 1
    python -m pytest || exit 1
fi

echo "Pre-commit checks passed!"
EOF
    
    chmod +x .git/hooks/pre-commit
    
    success "Git configuration completed"
}

# Install Docker
install_docker() {
    section "INSTALLING DOCKER"
    
    case "$OS" in
        "ubuntu")
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        "centos")
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        "macos")
            brew install --cask docker
            ;;
    esac
    
    # Start Docker service
    if [[ "$OS" != "macos" ]]; then
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    fi
    
    success "Docker installation completed"
}

# Setup Node.js environment
setup_nodejs() {
    section "SETTING UP NODE.JS ENVIRONMENT"
    
    # Install Node Version Manager (NVM)
    if [[ ! -d "$HOME/.nvm" ]]; then
        log "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    
    # Install global packages
    npm install -g npm@latest
    npm install -g yarn pnpm
    
    if [[ "$MINIMAL_SETUP" == false ]]; then
        npm install -g nodemon eslint prettier @vue/cli @angular/cli create-react-app
        npm install -g typescript ts-node @types/node
        npm install -g pm2 forever
    fi
    
    # Create package.json template
    cat > package-template.json << 'EOF'
{
  "name": "project-name",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "lint": "eslint .",
    "format": "prettier --write ."
  },
  "devDependencies": {
    "eslint": "^8.0.0",
    "prettier": "^2.7.0",
    "jest": "^28.0.0",
    "nodemon": "^2.0.0"
  }
}
EOF
    
    success "Node.js environment setup completed"
}

# Setup Python environment
setup_python() {
    section "SETTING UP PYTHON ENVIRONMENT"
    
    # Install Python 3 if not present
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt install -y python3 python3-pip python3-venv python3-dev
            ;;
        "yum")
            sudo yum install -y python3 python3-pip python3-venv python3-devel
            ;;
        "brew")
            brew install python
            ;;
        "pacman")
            sudo pacman -S --noconfirm python python-pip
            ;;
    esac
    
    # Install pyenv for Python version management
    if [[ ! -d "$HOME/.pyenv" ]]; then
        log "Installing pyenv..."
        curl https://pyenv.run | bash
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi
    
    # Upgrade pip
    python3 -m pip install --upgrade pip
    
    # Install common packages
    python3 -m pip install virtualenv pipenv poetry
    
    if [[ "$MINIMAL_SETUP" == false ]]; then
        python3 -m pip install flake8 black isort mypy pytest pytest-cov
        python3 -m pip install jupyter notebook ipython
        python3 -m pip install requests fastapi django flask
    fi
    
    # Create requirements template
    cat > requirements-template.txt << 'EOF'
# Production dependencies
requests>=2.28.0
fastapi>=0.68.0
uvicorn>=0.15.0

# Development dependencies
pytest>=7.0.0
pytest-cov>=3.0.0
flake8>=5.0.0
black>=22.0.0
isort>=5.10.0
mypy>=0.971
EOF
    
    # Create virtual environment template script
    cat > create-venv.sh << 'EOF'
#!/bin/bash
# Create and activate virtual environment

ENV_NAME=${1:-venv}

echo "Creating virtual environment: $ENV_NAME"
python3 -m venv $ENV_NAME

echo "Activating virtual environment..."
source $ENV_NAME/bin/activate

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing requirements..."
if [[ -f "requirements.txt" ]]; then
    pip install -r requirements.txt
fi

echo "Virtual environment '$ENV_NAME' created and activated!"
echo "To activate in the future, run: source $ENV_NAME/bin/activate"
EOF
    
    chmod +x create-venv.sh
    
    success "Python environment setup completed"
}

# Setup Java environment
setup_java() {
    section "SETTING UP JAVA ENVIRONMENT"
    
    # Install OpenJDK
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt install -y openjdk-17-jdk openjdk-17-jre maven gradle
            ;;
        "yum")
            sudo yum install -y java-17-openjdk java-17-openjdk-devel maven gradle
            ;;
        "brew")
            brew install openjdk@17 maven gradle
            ;;
        "pacman")
            sudo pacman -S --noconfirm jdk17-openjdk maven gradle
            ;;
    esac
    
    # Install SDKMAN for Java version management
    if [[ ! -d "$HOME/.sdkman" ]]; then
        log "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        # Install Java versions
        sdk install java 17.0.2-open
        sdk install maven
        sdk install gradle
    fi
    
    # Set JAVA_HOME
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
    echo 'export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' >> ~/.bashrc
    
    # Create Maven project template
    cat > create-maven-project.sh << 'EOF'
#!/bin/bash
# Create Maven project template

GROUP_ID=${1:-com.example}
ARTIFACT_ID=${2:-my-app}
VERSION=${3:-1.0-SNAPSHOT}

mvn archetype:generate \
    -DgroupId=$GROUP_ID \
    -DartifactId=$ARTIFACT_ID \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DinteractiveMode=false \
    -Dversion=$VERSION

echo "Maven project created: $ARTIFACT_ID"
EOF
    
    chmod +x create-maven-project.sh
    
    success "Java environment setup completed"
}


# Setup Go environment
setup_go() {
    section "SETTING UP GO ENVIRONMENT"
    
    # Install Go
    case "$PACKAGE_MANAGER" in
        "apt")
            wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
            rm go1.21.0.linux-amd64.tar.gz
            ;;
        "yum")
            wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
            rm go1.21.0.linux-amd64.tar.gz
            ;;
        "brew")
            brew install go
            ;;
        "pacman")
            sudo pacman -S --noconfirm go
            ;;
    esac
    
    # Set up Go environment variables
    export GOPATH="$HOME/go"
    export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
    
    echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
    echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> ~/.bashrc
    
    # Create Go workspace
    mkdir -p "$GOPATH"/{bin,pkg,src}
    
    # Install common Go tools
    if [[ "$MINIMAL_SETUP" == false ]]; then
        go install golang.org/x/tools/gopls@latest
        go install github.com/go-delve/delve/cmd/dlv@latest
        go install honnef.co/go/tools/cmd/staticcheck@latest
        go install golang.org/x/tools/cmd/goimports@latest
    fi

    cat > init-go-project.sh << 'EOF'
    # Initialize Go project

MODULE_NAME=${1:-example.com/myproject}

go mod init $MODULE_NAME

# Create main.go
cat > main.go << 'GOEOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
GOEOF

# Create basic structure
mkdir -p {cmd,internal,pkg,api,web,configs,scripts,build,deployments}

echo "Go project initialized: $MODULE_NAME"
EOF
    
    chmod +x init-go-project.sh
    
    success "Go environment setup completed"
}



# Setup database tools
setup_databases() {
    section "SETTING UP DATABASE TOOLS"
    
    # Install database clients
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt install -y postgresql-client mysql-client redis-tools mongodb-clients
            ;;
        "yum")
    esac 
}