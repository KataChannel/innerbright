# Git Auto-Push Configuration

This document explains the git auto-push setup for the KataCore project.

## 🚀 Quick Start

### Initial Setup
```bash
# Run the setup script once
./scripts/setup-git-auto.sh
```

### Basic Usage
```bash
# Auto commit and push all changes
bun run git:push

# Quick save with timestamp
bun run git:save

# Build project first, then push (recommended)
bun run git:build-push

# Start auto-commit watch mode (checks every 10 minutes)
bun run git:watch
```

## 📁 Scripts Overview

### 1. `auto-push.sh`
- **Purpose**: Main auto-push script
- **Usage**: `./scripts/auto-push.sh "Commit message"`
- **Features**:
  - Automatically adds all changes
  - Commits with custom or default message
  - Pushes to current branch
  - Error handling and status reporting

### 2. `quick-save.sh`
- **Purpose**: Quick save with timestamp
- **Usage**: `./scripts/quick-save.sh "Optional message"`
- **Features**:
  - Adds timestamp to commit message
  - Perfect for work-in-progress saves

### 3. `build-and-push.sh`
- **Purpose**: Build verification before push
- **Usage**: `./scripts/build-and-push.sh "Optional message"`
- **Features**:
  - Runs `test-build.sh` first
  - Only pushes if build succeeds
  - Prevents pushing broken code

### 4. `watch-auto-commit.sh`
- **Purpose**: Continuous auto-commit
- **Usage**: `./scripts/watch-auto-commit.sh [minutes]`
- **Features**:
  - Monitors for changes every N minutes (default: 10)
  - Auto-commits when changes detected
  - Runs until stopped with Ctrl+C

## ⚙️ Configuration

### Git Settings Applied
```bash
# Auto-push to current branch
git config push.default current
git config push.autoSetupRemote true

# Auto-track branches
git config branch.autosetupmerge always
git config branch.autosetuprebase always

# Auto-prune deleted remote branches
git config fetch.prune true
```

### Useful Git Aliases
```bash
# Quick commit and push
git quick "Your message"

# Save work in progress
git save

# Push and set upstream
git pushup

# Pretty status
git st

# Pretty log
git lg
```

## 🔧 Advanced Usage

### Custom Commit Messages
```bash
# With custom message
./scripts/auto-push.sh "feat: add new feature"
./scripts/quick-save.sh "working on authentication"
./scripts/build-and-push.sh "fix: resolve build issues"
```

### Watch Mode Options
```bash
# Check every 5 minutes
./scripts/watch-auto-commit.sh 5

# Check every 30 minutes
./scripts/watch-auto-commit.sh 30
```

### Manual Git Operations
```bash
# Check status
git status

# View recent commits
git lg

# Push manually
git push origin $(git branch --show-current)
```

## 🔒 Security Notes

- Scripts only work within the git repository
- All changes are added before committing
- Remote repository must be configured
- Ensure you have push permissions to the remote

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x scripts/*.sh
   ```

2. **No Remote Repository**
   ```bash
   git remote add origin <your-repo-url>
   ```

3. **Branch Not Set Up**
   ```bash
   git push --set-upstream origin <branch-name>
   ```

4. **Build Failures**
   ```bash
   # Fix build issues first
   bun run build
   # Then try again
   bun run git:build-push
   ```

## 📋 Integration with Development Workflow

### Recommended Workflow
1. **Development**: Use `bun run dev` for live development
2. **Save Progress**: Use `bun run git:save` for quick saves
3. **Major Changes**: Use `bun run git:build-push` for verified commits
4. **Continuous Work**: Use `bun run git:watch` for automatic saves

### Integration with Package.json Scripts
All git commands are integrated into the main package.json:
- `git:push` - Basic auto-push
- `git:save` - Quick save
- `git:build-push` - Build and push
- `git:watch` - Watch mode

## 🎯 Best Practices

1. **Use descriptive commit messages** when possible
2. **Use build-and-push** for production-ready commits
3. **Use watch mode** during long development sessions
4. **Use quick-save** for experimental work
5. **Review changes** before pushing important commits

This setup ensures your KataCore project changes are automatically saved and pushed to git while maintaining code quality through build verification.
