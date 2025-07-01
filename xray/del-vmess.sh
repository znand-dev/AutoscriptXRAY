#!/bin/bash
# Hapus akun VMess - by znand-dev

read -p "Masukkan username VMess yang mau dihapus: " user
config=/etc/xray/config.json

if grep -q "### $user" "$config"; then
    # Backup config sebelum hapus
    cp "$config" "$config.backup"
    
    # Hapus user dari config
    sed -i "/### $user/,/},/d" "$config"
    
    # Restart service dengan error handling
    if ! systemctl restart xray; then
        echo -e "\n❌ Gagal restart xray service!"
        # Restore backup
        cp "$config.backup" "$config"
        systemctl restart xray
        exit 1
    fi
    
    # Health check
    sleep 2
    if ! systemctl is-active --quiet xray; then
        echo -e "\n❌ Service xray tidak running setelah restart!"
        exit 1
    fi
    
    echo -e "\n✅ Akun '$user' berhasil dihapus dari Xray."
else
    echo -e "\n❌ Akun '$user' tidak ditemukan."
fi
