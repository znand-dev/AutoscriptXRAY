#!/bin/bash
# Main Menu - SIGMA VPN by znand-dev

# Warna
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
NC='\e[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}            ⛓️ MENU UTAMA ⛓️                    ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "  [1] Menu Vmess"
echo -e "  [2] Menu Vless"
echo -e "  [3] Menu Trojan"
echo -e "  [4] Menu Shadowsocks (WS)"
echo -e "  [5] Menu WireGuard"
echo -e "  [6] Menu Tools"
echo -e "  [7] Status Service"
echo -e "  [8] Clear RAM Cache"
echo -e "  [9] Reboot VPS"
echo -e "  [x] Exit"
echo -e ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "👉 Pilih menu: " menu
echo ""

case $menu in
  1) m-vmess ;;
  2) m-vless ;;
  3) m-trojan ;;
  4) m-ssws ;;
  5) m-wg ;;
  6) tools-menu ;;
  7) running ;;
  8) clearcache ;;
  9) reboot ;;
  x) exit ;;
  *) echo "❌ Pilihan tidak valid!" ; sleep 1 ; menu ;;
esac
