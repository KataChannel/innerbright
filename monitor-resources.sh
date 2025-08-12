#!/bin/bash

# Resource monitoring script for low-resource server
echo "=== INNERBRIGHT SERVER RESOURCE MONITORING ==="
echo "Time: $(date)"
echo

echo "=== CPU USAGE ==="
echo "Load Average: $(cat /proc/loadavg)"
echo "CPU Count: $(nproc)"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU Usage: " 100 - $1 "%"}'
echo

echo "=== MEMORY USAGE ==="
free -h
echo

echo "=== DISK USAGE ==="
df -h /
echo

echo "=== DOCKER CONTAINER STATUS ==="
if command -v docker &> /dev/null; then
    echo "Docker containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    echo
    echo "Docker resource usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
else
    echo "Docker not available"
fi
echo

echo "=== NETWORK CONNECTIONS ==="
echo "Active connections to port 3000:"
netstat -an | grep :3000 | wc -l
echo

echo "=== SYSTEM UPTIME ==="
uptime
echo

echo "=== RECENT ERRORS IN LOGS ==="
if [ -f /var/log/syslog ]; then
    echo "Recent system errors:"
    tail -20 /var/log/syslog | grep -i error | tail -5
fi

echo "=== DOCKER LOGS (LATEST ERRORS) ==="
if command -v docker &> /dev/null; then
    echo "Recent Docker errors:"
    docker compose -f /opt/innerbright/docker-compose.low-resource.yml logs --tail=50 2>/dev/null | grep -i error | tail -5
fi

echo
echo "=== MONITORING COMPLETE ==="
