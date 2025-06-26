#!/bin/bash
# Setup Xray Core - by znand-dev

# Warna
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}▶️ Memulai installasi Xray-core...${NC}"
sleep 1

# Install dependensi
apt update -y
apt install -y socat curl cron jq unzip gnupg coreutils

# Download Xray-core terbaru
mkdir -p /etc/xray
mkdir -p /var/log/xray
mkdir -p /usr/local/bin

echo -e "${GREEN}⬇️ Download Xray-core...${NC}"
wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -o /tmp/xray.zip -d /usr/local/bin/
chmod +x /usr/local/bin/xray
rm -f /tmp/xray.zip

# Konfigurasi domain
echo -e ""
read -p "Masukkan domain (pastikan A record mengarah ke VPS): " domain
echo "$domain" > /etc/xray/domain

# Install acme.sh dan request cert
curl https://acme-install.netlify.app/acme.sh -o acme.sh && bash acme.sh
~/.acme.sh/acme.sh --register-account -m admin@$domain
~/.acme.sh/acme.sh --issue --standalone -d $domain --keylength ec-256
~/.acme.sh/acme.sh --install-cert -d $domain \
--key-file /etc/xray/private.key \
--fullchain-file /etc/xray/cert.crt \
--ecc

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

# Dummy config
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

echo -e "${GREEN}✅ Xray-core berhasil di-install dan dikonfigurasi!${NC}"
echo -e "${GREEN}📂 Config: /etc/xray/config.json${NC}"
echo -e "${GREEN}🔐 Domain: $domain${NC}"
echo -e "${GREEN}🚀 Jalankan dengan: systemctl start xray${NC}"
