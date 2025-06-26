#!/bin/bash
# Auto Setup Script - SIGMA VPN by znand-dev

# Warna
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🚀 Memulai instalasi layanan SIGMA VPN...${NC}"
sleep 1

# Buat direktori config jika belum ada
mkdir -p /etc/autoscriptvpn

# Jalankan installer per modul
bash install/ssh.sh
bash install/wg.sh
bash install/xray.sh
bash install/websocket.sh

# Salin semua sub-menu & command ke /usr/bin
cp ssh/m-sshovpn /usr/bin/
cp xray/m-vmess /usr/bin/
cp xray/m-vless /usr/bin/
cp xray/m-trojan /usr/bin/
cp xray/m-ssws /usr/bin/
cp wg/m-wg /usr/bin/
cp tools/tools-menu /usr/bin/
cp tools/backup.sh /usr/bin/
cp tools/speedtest.sh /usr/bin/
cp tools/domain.sh /usr/bin/
cp websocket/*.sh /usr/bin/

# Set permission eksekusi
chmod +x /usr/bin/*
chmod +x ssh/*.sh xray/*.sh wg/*.sh websocket/*.sh tools/*.sh

# Set menu utama
cp menu.sh /usr/bin/menu
chmod +x /usr/bin/menu

echo -e "${GREEN}✅ Instalasi SIGMA VPN selesai!"
echo -e "${GREEN}🧠 Ketik 'menu' untuk mulai menggunakan script.${NC}"
