#!/bin/bash
# deploy.sh - Application deployment automation

# Configuration
APP_NAME="myapp"
DEPLOY_USER="deploy"
DEPLOY_HOST="production.server.com"
REPO_URL="git@github.com:company/myapp.git"
DEPLOY_PATH="/var/www/$APP_NAME"
BACKUP_PATH="/backup/deployments"
SERVICE_NAME="myapp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}[$(date '+%H:%M:%S')] $message${NC}"
}

# Function to run command with error checking
run_command() {
    local command="$1"
    local description="$2"
    
    print_status "$YELLOW" "Running: $description"
    
    if eval "$command"; then
        print_status "$GREEN" "Success: $description"
        return 0
    else
        print_status "$RED" "Failed: $description"
        return 1
    fi
}

# Function to create backup
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_PATH/${APP_NAME}_${timestamp}"
    
    print_status "$YELLOW" "Creating backup..."
    
    if [[ -d "$DEPLOY_PATH" ]]; then
        mkdir -p "$BACKUP_PATH"
        cp -r "$DEPLOY_PATH" "$backup_dir"
        print_status "$GREEN" "Backup created: $backup_dir"
        echo "$backup_dir" > /tmp/last_backup_path
        return 0
    else
        print_status "$YELLOW" "No existing deployment to backup"
        return 0
    fi
}

# Function to deploy application
deploy_application() {
    local branch="${1:-main}"
    
    print_status "$YELLOW" "Deploying branch: $branch"
    
    # Create deploy directory if it doesn't exist
    run_command "mkdir -p '$DEPLOY_PATH'" "Creating deploy directory" || return 1
    
    # Clone or pull repository
    if [[ -d "$DEPLOY_PATH/.git" ]]; then
        cd "$DEPLOY_PATH"
        run_command "git fetch origin" "Fetching latest changes" || return 1
        run_command "git checkout '$branch'" "Switching to branch $branch" || return 1
        run_command "git pull origin '$branch'" "Pulling latest changes" || return 1
    else
        run_command "git clone '$REPO_URL' '$DEPLOY_PATH'" "Cloning repository" || return 1
        cd "$DEPLOY_PATH"
        run_command "git checkout '$branch'" "Switching to branch $branch" || return 1
    fi
    
    return 0
}

# Function to install dependencies
install_dependencies() {
    cd "$DEPLOY_PATH"
    
    # Check for different dependency managers
    if [[ -f "package.json" ]]; then
        run_command "npm install --production" "Installing Node.js dependencies" || return 1
    fi
    
    if [[ -f "requirements.txt" ]]; then
        run_command "pip install -r requirements.txt" "Installing Python dependencies" || return 1
    fi
    
    if [[ -f "composer.json" ]]; then
        run_command "composer install --no-dev" "Installing PHP dependencies" || return 1
    fi
    
    if [[ -f "Gemfile" ]]; then
        run_command "bundle install" "Installing Ruby dependencies" || return 1
    fi
    
    return 0
}

# Function to run database migrations
run_migrations() {
    cd "$DEPLOY_PATH"
    
    if [[ -f "manage.py" ]]; then
        # Django
        run_command "python manage.py migrate" "Running Django migrations" || return 1
    elif [[ -f "artisan" ]]; then
        # Laravel
        run_command "php artisan migrate --force" "Running Laravel migrations" || return 1
    elif [[ -f "knexfile.js" ]]; then
        # Knex.js
        run_command "npx knex migrate:latest" "Running Knex migrations" || return 1
    fi
    
    return 0
}

# Function to build application
build_application() {
    cd "$DEPLOY_PATH"
    
    if [[ -f "package.json" ]] && grep -q "build" package.json; then
        run_command "npm run build" "Building application" || return 1
    fi
    
    if [[ -f "webpack.config.js" ]]; then
        run_command "npx webpack --mode production" "Running Webpack build" || return 1
    fi
    
    return 0
}

# Function to restart services
restart_services() {
    run_command "sudo systemctl restart '$SERVICE_NAME'" "Restarting $SERVICE_NAME service" || return 1
    run_command "sudo systemctl reload nginx" "Reloading Nginx" || return 1
    
    return 0
}

# Function to run health check
health_check() {
    local max_attempts=30
    local attempt=1
    local health_url="http://localhost/health"
    
    print_status "$YELLOW" "Running health check..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f -s "$health_url" > /dev/null; then
            print_status "$GREEN" "Health check passed"
            return 0
        fi
        
        print_status "$YELLOW" "Health check attempt $attempt/$max_attempts failed, retrying..."
        sleep 2
        ((attempt++))
    done
    
    print_status "$RED" "Health check failed after $max_attempts attempts"
    return 1
}

# Function to rollback deployment
rollback() {
    if [[ -f /tmp/last_backup_path ]]; then
        local backup_path=$(cat /tmp/last_backup_path)
        
        print_status "$YELLOW" "Rolling back to: $backup_path"
        
        if [[ -d "$backup_path" ]]; then
            rm -rf "$DEPLOY_PATH"
            cp -r "$backup_path" "$DEPLOY_PATH"
            restart_services
            print_status "$GREEN" "Rollback completed"
            return 0
        else
            print_status "$RED" "Backup path not found: $backup_path"
            return 1
        fi
    else
        print_status "$RED" "No backup available for rollback"
        return 1
    fi
}

# Function to cleanup old backups
cleanup_backups() {
    print_status "$YELLOW" "Cleaning up old backups..."
    find "$BACKUP_PATH" -name "${APP_NAME}_*" -type d -mtime +7 -exec rm -rf {} \;
    print_status "$GREEN" "Backup cleanup completed"
}

# Main deployment function
main() {
    local branch="${1:-main}"
    local skip_backup="${2:-false}"
    
    print_status "$GREEN" "Starting deployment of $APP_NAME (branch: $branch)"
    
    # Create backup unless skipped
    if [[ "$skip_backup" != "true" ]]; then
        create_backup || {
            print_status "$RED" "Backup failed, aborting deployment"
            exit 1
        }
    fi
    
    # Deploy application
    deploy_application "$branch" || {
        print_status "$RED" "Deployment failed, rolling back..."
        rollback
        exit 1
    }
    
    # Install dependencies
    install_dependencies || {
        print_status "$RED" "Dependency installation failed, rolling back..."
        rollback
        exit 1
    }
    
    # Build application
    build_application || {
        print_status "$RED" "Build failed, rolling back..."
        rollback
        exit 1
    }
    
    # Run migrations
    run_migrations || {
        print_status "$RED" "Migrations failed, rolling back..."
        rollback
        exit 1
    }
    
    # Restart services
    restart_services || {
        print_status "$RED" "Service restart failed, rolling back..."
        rollback
        exit 1
    }
    
    # Run health check
    health_check || {
        print_status "$RED" "Health check failed, rolling back..."
        rollback
        exit 1
    }
    
    # Cleanup old backups
    cleanup_backups
    
    print_status "$GREEN" "Deployment completed successfully!"
}

# Handle command line arguments
case "$1" in
    "rollback")
        rollback
        ;;
    "health")
        health_check
        ;;
    *)
        main "$@"
        ;;
esac