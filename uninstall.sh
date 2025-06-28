#!/bin/bash
# Uninstall Script - AutoScriptZNAND
# Dibuat oleh znand-dev | Bersih-bersih ala SIGMA 💀

# Warna
GREEN='\e[0;32m'
RED='\e[1;31m'
YELLOW='\e[1;33m'
NC='\e[0m'

function info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
function warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}
function error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Konfirmasi
read -p "⚠️  Yakin ingin menghapus semua layanan AutoScriptZNAND? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    warn "Batal uninstall."
    exit 0
fi

# Hentikan layanan
info "Menghentikan layanan XRAY, WireGuard, SSH, WebSocket..."
systemctl stop xray >/dev/null 2>&1
systemctl stop wg-quick@wg0 >/dev/null 2>&1
systemctl stop sshws.service >/dev/null 2>&1
systemctl stop ws-dropbear.service >/dev/null 2>&1

# Hapus layanan systemd custom (kalau ada)
info "Menghapus service WebSocket..."
rm -f /etc/systemd/system/sshws.service
rm -f /etc/systemd/system/ws-dropbear.service
systemctl daemon-reload

# Hapus direktori dan config
info "Menghapus direktori konfigurasi..."
rm -rf /etc/xray /etc/v2ray /var/lib /etc/systemd/system/xray*
rm -rf /root/domain /root/scdomain /etc/xray/domain /etc/xray/scdomain
rm -rf /etc/v2ray/domain /etc/v2ray/scdomain
rm -rf /usr/bin/menu /usr/bin/m-* /usr/bin/tools-menu
rm -rf /usr/bin/add-* /usr/bin/del-* /usr/bin/cek-* /usr/bin/renew-*
rm -rf /usr/bin/wg-* /usr/bin/restart-* /usr/bin/backup.sh /usr/bin/domain.sh /usr/bin/speedtest.sh
rm -rf /root/AutoscriptXRAY /root/cf /root/.profile

# Hapus rules firewall (jika ada)
info "Membersihkan iptables..."
iptables -F
ip6tables -F

# Opsional: Bersihkan package terkait
info "Menghapus package tambahan (opsional)..."
apt remove --purge -y screen unzip bzip2 gzip coreutils python3 curl wget git >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1

# Restart SSH biar tetap bisa remote
info "Restart SSH..."
systemctl restart ssh

# Selesai
echo -e "${GREEN}✅ AutoScriptZNAND berhasil di-uninstall.${NC}"
