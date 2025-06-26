#!/bin/bash
# AutoScript Setup by znand-dev
# Jangan lupa sholat bro! 🕌

cd /root
rm -rf setup.sh
clear

# WARNA
green='\e[0;32m'
red='\e[1;31m'
yell='\e[1;33m'
blue='\e[1;34m'
NC='\e[0m'

# Cek Root & Virtualisasi
if [[ $EUID -ne 0 ]]; then
  echo -e "${red}Kamu harus jalankan script ini sebagai root!${NC}"
  exit 1
fi

if [[ $(systemd-detect-virt) == "openvz" ]]; then
  echo -e "${red}VPS OpenVZ tidak didukung! Gunakan KVM atau VMWare.${NC}"
  exit 1
fi

# Tambahkan ke /etc/hosts jika belum ada
localip=$(hostname -I | cut -d' ' -f1)
if ! grep -q "$(hostname)" /etc/hosts; then
  echo "$localip $(hostname)" >> /etc/hosts
fi

# Buat direktori config
mkdir -p /etc/xray /etc/v2ray
touch /etc/xray/domain /etc/xray/scdomain /etc/v2ray/domain /etc/v2ray/scdomain

# Cek & install linux headers
header="linux-headers-$(uname -r)"
if ! dpkg -s "$header" &>/dev/null; then
  echo -e "${yell}Installing $header...${NC}"
  apt update && apt install -y "$header"
fi

# Set zona waktu dan nonaktifkan IPv6
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# Install dependensi
echo -e "${green}Menyiapkan dependensi...${NC}"
apt install -y git curl wget screen unzip bzip2 gzip coreutils python >/dev/null 2>&1

# Konfigurasi domain
clear
echo -e "${blue}=========== SETUP DOMAIN VPS ===========${NC}"
echo -e "${green}1.${NC} Gunakan domain random"
echo -e "${green}2.${NC} Masukkan domain sendiri"
echo -e "${blue}========================================${NC}"
read -rp "Pilih (1/2): " dns
if [[ $dns == "1" ]]; then
  wget -qO cf https://raw.githubusercontent.com/givpn/AutoScriptXray/master/ssh/cf && chmod +x cf && ./cf
elif [[ $dns == "2" ]]; then
  read -rp "Masukkan domain: " dom
  for file in /root/domain /etc/xray/domain /etc/xray/scdomain /etc/v2ray/domain /etc/v2ray/scdomain; do
    echo "$dom" > "$file"
  done
  echo "IP=$dom" > /var/lib/ipvps.conf
else
  echo -e "${red}Pilihan tidak valid!${NC}"
  exit 1
fi

# Auto menu saat login
cat > /root/.profile <<-END
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
clear
menu
END

chmod 644 /root/.profile

# Cleanup
rm -f /root/setup.sh
echo -e "${green}✅ Setup selesai, VPS akan reboot dalam 10 detik...${NC}"
sleep 10
reboot
