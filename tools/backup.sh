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
  cp -r /etc/xray/config.json "$backup_folder/" 2>/dev/null
  cp -r /etc/xray/domain "$backup_folder/" 2>/dev/null
  cp -r /usr/bin/* "$backup_folder/" 2>/dev/null

  cd /root
  zip -r backup-autoscript.zip backup-autoscript >/dev/null
  echo -e "\n✅ Backup selesai!"
  echo -e "📁 File: /root/backup-autoscript.zip"
  echo -e "${YELLOW}Simpan file zip ini untuk restore nanti.${NC}"
  ;;
2)
  while true; do
    read -p "🗂 Masukkan path file ZIP backup: " path
    
    # Input validation
    if [[ -z "$path" ]]; then
      echo -e "❌ Path tidak boleh kosong!"
      continue
    fi
    
    # Security checks untuk path traversal
    if [[ "$path" =~ \.\. ]]; then
      echo -e "❌ Path tidak aman! (mengandung '..')"
      continue
    fi
    
    # Hanya allow path di /root atau /home untuk safety
    if [[ ! "$path" =~ ^(/root|/home|\./) ]]; then
      echo -e "❌ Path harus di /root, /home, atau direktori saat ini!"
      continue
    fi
    
    # Check apakah file exist
    if [[ ! -f "$path" ]]; then
      echo -e "❌ File backup tidak ditemukan!"
      continue
    fi
    
    # Check apakah file adalah ZIP
    if ! file "$path" | grep -q "Zip archive"; then
      echo -e "❌ File bukan ZIP archive!"
      continue
    fi
    
    # Check ukuran file (prevent bomb)
    file_size=$(stat -c%s "$path")
    if [[ $file_size -gt 104857600 ]]; then  # 100MB limit
      echo -e "❌ File terlalu besar! (maksimal 100MB)"
      continue
    fi
    
    break
  done
  
  echo -e "\n🔄 Restore data..."
  
  # Create secure temp directory
  temp_restore=$(mktemp -d)
  
  # Extract dengan safety
  if ! unzip -j "$path" -d "$temp_restore" >/dev/null 2>&1; then
    echo -e "❌ Gagal extract backup!"
    rm -rf "$temp_restore"
    exit 1
  fi
  
  # Validate extracted files
  if [[ ! -f "$temp_restore/config.json" ]] || [[ ! -f "$temp_restore/domain" ]]; then
    echo -e "❌ Backup tidak lengkap (missing config.json atau domain)!"
    rm -rf "$temp_restore"
    exit 1
  fi
  
  # Validate JSON syntax
  if ! jq empty "$temp_restore/config.json" 2>/dev/null; then
    echo -e "❌ Config JSON tidak valid!"
    rm -rf "$temp_restore"
    exit 1
  fi
  
  # Backup current config sebelum restore
  cp /etc/xray/config.json /etc/xray/config.json.pre-restore.$(date +%s)
  
  # Restore files dengan aman
  cp "$temp_restore/config.json" /etc/xray/
  cp "$temp_restore/domain" /etc/xray/
  
  # Restart service dengan error checking
  if ! systemctl restart xray; then
    echo -e "❌ Gagal restart xray service!"
    echo -e "🔄 Restoring previous config..."
    cp /etc/xray/config.json.pre-restore.* /etc/xray/config.json
    systemctl restart xray
    rm -rf "$temp_restore"
    exit 1
  fi
  
  # Cleanup
  rm -rf "$temp_restore"
  echo -e "\n✅ Restore selesai!"
  ;;
x) menu ;;
*) echo "❌ Pilihan salah!" ; sleep 1 ; bash $0 ;;
esac
