# 🔧 PWA Deployment Fix Guide

## Vấn đề: PWA scope: / bị đứng khi deploy lên cloud server

### 🔍 Nguyên nhân phổ biến:

1. **Service Worker không được serve đúng cách**
2. **Scope configuration sai trong manifest**  
3. **Nginx không hỗ trợ Service Worker**
4. **HTTPS không được cấu hình (PWA yêu cầu HTTPS)**
5. **Cache headers không phù hợp**

---

## ✅ Giải pháp đã triển khai:

### 1. **Fixed Manifest Configuration**
```json
{
  "scope": "/",          // Thay đổi từ "./"
  "start_url": "/",      // Thay đổi từ "./"
  // ... other config
}
```

### 2. **Enhanced next-pwa Configuration**
```typescript
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  scope: '/',                    // Explicit scope
  sw: 'sw.js',                  // Service worker file
  runtimeCaching: [...],        // Custom caching rules
  buildExcludes: [/middleware-manifest\.json$/],
  disable: false,               // Always enable PWA
});
```

### 3. **Nginx Configuration for PWA**
- Service Worker không được cache (`no-cache`)
- Manifest files có cache ngắn hạn (`max-age=300`)
- Workbox files có cache với revalidation
- CORS headers cho PWA assets

### 4. **Deployment Script**
Script `fix-pwa-deployment.sh` để:
- Verify PWA configuration
- Rebuild assets
- Test service worker endpoints
- Provide deployment instructions

---

## 🚀 Deployment Steps:

### Bước 1: Chạy PWA Fix Script
```bash
./fix-pwa-deployment.sh
```

### Bước 2: Deploy lên server
```bash
# Upload code
git push origin main

# Trên server:
cd /path/to/your/app
git pull origin main

# Build PWA
cd site
bun install
bun run build
```

### Bước 3: Update Nginx
```bash
# Copy nginx config
sudo cp nginx.conf /etc/nginx/sites-available/innerbright

# Test và reload
sudo nginx -t
sudo systemctl reload nginx
```

### Bước 4: Ensure HTTPS
```bash
# PWA requires HTTPS in production
sudo certbot --nginx -d yourdomain.com
```

---

## 🧪 Testing PWA:

### 1. **Browser DevTools**
- **Application Tab** > Service Workers
- **Application Tab** > Manifest  
- **Network Tab** > Check SW registration

### 2. **Service Worker Endpoints**
```bash
curl -I https://yourdomain.com/sw.js
curl -I https://yourdomain.com/manifest.json
```

### 3. **PWA Installation**
- Chrome: Look for "Install" button in address bar
- Mobile: "Add to Home Screen" option

---

## 🐛 Troubleshooting:

### Service Worker Not Registering:
```bash
# Check nginx logs
sudo tail -f /var/log/nginx/error.log

# Check Next.js logs  
pm2 logs site
```

### Manifest Not Loading:
```bash
# Verify manifest endpoint
curl https://yourdomain.com/manifest.json

# Check Content-Type header
curl -I https://yourdomain.com/manifest.json
```

### PWA Not Installing:
1. Clear browser cache completely
2. Ensure HTTPS is working
3. Check DevTools > Application > Manifest for errors
4. Verify all required manifest fields

### Cache Issues:
```bash
# Clear service worker cache
# In DevTools > Application > Storage > Clear storage

# Force service worker update
# In DevTools > Application > Service Workers > Update
```

---

## 📁 File Changes Made:

### `/site/public/manifest.json`
- ✅ Changed `scope` from `"./"` to `"/"`
- ✅ Changed `start_url` from `"./"` to `"/"`

### `/site/public/manifest.webmanifest`  
- ✅ Same changes as manifest.json

### `/site/next.config.ts`
- ✅ Enhanced PWA configuration
- ✅ Added explicit scope and caching rules

### `/nginx.conf`
- ✅ Added Service Worker specific headers
- ✅ Added PWA manifest handling
- ✅ Added Workbox files caching

### New Files:
- ✅ `/fix-pwa-deployment.sh` - Deployment script
- ✅ `/nginx/conf.d/pwa.conf` - PWA nginx config

---

## 🔄 Next Steps:

1. **Test locally first:**
   ```bash
   cd site
   bun run build
   bun run start
   # Test http://localhost:3000
   ```

2. **Deploy to server:**
   ```bash
   ./fix-pwa-deployment.sh
   # Follow deployment instructions
   ```

3. **Verify HTTPS:**
   ```bash
   # Ensure SSL certificate is valid
   openssl s_client -connect yourdomain.com:443
   ```

4. **Test PWA functionality:**
   - Service Worker registration
   - Offline functionality  
   - Install prompt
   - Push notifications (if configured)

---

## 📞 Support:

Nếu vẫn gặp vấn đề:

1. Check browser console for errors
2. Verify network requests in DevTools
3. Test on different browsers/devices
4. Ensure domain is properly configured with HTTPS

**Common PWA Requirements:**
- ✅ HTTPS (mandatory in production)
- ✅ Valid manifest.json
- ✅ Service Worker registration
- ✅ Icons (multiple sizes)
- ✅ Proper cache headers
