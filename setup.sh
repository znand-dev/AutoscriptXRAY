#!/bin/bash
# Setup Script for AutoScript_ZNAND
# Penyesuaian & Inspirasi dari GIVPN by znand-dev

echo "" > /root/log-install.txt
cd "$(dirname "$0")"
rm -f setup.sh
clear

# Warna
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
NC='\e[0m'

# Fungsi warna
function info() { echo -e "${green}[INFO]${NC} $1"; }
function warn() { echo -e "${yellow}[WARNING]${NC} $1"; }
function error() { echo -e "${red}[ERROR]${NC} $1"; }

# Mulai timer
start_time=$(date +%s)

# Check Root
if [ "${EUID}" -ne 0 ]; then
  error "Script harus dijalankan sebagai root."
  exit 1
fi

# Check OpenVZ
if [ "$(systemd-detect-virt)" == "openvz" ]; then
  error "OpenVZ tidak didukung. Gunakan KVM/VMWare."
  exit 1
fi

# Setup /etc/hosts jika belum sesuai
localip=$(hostname -I | awk '{print $1}')
hostname=$(hostname)
domainline=$(grep -w "$hostname" /etc/hosts | awk '{print $2}')
if [[ "$hostname" != "$domainline" ]]; then
  echo "$localip $hostname" >> /etc/hosts
fi

# Create folder yang dibutuhkan
mkdir -p /etc/xray /etc/v2ray /var/lib
for file in domain scdomain; do
  touch /etc/xray/$file
  touch /etc/v2ray/$file
  touch /root/$file
done
touch /var/lib/ipvps.conf

# Set Timezone
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Update & Install Dependensi
info "Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y curl wget git screen unzip bzip2 gzip coreutils python3 python3-pip >/dev/null 2>&1
pip3 install websocket-server >/dev/null 2>&1

# Header Linux
kernelver=$(uname -r)
headerpkg="linux-headers-$kernelver"
if ! dpkg -s $headerpkg >/dev/null 2>&1; then
  info "Installing $headerpkg..."
  apt install -y $headerpkg
fi

# Pilih Domain
clear
echo -e "$blue========= DOMAIN SETUP =========$NC"
echo "1. Gunakan Domain Acak (Cloudflare API)"
echo "2. Masukkan Domain Sendiri"
echo -n "Pilih [1/2]: "; read domopt
if [[ "$domopt" == "1" ]]; then
  wget -q https://raw.githubusercontent.com/givpn/AutoScriptXray/master/ssh/cf && chmod +x cf && ./cf
elif [[ "$domopt" == "2" ]]; then
  read -rp "Masukkan domain kamu: " domain
  echo "$domain" > /root/domain
  for dfile in domain scdomain; do
    echo "$domain" > /etc/xray/$dfile
    echo "$domain" > /etc/v2ray/$dfile
    echo "$domain" > /root/$dfile
  done
  echo "IP=$domain" > /var/lib/ipvps.conf
else
  error "Pilihan tidak valid"
  exit 1
fi

# Eksekusi Installer per Fitur
info "Menjalankan installer SSH..."
bash install/ssh.sh
info "Menjalankan installer XRAY..."
bash install/xray.sh
info "Menjalankan installer WireGuard..."
bash install/wg.sh
info "Menjalankan installer WebSocket..."
bash install/websocket.sh

# Salin sub-menu & tools ke /usr/bin
info "Menyalin command menu..."
cp -f ssh/m-sshovpn /usr/bin/
cp -f xray/m-vmess /usr/bin/
cp -f xray/m-vless /usr/bin/
cp -f xray/m-trojan /usr/bin/
cp -f xray/m-ssws /usr/bin/
cp -f wg/m-wg /usr/bin/
cp -f tools/tools-menu /usr/bin/
cp -f tools/backup.sh /usr/bin/
cp -f tools/speedtest.sh /usr/bin/
cp -f tools/domain.sh /usr/bin/
cp -f websocket/*.sh /usr/bin/
cp -f menu.sh /usr/bin/menu

# Copy sshws.py ke tempat yang benar
cp -f websocket/sshws.py /usr/local/bin/sshws.py
chmod +x /usr/local/bin/sshws.py

# Set permission eksekusi
chmod +x /usr/bin/*
chmod +x ssh/*.sh xray/*.sh wg/*.sh websocket/*.sh tools/*.sh /usr/bin/menu

# Copy semua script ke folder runtime /etc/autoscriptvpn
info "Menyalin semua submenu ke /etc/autoscriptvpn/..."
mkdir -p /etc/autoscriptvpn/{ssh,xray,websocket,tools,wg}

cp -r ssh/*.sh /etc/autoscriptvpn/ssh/
cp -r xray/*.sh /etc/autoscriptvpn/xray/
cp -r websocket/*.sh /etc/autoscriptvpn/websocket/
cp -r tools/*.sh /etc/autoscriptvpn/tools/
cp -r wg/*.sh /etc/autoscriptvpn/wg/

chmod +x /etc/autoscriptvpn/*/*.sh

# Tambahkan menu otomatis saat login
cat > /root/.profile <<-EOF
if [ "\$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
clear
menu
EOF
chmod 644 /root/.profile

# Bersih-bersih file sementara
rm -f cf ssh-vpn.sh ins-xray.sh insshws.sh setup.sh

# Tampilkan durasi dan reboot
end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo -e "${green}✅ Instalasi selesai dalam $((elapsed / 60)) menit $((elapsed % 60)) detik.${NC}"
echo -e "${green}♻️ VPS akan reboot dalam 10 detik...${NC}"
sleep 10
reboot
