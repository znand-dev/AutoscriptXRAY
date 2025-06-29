#!/bin/bash
# Install SSH + Dropbear + Banner + Port Logger

apt install -y dropbear -qq

# Tambah shell non-login
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

# Konfigurasi Dropbear
cat > /etc/default/dropbear << EOF
NO_START=0
DROPBEAR_PORT=442
DROPBEAR_EXTRA_ARGS="-p 109 -p 69"
DROPBEAR_BANNER="/etc/issue.net"
EOF

# Tambahkan banner
cat > /etc/issue.net <<EOF
Selamat datang di Server SIGMA VPN!
EOF

# Enable & Restart service
systemctl enable dropbear
systemctl restart dropbear

# Log port ke /root/log-install.txt
{
  echo "OpenSSH      : 22"
  echo "Dropbear     : 442, 109, 69"
  echo "Stunnel4     : 443"
  echo "SSH Websocket: 80"
  echo "SSH SSL Websocket: 443"
  echo "Squid        : 3128"  # Kalau tidak pakai squid, bisa dihapus
  echo "OHP SSH      : 8181"
  echo "OHP DBear    : 8282"
  echo "OHP OpenVPN  : 8383"
} >> /root/log-install.txt

echo -e "\e[1;32m✅ SSH & Dropbear berhasil di-setup!\e[0m"
