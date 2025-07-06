#!/bin/bash
# Setup Xray Core - by znand-dev

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}▶️ Memulai instalasi Xray-core...${NC}"
sleep 1

# Install dependensi
apt update -y
apt install -y socat curl cron jq unzip gnupg coreutils lsof -qq

# Download Xray-core terbaru
mkdir -p /etc/xray /var/log/xray /usr/local/bin

echo -e "${GREEN}⬇️ Download Xray-core...${NC}"
wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -o /tmp/xray.zip -d /usr/local/bin/
chmod +x /usr/local/bin/xray
rm -f /tmp/xray.zip

# Konfigurasi domain
if [[ -f /root/domain ]]; then
  domain=$(cat /root/domain)
else
  echo -e "${RED}[ERROR] File /root/domain tidak ditemukan!${NC}"
  exit 1
fi

echo "$domain" > /etc/xray/domain

# Install & issue cert via acme.sh
if [ ! -f /root/.acme.sh/acme.sh ]; then
  echo -e "${GREEN}🔐 Menginstall acme.sh...${NC}"
  curl https://acme-install.netlify.app/acme.sh | bash
  export PATH="/root/.acme.sh:$PATH"
  source /root/.bashrc >/dev/null 2>&1 || true
  sleep 3
fi

ACME="/root/.acme.sh/acme.sh"
if [ ! -f "$ACME" ]; then
  echo -e "${RED}[ERROR] acme.sh tetap tidak ditemukan setelah instalasi!${NC}"
else
  chmod +x "$ACME"
  "$ACME" --set-default-ca --server letsencrypt
  "$ACME" --register-account -m admin@$domain
  "$ACME" --issue --standalone -d $domain --keylength ec-256
  "$ACME" --install-cert -d $domain \
    --key-file /etc/xray/private.key \
    --fullchain-file /etc/xray/cert.crt \
    --ecc
fi

# Dummy config JSON
cat > /etc/xray/config.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "blocked"
    }
  ]
}
EOF

# Setup systemd service
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://xray.dev/
After=network.target nss-lookup.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/config.json
Restart=on-failure
LimitNPROC=1000000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray

# Tambahkan info ke log install
grep -q "XRAY TLS" /root/log-install.txt || echo "XRAY TLS         : 443" >> /root/log-install.txt
grep -q "XRAY None TLS" /root/log-install.txt || echo "XRAY None TLS    : 80" >> /root/log-install.txt

# Output final
echo -e "${GREEN}✅ Xray-core berhasil di-install dan dikonfigurasi!${NC}"
echo -e "${GREEN}📂 Config: /etc/xray/config.json${NC}"
echo -e "${GREEN}🔐 Domain: $domain${NC}"
echo -e "${GREEN}🚀 Jalankan dengan: systemctl start xray${NC}"
