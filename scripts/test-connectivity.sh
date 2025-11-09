#!/bin/bash

# Test server connectivity with multiple methods

SERVER_IP="116.118.48.208"

echo "🔍 Testing server connectivity: ${SERVER_IP}"
echo "================================================"

echo ""
echo "1. Testing PING..."
if ping -c 3 "${SERVER_IP}" >/dev/null 2>&1; then
    echo "✅ PING: Server is reachable"
else
    echo "❌ PING: Server unreachable"
    exit 1
fi

echo ""
echo "2. Testing port 22 (SSH)..."
if timeout 5 bash -c "cat < /dev/null > /dev/tcp/${SERVER_IP}/22" 2>/dev/null; then
    echo "✅ Port 22: Open"
else
    echo "❌ Port 22: Closed or filtered"
fi

echo ""
echo "3. Testing port 14000 (Web App)..."
if timeout 5 bash -c "cat < /dev/null > /dev/tcp/${SERVER_IP}/14000" 2>/dev/null; then
    echo "✅ Port 14000: Open"
    echo "   Testing HTTP response..."
    if curl -s --connect-timeout 5 "http://${SERVER_IP}:14000" >/dev/null 2>&1; then
        echo "✅ HTTP: Application responding"
    else
        echo "❌ HTTP: Application not responding"
    fi
else
    echo "❌ Port 14000: Closed or app down"
fi

echo ""
echo "4. Testing SSH with different timeouts..."

echo "   4a. Quick SSH test (5s)..."
if timeout 5 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@${SERVER_IP} "echo 'Quick test'" 2>/dev/null; then
    echo "✅ SSH (5s): Success"
else
    echo "❌ SSH (5s): Failed"
fi

echo "   4b. Medium SSH test (30s)..."
if timeout 30 ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no root@${SERVER_IP} "echo 'Medium test'" 2>/dev/null; then
    echo "✅ SSH (30s): Success"
else
    echo "❌ SSH (30s): Failed"
fi

echo "   4c. Long SSH test (60s)..."
if timeout 60 ssh -o ConnectTimeout=60 -o StrictHostKeyChecking=no root@${SERVER_IP} "echo 'Long test'" 2>/dev/null; then
    echo "✅ SSH (60s): Success"
else
    echo "❌ SSH (60s): Failed"
fi

echo ""
echo "5. Testing with different SSH keys..."
for key in ~/.ssh/id_* ~/.ssh/default ~/.ssh/tazav1; do
    if [[ -f "$key" && ! "$key" =~ \.pub$ ]]; then
        echo "   Testing with key: $(basename $key)"
        if timeout 10 ssh -i "$key" -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@${SERVER_IP} "echo 'Key test'" 2>/dev/null; then
            echo "✅ Key $(basename $key): Success"
        else
            echo "❌ Key $(basename $key): Failed"
        fi
    fi
done

echo ""
echo "6. Server resource check (if SSH works)..."
if timeout 30 ssh -o ConnectTimeout=30 root@${SERVER_IP} "
    echo 'Server Status:'
    echo '- Uptime:' \$(uptime | cut -d',' -f1)
    echo '- Load:' \$(uptime | awk '{print \$10,\$11,\$12}')
    echo '- Memory:' \$(free -h | grep Mem | awk '{print \$3\"/\"\$2}')
    echo '- Disk:' \$(df -h / | tail -1 | awk '{print \$5\" used\"}')
    echo '- SSH connections:' \$(who | wc -l)
    echo '- Docker status:' \$(systemctl is-active docker 2>/dev/null || echo 'unknown')
" 2>/dev/null; then
    echo "✅ Server info retrieved"
else
    echo "❌ Could not retrieve server info"
fi

echo ""
echo "================================================"
echo "🔧 Troubleshooting suggestions:"
echo ""
echo "If SSH fails but ping works:"
echo "1. Server may be overloaded"
echo "2. SSH service may be down: ssh root@${SERVER_IP} 'systemctl restart sshd'"
echo "3. Try accessing via console/VNC if available"
echo "4. Check if server has run out of disk space"
echo "5. Server may need reboot if completely unresponsive"
echo ""
echo "If port 14000 is closed:"
echo "1. Docker containers may be stopped"
echo "2. Application crashed during build"
echo "3. Port may be blocked by firewall"
echo ""
echo "Next steps:"
echo "- Wait 5-10 minutes and try again (server may recover)"
echo "- Contact server administrator if issue persists"
echo "- Try ./scripts/debug-deploy.sh for more diagnostics"