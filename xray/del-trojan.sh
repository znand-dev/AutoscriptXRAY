#!/bin/bash
# Hapus akun Trojan - by znand-dev

read -p "Masukkan username Trojan yang mau dihapus: " user
config=/etc/xray/config.json

if grep -q "### $user" "$config"; then
    sed -i "/### $user/,/},/d" "$config"
    systemctl restart xray
    echo -e "\n✅ Akun '$user' berhasil dihapus dari Xray."
else
    echo -e "\n❌ Akun '$user' tidak ditemukan."
fi
