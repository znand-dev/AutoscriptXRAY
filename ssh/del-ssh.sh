#!/bin/bash
# Hapus user SSH - by znand-dev

echo -e ""
read -p "Masukkan username yang mau dihapus: " user

# Cek apakah user ada
if id "$user" &>/dev/null; then
    userdel --force "$user"
    echo -e "\n✅ User '$user' berhasil dihapus dari sistem."
else
    echo -e "\n❌ User '$user' tidak ditemukan di sistem."
fi
