#!/bin/bash
# Setup Script for AutoScript_ZNAND
# Penyesuaian & Inspirasi dari GIVPN by znand-dev

cd
rm -rf setup.sh
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

# Check Root
if [ "${EUID}" -ne 0 ]; then
  error "Script must be run as root."
  exit 1
fi

# Check OpenVZ
if [ "$(systemd-detect-virt)" == "openvz" ]; then
  error "OpenVZ is not supported. Use KVM/VMWare."
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
apt install -y curl wget git screen unzip bzip2 gzip coreutils python3 >/dev/null 2>&1

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
bash install/ssh.sh
bash install/xray.sh
bash install/wg.sh
bash install/websocket.sh
=======
# Clone autoscript repo dan mulai install
cd "$(dirname "$0")"
chmod +x install.sh
screen -S setup ./install.sh

# Tambahkan auto menu
cat > /root/.profile
if [ "\$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
clear
menu
END
chmod 644 /root/.profile

# Bersih-bersih file sementara
rm -f cf ssh-vpn.sh ins-xray.sh insshws.sh setup.sh

# Auto Reboot
secs_to_human() {
  echo "Installation took \$(( \$1 / 60 ))m \$(( \$1 % 60 ))s"
}
start_time=$(date +%s)
end_time=$(date +%s)
secs_to_human $(( end_time - start_time ))

echo -e "${green}Installation complete. Rebooting in 10 seconds...${NC}"
sleep 10
