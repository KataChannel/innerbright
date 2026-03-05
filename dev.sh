#!/bin/bash

echo "Chọn tùy chọn chạy:"
echo "1. Chạy dev (next dev)"
echo "2. Auto push git"
read -p "Lựa chọn của bạn (1/2): " opt

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
else
    echo "Lựa chọn không hợp lệ."
fi
