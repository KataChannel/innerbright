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
    IMAGE_NAME="innerbright-frontend"
    # Host SSH được cấu hình trong ~/.ssh/config hoặc IP trực tiếp
    REMOTE_SERVER="innerbright-116.118.48.208"
    REMOTE_DIR="/root/innerbright/frontend"

    echo "--- Đang triển khai tới server $REMOTE_SERVER ---"
    
    echo "1. Đang build Docker image: $IMAGE_NAME..."
    docker build -t $IMAGE_NAME .
    
    if [ $? -ne 0 ]; then
        echo "Lỗi: Build image thất bại."
        exit 1
    fi

    echo "2. Đang copy image lên server..."
    # Save, compress and load over SSH
    docker save $IMAGE_NAME | gzip | ssh $REMOTE_SERVER "docker load"

    echo "3. Đang cập nhật docker-compose và deploy..."
    ssh $REMOTE_SERVER "mkdir -p $REMOTE_DIR"
    scp docker-compose.yml $REMOTE_SERVER:$REMOTE_DIR/
    
    echo "Dọn dẹp các container đang chiếm dụng port 3005..."
    # Tìm container ID đang map tới port 3005 và stop/rm nó
    ssh $REMOTE_SERVER "
        CONTAINER_ID=\$(docker ps -q --filter publish=3005)
        if [ ! -z \"\$CONTAINER_ID\" ]; then
            echo \"Đang dừng container \$CONTAINER_ID đang dùng port 3005...\"
            docker rm -f \$CONTAINER_ID
        fi
        cd $REMOTE_DIR && docker compose down && docker compose up -d
    "
    
    echo "--- Triển khai HOÀN TẤT! ---"
else
    echo "Lựa chọn không hợp lệ."
fi
