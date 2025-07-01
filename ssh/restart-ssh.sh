#!/bin/bash
# Restart service SSH-related - by znand-dev

echo -e "♻️  Restarting all SSH-related services..."

services=("ssh" "dropbear" "stunnel4")

for svc in "${services[@]}"; do
    if systemctl list-units --type=service | grep -q "$svc"; then
        if systemctl restart "$svc"; then
            sleep 1
            if systemctl is-active --quiet "$svc"; then
                echo "✅ $svc restarted successfully."
            else
                echo "❌ $svc failed to start after restart."
            fi
        else
            echo "❌ Failed to restart $svc."
        fi
    else
        echo "⚠️ $svc not found or inactive."
    fi
done
