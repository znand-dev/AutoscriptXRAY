#!/bin/bash
# Submenu Status Service - by znand-dev

# Warna
NC='\e[0m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}          📡 STATUS LAYANAN AKTIF           ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Cek status layanan utama
services=(
  "ssh"
  "dropbear"
  "sshws"
  "xray"
  "stunnel4"
  "wg-quick@wg0"
)

for svc in "${services[@]}"; do
  status=$(systemctl is-active $svc 2>/dev/null)
  printf "%-15s : %s\n" "$svc" "${status^^}"
done

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n1 -r -p "⏎ Tekan enter untuk kembali ke menu utama..."
menu
