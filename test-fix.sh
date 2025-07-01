#!/bin/bash

echo "Testing deployment fix..."

# Test the logging function fix
cd /chikiet/kataoffical/KataCore

# Check if script is executable
if [[ -x "./universal-deployer.sh" ]]; then
    echo "✅ Script is executable"
else
    echo "❌ Script is not executable, fixing..."
    chmod +x ./universal-deployer.sh
fi

# Test the fix by calling the script with help
echo "Testing help command..."
./universal-deployer.sh --help

echo "Done!"
