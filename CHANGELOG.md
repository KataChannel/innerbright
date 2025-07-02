# Changelog - KataCore StartKit v2

## [2.0.0] - 2025-01-02

### 🚀 Major Changes - StartKit v2
- **Auto-Environment Generation**: Tự động tạo `.env.prod` với credentials an toàn
- **Auto-SSL Configuration**: Tự động cấu hình SSL certificate với Let's Encrypt  
- **Smart Deployment Detection**: Tự động phát hiện deployment lần đầu vs update
- **Minimal Configuration**: Chỉ cần IP server và domain
- **Update Management**: Cập nhật NextJS/NestJS/Prisma tự động
- **Enhanced Security**: Auto-generate password 16-64 ký tự

### ✨ New Features
- Single command deployment: `./startkit-deployer.sh --host IP --domain DOMAIN`
- Auto-detect first deployment vs updates
- Auto-generate secure environment variables
- Auto-configure SSL certificates and renewal
- Smart update management (only update what changed)
- Simplified codebase (removed 80% of helper scripts)

### 🔧 Improvements
- Consolidated deployment logic into single script
- Removed redundant helper scripts
- Streamlined configuration process
- Enhanced error handling and logging
- Better deployment status reporting

### 🗑️ Removed (Deprecated in v2)
- `universal-deployer.sh` (replaced by `startkit-deployer.sh`)
- `quick-deploy.sh` and related scripts
- Multiple helper scripts in `scripts/` directory
- Manual environment configuration
- Complex deployment modes

### 📝 Migration Guide from v1 to v2
1. Use new deployment command: `./startkit-deployer.sh --host IP --domain DOMAIN`
2. Remove old `.env.prod` file (will be auto-generated)
3. Update npm scripts to use new deployer
4. SSL now auto-configured (no manual setup needed)

---

## [1.0.0] - Previous Version
- Legacy deployment system
- Manual environment configuration
- Multiple deployment scripts
- Manual SSL setup
