#!/bin/bash

# KataCore Auto Git Push Script
# Automatically commits and pushes changes to git repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
DEFAULT_BRANCH="main"
AUTO_COMMIT_MESSAGE="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
FORCE_PUSH=false
VERBOSE=false
DRY_RUN=false
SKIP_TESTS=false
AUTO_PULL=true

# Functions
log() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${PURPLE}🔍 DEBUG: $1${NC}"
    fi
}

# Show banner
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🚀 KataCore Auto Git Push                               ║
║                                                                              ║
║                 Automated Git Workflow Management                           ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Show help
show_help() {
    cat << EOF
KataCore Auto Git Push Script

USAGE:
    ./autopush-git.sh [OPTIONS] [COMMIT_MESSAGE]

OPTIONS:
    -h, --help          Show this help message
    -b, --branch NAME   Target branch (default: main)
    -f, --force         Force push (use with caution)
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without executing
    -t, --skip-tests    Skip running tests before push
    -n, --no-pull       Skip auto-pull before push
    -m, --message MSG   Custom commit message

EXAMPLES:
    ./autopush-git.sh                           # Auto commit with timestamp
    ./autopush-git.sh "Fix API authentication"  # Custom commit message
    ./autopush-git.sh -f -m "Hotfix: urgent"    # Force push with message
    ./autopush-git.sh -d                        # Dry run to see changes
    ./autopush-git.sh -b develop                # Push to develop branch

FEATURES:
    ✅ Auto-detects git repository
    ✅ Checks for uncommitted changes
    ✅ Runs tests before push (optional)
    ✅ Auto-pulls latest changes
    ✅ Handles merge conflicts detection
    ✅ Supports multiple branches
    ✅ Dry-run mode for safety
    ✅ Verbose logging
EOF
}

# Parse command line arguments
parse_arguments() {
    COMMIT_MESSAGE=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--branch)
                DEFAULT_BRANCH="$2"
                shift 2
                ;;
            -f|--force)
                FORCE_PUSH=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -t|--skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            -n|--no-pull)
                AUTO_PULL=false
                shift
                ;;
            -m|--message)
                COMMIT_MESSAGE="$2"
                shift 2
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                # If no message was provided via -m, treat as commit message
                if [ -z "$COMMIT_MESSAGE" ]; then
                    COMMIT_MESSAGE="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Use default message if none provided
    if [ -z "$COMMIT_MESSAGE" ]; then
        COMMIT_MESSAGE="$AUTO_COMMIT_MESSAGE"
    fi
}

# Check if we're in a git repository
check_git_repo() {
    debug "Checking if current directory is a git repository"
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not a git repository. Please run 'git init' first."
    fi
    
    success "Git repository detected"
}

# Check git configuration
check_git_config() {
    debug "Checking git configuration"
    
    if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
        warning "Git user not configured. Setting up default configuration..."
        
        read -p "Enter your git username: " git_username
        read -p "Enter your git email: " git_email
        
        git config user.name "$git_username"
        git config user.email "$git_email"
        
        success "Git configuration updated"
    fi
    
    debug "Git user: $(git config user.name) <$(git config user.email)>"
}

# Check if remote origin exists
check_remote_origin() {
    debug "Checking remote origin"
    
    if ! git remote get-url origin > /dev/null 2>&1; then
        warning "No remote origin found."
        read -p "Enter your git repository URL: " repo_url
        
        if [ ! -z "$repo_url" ]; then
            git remote add origin "$repo_url"
            success "Remote origin added: $repo_url"
        else
            error "Remote origin is required for pushing"
        fi
    fi
    
    local origin_url=$(git remote get-url origin)
    debug "Remote origin: $origin_url"
}

# Check current branch
check_current_branch() {
    local current_branch=$(git branch --show-current)
    debug "Current branch: $current_branch"
    
    if [ "$current_branch" != "$DEFAULT_BRANCH" ]; then
        warning "Current branch '$current_branch' is different from target branch '$DEFAULT_BRANCH'"
        read -p "Do you want to switch to '$DEFAULT_BRANCH'? (y/N): " switch_branch
        
        if [[ $switch_branch =~ ^[Yy]$ ]]; then
            info "Switching to branch '$DEFAULT_BRANCH'"
            if [ "$DRY_RUN" = false ]; then
                git checkout "$DEFAULT_BRANCH" 2>/dev/null || git checkout -b "$DEFAULT_BRANCH"
            fi
        else
            DEFAULT_BRANCH="$current_branch"
            info "Using current branch '$current_branch'"
        fi
    fi
}

# Check for uncommitted changes
check_uncommitted_changes() {
    debug "Checking for uncommitted changes"
    
    if git diff --quiet && git diff --staged --quiet; then
        warning "No changes to commit"
        return 1
    fi
    
    # Show status
    info "Current git status:"
    git status --short
    
    return 0
}

# Run tests (if available and not skipped)
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        warning "Skipping tests (--skip-tests flag used)"
        return 0
    fi
    
    debug "Checking for available test commands"
    
    # Check if package.json exists and has test scripts
    if [ -f "package.json" ]; then
        if grep -q '"test"' package.json; then
            info "Running tests..."
            if [ "$DRY_RUN" = false ]; then
                if command -v bun > /dev/null; then
                    bun test || {
                        error "Tests failed. Use --skip-tests to bypass."
                    }
                elif command -v npm > /dev/null; then
                    npm test || {
                        error "Tests failed. Use --skip-tests to bypass."
                    }
                fi
            else
                info "[DRY RUN] Would run: bun test"
            fi
            success "Tests passed"
        else
            debug "No test script found in package.json"
        fi
    else
        debug "No package.json found"
    fi
}

# Pull latest changes
pull_latest_changes() {
    if [ "$AUTO_PULL" = false ]; then
        warning "Skipping auto-pull (--no-pull flag used)"
        return 0
    fi
    
    info "Pulling latest changes from origin/$DEFAULT_BRANCH"
    
    if [ "$DRY_RUN" = false ]; then
        # Check if remote branch exists
        if git ls-remote --heads origin "$DEFAULT_BRANCH" | grep -q "$DEFAULT_BRANCH"; then
            git pull origin "$DEFAULT_BRANCH" || {
                warning "Pull failed. There might be conflicts to resolve."
                info "Please resolve conflicts manually and run the script again."
                return 1
            }
        else
            info "Remote branch '$DEFAULT_BRANCH' doesn't exist. Will create it on first push."
        fi
    else
        info "[DRY RUN] Would run: git pull origin $DEFAULT_BRANCH"
    fi
    
    success "Repository is up to date"
}

# Add and commit changes
commit_changes() {
    info "Adding all changes to staging"
    
    if [ "$DRY_RUN" = false ]; then
        git add .
    else
        info "[DRY RUN] Would run: git add ."
    fi
    
    info "Committing changes with message: '$COMMIT_MESSAGE'"
    
    if [ "$DRY_RUN" = false ]; then
        git commit -m "$COMMIT_MESSAGE"
    else
        info "[DRY RUN] Would run: git commit -m \"$COMMIT_MESSAGE\""
    fi
    
    success "Changes committed successfully"
}

# Push changes to remote
push_changes() {
    local push_command="git push origin $DEFAULT_BRANCH"
    
    if [ "$FORCE_PUSH" = true ]; then
        push_command="git push --force origin $DEFAULT_BRANCH"
        warning "Force push enabled - this can overwrite remote changes!"
    fi
    
    info "Pushing changes to origin/$DEFAULT_BRANCH"
    
    if [ "$DRY_RUN" = false ]; then
        if [ "$FORCE_PUSH" = true ]; then
            git push --force origin "$DEFAULT_BRANCH"
        else
            git push origin "$DEFAULT_BRANCH"
        fi
    else
        info "[DRY RUN] Would run: $push_command"
    fi
    
    success "Changes pushed successfully"
}

# Show final status
show_final_status() {
    echo
    success "🎉 Git auto-push completed successfully!"
    echo
    info "Summary:"
    echo "  📝 Commit message: $COMMIT_MESSAGE"
    echo "  🌿 Branch: $DEFAULT_BRANCH"
    echo "  📤 Remote: $(git remote get-url origin 2>/dev/null || echo 'Not configured')"
    echo "  📊 Latest commit: $(git log --oneline -1 2>/dev/null || echo 'No commits')"
    echo
    
    if [ "$DRY_RUN" = true ]; then
        warning "This was a dry run. No actual changes were made."
        info "Remove --dry-run flag to execute the commands."
    fi
}

# Main function
main() {
    show_banner
    
    # Parse arguments
    parse_arguments "$@"
    
    if [ "$DRY_RUN" = true ]; then
        warning "DRY RUN MODE - No changes will be made"
        echo
    fi
    
    # Validation steps
    check_git_repo
    check_git_config
    check_remote_origin
    check_current_branch
    
    # Check if there are changes to commit
    if ! check_uncommitted_changes; then
        info "Nothing to push. Repository is clean."
        exit 0
    fi
    
    # Pre-push operations
    pull_latest_changes || exit 1
    run_tests
    
    # Main git operations
    commit_changes
    push_changes
    
    # Show final status
    show_final_status
}

# Run main function with all arguments
main "$@"
