#!/bin/bash
# Restart service SSH-related - by znand-dev

echo -e "♻️  Restarting all SSH-related services..."

services=("ssh" "dropbear" "stunnel4")

for svc in "${services[@]}"; do
    if systemctl list-units --type=service | grep -q "$svc"; then
        systemctl restart $svc && echo "✅ $svc restarted."
    else
        echo "❌ $svc not found or inactive."
    fi
done
