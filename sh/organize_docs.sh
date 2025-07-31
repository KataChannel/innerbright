#!/bin/bash

# Script để tổ chức và đánh số lại các file .md theo thứ tự ngày tạo

echo "🧹 Bắt đầu tổ chức và làm sạch tài liệu..."

# Tạo thư mục docs nếu chưa có
mkdir -p docs/archived

# Lấy danh sách file .md (trừ README.md) theo thứ tự thời gian tạo
files=(
    "/chikiet/kataoffical/innerbright/CHANGELOG.md"
    "/chikiet/kataoffical/innerbright/docs/api/AUTH-API.md"
    "/chikiet/kataoffical/innerbright/docs/api/HRM-API.md"
    "/chikiet/kataoffical/innerbright/docs/api/SYSTEM-API.md"
    "/chikiet/kataoffical/innerbright/docs/DEPLOYMENT-README.md"
    "/chikiet/kataoffical/innerbright/docs/DOCS-INDEX.md"
    "/chikiet/kataoffical/innerbright/docs/GETTING-STARTED.md"
    "/chikiet/kataoffical/innerbright/docs/guides/ARCHITECTURE.md"
    "/chikiet/kataoffical/innerbright/docs/guides/DEVELOPMENT.md"
    "/chikiet/kataoffical/innerbright/docs/troubleshooting/TROUBLESHOOTING.md"
    "/chikiet/kataoffical/innerbright/CLEANUP-SUMMARY.md"
    "/chikiet/kataoffical/innerbright/SCRIPTS-GUIDE.md"
    "/chikiet/kataoffical/innerbright/site/AUTH-DEVELOPER-GUIDE.md"
    "/chikiet/kataoffical/innerbright/site/AUTH-FINAL-COMPLETION.md"
    "/chikiet/kataoffical/innerbright/site/AUTH-FINAL-STATUS.md"
    "/chikiet/kataoffical/innerbright/site/AUTH-ISSUE-RESOLUTION.md"
    "/chikiet/kataoffical/innerbright/site/AUTH-SYNC-SUMMARY.md"
    "/chikiet/kataoffical/innerbright/site/PERMISSIONS-FINAL-COMPLETION.md"
    "/chikiet/kataoffical/innerbright/site/PERMISSIONS-SETUP-COMPLETE.md"
    "/chikiet/kataoffical/innerbright/site/PERMISSIONS-SYSTEM-GUIDE.md"
    "/chikiet/kataoffical/innerbright/site/SYSTEM-COMPLETION-FINAL.md"
    "/chikiet/kataoffical/innerbright/docs/SEED-README.md"
)

# Danh sách file README sẽ không di chuyển
echo "📋 Các file README.md sẽ được giữ nguyên vị trí..."

counter=1
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        # Lấy tên file gốc
        basename_file=$(basename "$file")
        
        # Tạo tên file mới với số thứ tự
        new_name=$(printf "%02d_%s" $counter "$basename_file")
        
        # Đường dẫn đích
        dest_path="docs/archived/$new_name"
        
        echo "📄 [$counter] $basename_file -> $new_name"
        
        # Di chuyển file
        mv "$file" "$dest_path"
        
        ((counter++))
    fi
done

echo ""
echo "🧹 Làm sạch thư mục trống..."

# Xóa các thư mục trống trong docs
find docs -type d -empty -delete 2>/dev/null

# Xóa các thư mục trống trong site
find site -type d -empty -delete 2>/dev/null

echo ""
echo "✅ Hoàn thành tổ chức tài liệu!"
echo "📁 Tất cả file .md đã được di chuyển vào docs/archived/ với số thứ tự"
echo "📋 File README.md được giữ nguyên vị trí gốc"
echo ""
echo "📊 Thống kê:"
echo "   - Số file đã tổ chức: $((counter-1))"
echo "   - Thư mục đích: docs/archived/"
echo ""
