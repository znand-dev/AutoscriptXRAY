#!/bin/bash
# Remove Trojan & Shadowsocks Components - AutoScript ZNAND
# Script untuk menghapus komponen Trojan dan Shadowsocks yang sudah terinstall

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
echo -e "${YELLOW}     🗑️ TROJAN & SHADOWSOCKS REMOVAL         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "Script ini akan menghapus:"
echo -e "• Trojan protocol dari XRAY config"
echo -e "• Shadowsocks protocol dari XRAY config"
echo -e "• Menu Trojan dan Shadowsocks"
echo -e "• User accounts untuk kedua protocol"
echo -e "• Configuration entries yang terkait"
echo -e ""

read -p "❓ Lanjutkan penghapusan Trojan & Shadowsocks? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${YELLOW}Operasi dibatalkan.${NC}"
    exit 0
fi

echo -e ""
info "🚮 Memulai penghapusan Trojan & Shadowsocks components..."

# 1. Backup XRAY config sebelum modifikasi
info "Membuat backup konfigurasi XRAY..."
if [[ -f /etc/xray/config.json ]]; then
    cp /etc/xray/config.json /etc/xray/config.json.backup.$(date +%s)
    info "✅ Backup created: /etc/xray/config.json.backup.$(date +%s)"
else
    warn "⚠️ Config XRAY tidak ditemukan di /etc/xray/config.json"
fi

# 2. Hapus user Trojan dari config XRAY
info "Menghapus user Trojan dari konfigurasi..."
if [[ -f /etc/xray/config.json ]]; then
    # Remove Trojan users (lines with ### username containing trojan info)
    sed -i '/### .* trojan/,+5d' /etc/xray/config.json 2>/dev/null
    sed -i '/trojan/,+5d' /etc/xray/config.json 2>/dev/null
    info "✅ Trojan users removed from config"
fi

# 3. Hapus user Shadowsocks dari config XRAY
info "Menghapus user Shadowsocks dari konfigurasi..."
if [[ -f /etc/xray/config.json ]]; then
    # Remove Shadowsocks users
    sed -i '/### .* shadowsocks/,+5d' /etc/xray/config.json 2>/dev/null
    sed -i '/shadowsocks/,+5d' /etc/xray/config.json 2>/dev/null
    info "✅ Shadowsocks users removed from config"
fi

# 4. Hapus script dari /usr/bin
info "Menghapus script dari system..."
rm -f /usr/bin/m-trojan 2>/dev/null
rm -f /usr/bin/m-ssws 2>/dev/null
info "✅ Menu scripts removed"

# 5. Hapus dari /etc/autoscriptvpn jika ada
if [[ -d /etc/autoscriptvpn/xray ]]; then
    info "Membersihkan /etc/autoscriptvpn/xray..."
    rm -f /etc/autoscriptvpn/xray/add-trojan.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/del-trojan.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/cek-trojan.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/renew-trojan.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/add-ssws.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/del-ssws.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/cek-ssws.sh 2>/dev/null
    rm -f /etc/autoscriptvpn/xray/renew-ssws.sh 2>/dev/null
    info "✅ Autoscriptvpn directory cleaned"
fi

# 6. Clean up dari log-install.txt
if [[ -f /root/log-install.txt ]]; then
    info "Membersihkan log install..."
    sed -i '/Trojan/d' /root/log-install.txt 2>/dev/null
    sed -i '/TROJAN/d' /root/log-install.txt 2>/dev/null
    sed -i '/Shadowsocks/d' /root/log-install.txt 2>/dev/null
    sed -i '/SHADOWSOCKS/d' /root/log-install.txt 2>/dev/null
    info "✅ Log files cleaned"
fi

# 7. Restart XRAY service dengan error handling
info "Restarting XRAY service..."
if systemctl restart xray; then
    sleep 2
    if systemctl is-active --quiet xray; then
        info "✅ XRAY service restarted successfully"
    else
        warn "⚠️ XRAY service tidak running setelah restart"
        # Try to restore backup
        if [[ -f /etc/xray/config.json.backup.* ]]; then
            warn "Attempting to restore backup..."
            latest_backup=$(ls -t /etc/xray/config.json.backup.* | head -1)
            cp "$latest_backup" /etc/xray/config.json
            systemctl restart xray
        fi
    fi
else
    error "❌ Gagal restart XRAY service"
    # Try to restore backup
    if [[ -f /etc/xray/config.json.backup.* ]]; then
        warn "Attempting to restore backup..."
        latest_backup=$(ls -t /etc/xray/config.json.backup.* | head -1)
        cp "$latest_backup" /etc/xray/config.json
        systemctl restart xray
    fi
fi

# 8. Verify cleanup
info "🔍 Memverifikasi penghapusan..."

errors=0

# Check scripts
if [[ -f /usr/bin/m-trojan ]]; then
    warn "⚠️ Script m-trojan masih ada di /usr/bin"
    ((errors++))
fi

if [[ -f /usr/bin/m-ssws ]]; then
    warn "⚠️ Script m-ssws masih ada di /usr/bin"
    ((errors++))
fi

# Check config for remaining entries
if [[ -f /etc/xray/config.json ]]; then
    if grep -q "trojan\|shadowsocks" /etc/xray/config.json; then
        warn "⚠️ Config masih mengandung referensi trojan/shadowsocks"
        ((errors++))
    fi
fi

# Summary
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}✅ Trojan & Shadowsocks berhasil dihapus!${NC}"
    echo -e "${GREEN}📋 Komponen yang telah dihapus:${NC}"
    echo -e "   • Menu Trojan (m-trojan)"
    echo -e "   • Menu Shadowsocks (m-ssws)"
    echo -e "   • User accounts Trojan & Shadowsocks"
    echo -e "   • Configuration entries"
    echo -e "   • Script management files"
else
    warn "⚠️ Penghapusan selesai dengan $errors warning(s)"
    echo -e "${YELLOW}Beberapa komponen mungkin perlu dihapus manual${NC}"
fi

echo -e ""
echo -e "${CYAN}📝 Notes:${NC}"
echo -e "• Menu utama telah diupdate (hanya VMess & VLess)"
echo -e "• Existing users Trojan/Shadowsocks telah dihapus"
echo -e "• XRAY config telah dibersihkan"
echo -e "• Backup config tersimpan untuk recovery"
echo -e ""

echo -e "${GREEN}🎯 Protocol yang tersisa:${NC}"
echo -e "   [1] SSH & Dropbear + WebSocket"
echo -e "   [2] XRAY VMess"
echo -e "   [3] XRAY VLess"
echo -e ""

echo -e "${CYAN}✅ AutoScript sekarang lebih sederhana dan fokus!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"