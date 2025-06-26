#!/bin/bash
# Speedtest CLI - by znand-dev

# Warna
GREEN='\e[1;32m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
NC='\e[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}              🌐 SPEEDTEST VPS                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Cek apakah speedtest-cli terinstall
if ! command -v speedtest &> /dev/null; then
    echo -e "${YELLOW}⚠️ speedtest-cli belum terinstall... installing...${NC}"
    apt-get update -y >/dev/null 2>&1
    apt-get install speedtest-cli -y >/dev/null 2>&1
fi

# Jalankan speedtest
echo -e "${CYAN}Sedang menguji koneksi... Mohon tunggu...${NC}"
speedtest --simple

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✔️ Selesai${NC}"
