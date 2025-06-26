#!/bin/bash
# WebSocket installer untuk SSH / Dropbear

# Install Python WS server
apt install -y python3 python3-pip
pip3 install websocket-server

# Buat file service systemd
cat > /etc/systemd/system/sshws.service <<EOF
[Unit]
Description=SSH WebSocket by znand-dev
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m websocket_server -p 80 -h 127.0.0.1 --target 127.0.0.1:22
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable & start
systemctl daemon-reload
systemctl enable sshws
systemctl restart sshws

echo "✅ WebSocket service aktif di port 80 → SSH"
