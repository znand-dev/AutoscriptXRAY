#!/bin/bash
# Setup WebSocket untuk SSH (port 80) dan log info

# Install dependensi
apt install -y python3 python3-pip -qq
pip3 install websocket-server >/dev/null 2>&1

# Cek dan hapus service lama jika ada
systemctl stop sshws >/dev/null 2>&1
systemctl disable sshws >/dev/null 2>&1
rm -f /etc/systemd/system/sshws.service

# Buat ulang service SSH WebSocket (port 80 → 22)
cat > /etc/systemd/system/sshws.service <<EOF
[Unit]
Description=SSH WebSocket by znand-dev
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/sshws.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload dan aktifkan service
systemctl daemon-reload
systemctl enable sshws
systemctl restart sshws

# Log ke file
grep -q "SSH Websocket" /root/log-install.txt || echo "SSH Websocket     : 80" >> /root/log-install.txt
grep -q "SSH SSL Websocket" /root/log-install.txt || echo "SSH SSL Websocket : 443" >> /root/log-install.txt

# Output ke user
echo -e "\e[1;32m✅ WebSocket SSH berhasil diaktifkan di port 80!\e[0m"
