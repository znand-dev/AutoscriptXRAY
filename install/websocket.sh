#!/bin/bash
# Setup WebSocket service untuk Dropbear & SSH (opsional)

apt install -y python3 python3-websocket python3-pip
pip3 install websocket-server

# Buat service websocket ssh (port 80 → 22)
cat > /etc/systemd/system/sshws.service <<EOF
[Unit]
Description=SSH Websocket by znand-dev
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m websocket_server -p 80 -h 127.0.0.1 --target 127.0.0.1:22
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable sshws
systemctl restart sshws

echo "✅ WebSocket SSH berhasil dijalankan di port 80!"
