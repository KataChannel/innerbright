# InnerBright Deployment

## Quick Start

Deploy toàn bộ application lên server chỉ với một lệnh:

```bash
./deploy.sh
```

## What it does

1. **Build** - Builds Next.js app locally với optimization
2. **Package** - Tạo deployment archive 
3. **Upload** - Upload lên server 116.118.48.208
4. **Deploy** - Extract và chạy Docker containers
5. **Verify** - Kiểm tra app hoạt động đúng

## Result

- 🌐 **Website**: http://116.118.48.208:3000
- 🌐 **Domain**: http://innerbright.vn (if configured)

## Requirements

- SSH access to server
- Docker installed on server
- Bun/Node.js locally

## Troubleshooting

```bash
# Check logs
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs'

# Restart
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml restart'
```

See `DEPLOY_GUIDE.md` for detailed documentation.

---

**Previous files backed up:**
- `build-local.sh.backup`
- `deploy-prebuilt-simple.sh.backup`
