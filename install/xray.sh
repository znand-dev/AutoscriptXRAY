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

# Install & issue cert via acme.sh dengan error handling
echo -e "${GREEN}🔐 Setting up SSL certificates...${NC}"

if ! command -v ~/.acme.sh/acme.sh &>/dev/null; then
  echo -e "${GREEN}📥 Installing acme.sh...${NC}"
  temp_acme=$(mktemp)
  
  if ! curl -s https://acme-install.netlify.app/acme.sh -o "$temp_acme"; then
    echo -e "${RED}[ERROR] Gagal download acme.sh installer!${NC}"
    rm -f "$temp_acme"
    exit 1
  fi
  
  # Basic security check
  if ! head -1 "$temp_acme" | grep -q "#!/bin/bash\|#!/bin/sh"; then
    echo -e "${RED}[ERROR] acme.sh installer tidak valid!${NC}"
    rm -f "$temp_acme"
    exit 1
  fi
  
  mv "$temp_acme" acme.sh
  chmod +x acme.sh
  
  if ! bash acme.sh; then
    echo -e "${RED}[ERROR] Gagal install acme.sh!${NC}"
    exit 1
  fi
  
  rm -f acme.sh
fi

# Set certificate authority
if ! ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt; then
  echo -e "${RED}[ERROR] Gagal set CA ke Let's Encrypt!${NC}"
  exit 1
fi

# Register account
echo -e "${GREEN}📝 Registering account...${NC}"
if ! ~/.acme.sh/acme.sh --register-account -m admin@$domain; then
  echo -e "${RED}[ERROR] Gagal register account!${NC}"
  exit 1
fi

# Issue certificate
echo -e "${GREEN}🔒 Issuing SSL certificate for $domain...${NC}"
if ! ~/.acme.sh/acme.sh --issue --standalone -d $domain --keylength ec-256; then
  echo -e "${RED}[ERROR] Gagal issue SSL certificate!${NC}"
  echo -e "${RED}Pastikan:${NC}"
  echo -e "${RED}- Domain $domain mengarah ke IP server ini${NC}"
  echo -e "${RED}- Port 80 tidak digunakan service lain${NC}"
  echo -e "${RED}- Firewall tidak memblokir port 80${NC}"
  exit 1
fi

# Install certificate
echo -e "${GREEN}📋 Installing certificates...${NC}"
if ! ~/.acme.sh/acme.sh --install-cert -d $domain \
  --key-file /etc/xray/private.key \
  --fullchain-file /etc/xray/cert.crt \
  --ecc; then
  echo -e "${RED}[ERROR] Gagal install certificates!${NC}"
  exit 1
fi

# Verify certificates
if [[ ! -f /etc/xray/private.key ]] || [[ ! -f /etc/xray/cert.crt ]]; then
  echo -e "${RED}[ERROR] Certificate files tidak ditemukan!${NC}"
  exit 1
fi

echo -e "${GREEN}✅ SSL certificates berhasil di-setup!${NC}"

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
