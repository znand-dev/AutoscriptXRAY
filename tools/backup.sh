#!/bin/bash
# Backup tool - by znand-dev

# Warna
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
NC='\e[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}            🔄 BACKUP & RESTORE TOOLS         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[1]${NC} Backup Data"
echo -e "${GREEN}[2]${NC} Restore Data"
echo -e "${GREEN}[x]${NC} Kembali ke menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "👉 Pilih opsi: " opt

backup_folder="/root/backup-autoscript"
mkdir -p "$backup_folder"

case $opt in
1)
  echo -e "\n📦 Membuat backup..."
  cp -r /etc/xray/config.json $backup_folder/ 2>/dev/null
  cp -r /etc/xray/domain $backup_folder/ 2>/dev/null
  cp -r /usr/bin/* $backup_folder/ 2>/dev/null

  cd /root
  zip -r backup-autoscript.zip backup-autoscript >/dev/null
  echo -e "\n✅ Backup selesai!"
  echo -e "📁 File: /root/backup-autoscript.zip"
  echo -e "${YELLOW}Simpan file zip ini untuk restore nanti.${NC}"
  ;;
2)
  read -p "🗂 Masukkan path file ZIP backup: " path
  if [[ -f "$path" ]]; then
    echo -e "\n🔄 Restore data..."
    unzip "$path" -d /root >/dev/null
    cp -r /root/backup-autoscript/config.json /etc/xray/
    cp -r /root/backup-autoscript/domain /etc/xray/
    cp -r /root/backup-autoscript/* /usr/bin/
    systemctl restart xray
    echo -e "\n✅ Restore selesai!"
  else
    echo -e "❌ File backup tidak ditemukan!"
  fi
  ;;
x) menu ;;
*) echo "❌ Pilihan salah!" ; sleep 1 ; bash $0 ;;
esac
