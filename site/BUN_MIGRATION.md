# Migration Guide: Node.js to Bun.js

## Overview
This project has been migrated from Node.js to Bun.js for better performance and modern JavaScript runtime capabilities.

## Prerequisites
- Install Bun.js: `curl -fsSL https://bun.sh/install | bash`
- Restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`)

## Migration Steps Completed

### 1. Package.json Updates
- Updated all scripts to use `bun run` instead of direct commands
- Added `engines` field to specify Bun version requirement
- Replaced `pnpm` configuration with `trustedDependencies` for Bun
- Added Prisma-specific scripts for easier database management

### 2. Bun Configuration
- Created `bunfig.toml` for Bun-specific configuration
- Configured trusted dependencies for native modules
- Set up proper environment variables

### 3. Docker Updates
- Switched base image from `node:20-alpine` to `oven/bun:1-alpine`
- Updated all build commands to use Bun
- Modified user/group setup for Bun compatibility
- Updated build script to use new image names

## How to Use

### Local Development
```bash
# Install dependencies
bun install

# Run development server
bun run dev

# Build for production
bun run build

# Start production server
bun run start

# Database operations
bun run prisma:generate
bun run prisma:migrate
bun run prisma:studio
```

### Docker Deployment
```bash
# Build and run with Docker
chmod +x docker-build.sh
./docker-build.sh
```

## Benefits of Bun.js

1. **Performance**: Significantly faster package installation and runtime
2. **Built-in tools**: Bundler, test runner, and package manager in one
3. **TypeScript support**: Native TypeScript execution without compilation
4. **Compatibility**: Drop-in replacement for Node.js with better performance
5. **Modern APIs**: Built-in support for modern web APIs

## Compatibility Notes

- All existing Node.js code remains compatible
- Prisma works seamlessly with Bun
- Next.js fully supports Bun runtime
- All dependencies are compatible with Bun

## Troubleshooting

### If you encounter issues:

1. **Clear cache**: `rm -rf node_modules bun.lockb && bun install`
2. **Regenerate Prisma**: `bun run prisma:generate`
3. **Check Bun version**: `bun --version` (should be 1.0.0 or higher)

### Common Issues:

- **Native modules**: Some packages may need to be in `trustedDependencies`
- **Environment variables**: Make sure all env vars are properly set
- **Docker builds**: Ensure you're using the new image names

## Performance Comparison

Typical improvements you should see:
- Package installation: ~3-5x faster
- Development server startup: ~2-3x faster
- Build times: ~10-20% faster
- Memory usage: ~15-30% lower

## Next Steps

1. Update your CI/CD pipelines to use Bun
2. Consider using Bun's built-in test runner
3. Explore Bun's bundling capabilities
4. Update documentation for team members

## Rollback Plan

If you need to rollback to Node.js:
1. Restore original `package.json` scripts
2. Remove `bunfig.toml`
3. Restore original `Dockerfile`
4. Use `npm install` or `pnpm install` instead of `bun install`
