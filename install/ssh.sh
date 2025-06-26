#!/bin/bash
# Install SSH + Dropbear + Banner

apt install -y dropbear

# Aktifkan dropbear di port 442
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

cat > /etc/default/dropbear << EOF
NO_START=0
DROPBEAR_PORT=442
DROPBEAR_EXTRA_ARGS="-p 109 -p 69"
DROPBEAR_BANNER="/etc/issue.net"
EOF

# Banner info
cat > /etc/issue.net <<EOF
Selamat datang di Server SIGMA VPN!
EOF

# Restart service
systemctl enable dropbear
systemctl restart dropbear

echo "✅ SSH & Dropbear berhasil di-setup!"
