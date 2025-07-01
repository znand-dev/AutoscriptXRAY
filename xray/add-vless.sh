#!/bin/bash
# Tambah akun VLESS - by znand-dev

# Functions
error() { echo -e "\e[1;31m[ERROR]\e[0m $1"; }
info() { echo -e "\e[1;32m[INFO]\e[0m $1"; }

# Validasi dependencies
if ! command -v jq &> /dev/null; then
    error "jq tidak terinstall. Installing..."
    apt update && apt install -y jq
fi

domain=$(cat /etc/xray/domain)
read -p "Username: " user
read -p "Expired (hari): " masaaktif

# Input validation untuk username
if [[ ! "$user" =~ ^[a-zA-Z0-9_-]{3,32}$ ]]; then
    error "Username tidak valid! (3-32 karakter alphanumeric, underscore, dash)"
    exit 1
fi

# Input validation untuk masa aktif
if [[ ! "$masaaktif" =~ ^[0-9]{1,3}$ ]] || [[ "$masaaktif" -lt 1 ]] || [[ "$masaaktif" -gt 365 ]]; then
    error "Masa aktif tidak valid! (1-365 hari)"
    exit 1
fi

# Check apakah user sudah exist
if grep -q "\"email\": \"$user\"" /etc/xray/config.json; then
    error "User '$user' sudah exist!"
    exit 1
fi

uuid=$(cat /proc/sys/kernel/random/uuid)
exp_date=$(date -d "$masaaktif days" +%Y-%m-%d)

# File locking untuk avoid race condition
info "Menambahkan user ke konfigurasi..."
(
    flock -x 200
    
    # Backup config terlebih dahulu
    cp /etc/xray/config.json /etc/xray/config.json.backup
    
    # Safe JSON manipulation menggunakan jq
    temp_config=$(mktemp)
    if ! jq --arg user "$user" --arg uuid "$uuid" --arg exp "$exp_date" \
        '.inbounds[1].settings.clients += [{"id": $uuid, "flow": "", "email": $user}]' \
        /etc/xray/config.json > "$temp_config"; then
        error "Gagal update config JSON!"
        rm -f "$temp_config"
        exit 1
    fi
    
    # Validate JSON syntax
    if ! jq empty "$temp_config" 2>/dev/null; then
        error "Config JSON tidak valid setelah update!"
        rm -f "$temp_config"
        exit 1
    fi
    
    mv "$temp_config" /etc/xray/config.json
    
) 200>/var/lock/xray-config.lock

# Error handling untuk restart service
info "Restarting Xray service..."
if ! systemctl restart xray; then
    error "Gagal restart xray service!"
    # Restore backup
    cp /etc/xray/config.json.backup /etc/xray/config.json
    exit 1
fi

# Health check
sleep 2
if ! systemctl is-active --quiet xray; then
    error "Service xray tidak running setelah restart!"
    # Restore backup dan restart
    cp /etc/xray/config.json.backup /etc/xray/config.json
    systemctl restart xray
    exit 1
fi

# Buat link config
vless_link="vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless&host=$domain#${user}"

# Output
echo -e "\n✅ Akun VLESS berhasil dibuat!"
echo -e "Username : $user"
echo -e "Expired  : $exp_date"
echo -e "UUID     : $uuid"
echo -e "Link     : $vless_link"
