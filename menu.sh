#!/bin/bash
# Main Menu - SIGMA VPN by znand-dev

# Warna
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
NC='\e[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}            ⛓️ SIGMA VPN MENU UTAMA             ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "  [1] Menu SSH & Dropbear"
echo -e "  [2] Menu Vmess"
echo -e "  [3] Menu Vless"
echo -e "  [4] Menu Trojan"
echo -e "  [5] Menu Shadowsocks (WS)"
echo -e "  [6] Menu WireGuard"
echo -e "  [7] Menu Tools"
echo -e "  [8] Status Service"
echo -e "  [9] Clear RAM Cache"
echo -e " [10] Reboot VPS"
echo -e "  [x] Exit"
echo -e ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "👉 Pilih menu: " menu
echo ""

case $menu in
  1) m-sshovpn ;;
  2) m-vmess ;;
  3) m-vless ;;
  4) m-trojan ;;
  5) m-ssws ;;
  6) m-wg ;;
  7) tools-menu ;;
  8) running ;;
  9) clearcache ;;
  10) reboot ;;
  x) exit ;;
  *) echo "❌ Pilihan tidak valid!" ; sleep 1 ; menu ;;
esac
