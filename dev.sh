#!/bin/bash

echo "Chọn tùy chọn chạy:"
echo "1. Chạy dev (next dev)"
echo "2. Auto push git"
echo "3. Deploy Docker"
read -p "Lựa chọn của bạn (1/2/3): " opt

if [ "$opt" == "1" ]; then
    next dev
elif [ "$opt" == "2" ]; then
    read -p "Nhập message commit: " msg
    if [ -z "$msg" ]; then
        msg="Update from dev script"
    fi
    git add .
    git commit -m "$msg"
    git push
elif [ "$opt" == "3" ]; then
    echo "Đang triển khai với Docker..."
    docker compose up -d --build
else
    echo "Lựa chọn không hợp lệ."
fi
