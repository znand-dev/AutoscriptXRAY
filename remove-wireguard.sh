#!/bin/bash
# Remove WireGuard Component - AutoScript ZNAND
# Script untuk menghapus komponen WireGuard yang sudah terinstall

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# Functions
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "Script ini harus dijalankan sebagai root"
   exit 1
fi

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}        🗑️ WIREGUARD COMPONENT REMOVAL        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "Script ini akan menghapus:"
echo -e "• WireGuard services dan konfigurasi"
echo -e "• Interface wg0"
echo -e "• Client configurations"
echo -e "• Menu WireGuard dari autoscript"
echo -e "• Package wireguard-tools (opsional)"
echo -e ""

read -p "❓ Lanjutkan penghapusan WireGuard? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${YELLOW}Operasi dibatalkan.${NC}"
    exit 0
fi

echo -e ""
info "🚮 Memulai penghapusan WireGuard component..."

# 1. Stop dan disable WireGuard service
info "Menghentikan WireGuard service..."
systemctl stop wg-quick@wg0 2>/dev/null
systemctl disable wg-quick@wg0 2>/dev/null

# Check jika ada interface aktif
if ip link show wg0 &>/dev/null; then
    info "Menonaktifkan interface wg0..."
    wg-quick down wg0 2>/dev/null || ip link delete wg0 2>/dev/null
fi

# 2. Hapus file konfigurasi WireGuard
info "Menghapus konfigurasi WireGuard..."
rm -rf /etc/wireguard/ 2>/dev/null
rm -f /etc/systemd/system/wg-quick@wg0.service 2>/dev/null

# 3. Hapus dari systemctl daemon
systemctl daemon-reload

# 4. Hapus script WireGuard dari /usr/bin
info "Menghapus script WireGuard dari system..."
rm -f /usr/bin/m-wg 2>/dev/null

# 5. Hapus dari /etc/autoscriptvpn
rm -rf /etc/autoscriptvpn/wg/ 2>/dev/null

# 6. Clean up dari log-install.txt
if [[ -f /root/log-install.txt ]]; then
    info "Membersihkan log install..."
    sed -i '/WireGuard/d' /root/log-install.txt 2>/dev/null
    sed -i '/wg0/d' /root/log-install.txt 2>/dev/null
fi

# 7. Opsional: Uninstall wireguard packages
echo -e ""
read -p "❓ Hapus package wireguard-tools dari system? [y/N]: " remove_pkg
if [[ "$remove_pkg" == "y" || "$remove_pkg" == "Y" ]]; then
    info "Menghapus package wireguard-tools..."
    apt remove --purge -y wireguard-tools wireguard 2>/dev/null
    apt autoremove -y 2>/dev/null
fi

# 8. Verify cleanup
info "🔍 Memverifikasi penghapusan..."

errors=0

# Check service
if systemctl is-active --quiet wg-quick@wg0; then
    warn "⚠️ Service wg-quick@wg0 masih aktif"
    ((errors++))
fi

# Check interface
if ip link show wg0 &>/dev/null; then
    warn "⚠️ Interface wg0 masih ada"
    ((errors++))
fi

# Check config files
if [[ -d /etc/wireguard ]]; then
    warn "⚠️ Direktori /etc/wireguard masih ada"
    ((errors++))
fi

# Check scripts
if [[ -f /usr/bin/m-wg ]]; then
    warn "⚠️ Script m-wg masih ada di /usr/bin"
    ((errors++))
fi

# Summary
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}✅ WireGuard berhasil dihapus sepenuhnya!${NC}"
    echo -e "${GREEN}📋 Komponen yang telah dihapus:${NC}"
    echo -e "   • Service wg-quick@wg0"
    echo -e "   • Interface wg0"
    echo -e "   • Konfigurasi /etc/wireguard/"
    echo -e "   • Menu WireGuard (m-wg)"
    echo -e "   • Client configurations"
    
    if [[ "$remove_pkg" == "y" || "$remove_pkg" == "Y" ]]; then
        echo -e "   • Package wireguard-tools"
    fi
else
    warn "⚠️ Penghapusan selesai dengan $errors warning(s)"
    echo -e "${YELLOW}Beberapa komponen mungkin perlu dihapus manual${NC}"
fi

echo -e ""
echo -e "${CYAN}📝 Notes:${NC}"
echo -e "• Menu utama telah diupdate (tanpa WireGuard)"
echo -e "• Restart VPS disarankan untuk pembersihan lengkap"
echo -e "• Jika ada client aktif, mereka akan terputus"
echo -e ""

read -p "❓ Restart VPS sekarang untuk finalisasi? [y/N]: " restart_now
if [[ "$restart_now" == "y" || "$restart_now" == "Y" ]]; then
    info "🔄 Restarting VPS dalam 5 detik..."
    sleep 5
    reboot
else
    echo -e "${YELLOW}💡 Jangan lupa restart VPS nanti: ${CYAN}reboot${NC}"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"