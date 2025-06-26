#!/bin/bash
# Hapus akun SS WS - by znand-dev

read -p "Masukkan username yang ingin dihapus: " user
config=/etc/xray/config.json

if grep -q "### $user" "$config"; then
    sed -i "/### $user/,/},/d" "$config"
    systemctl restart xray
    echo -e "\n✅ Akun '$user' berhasil dihapus dari SS WS"
else
    echo -e "\n❌ Akun '$user' tidak ditemukan!"
fi
