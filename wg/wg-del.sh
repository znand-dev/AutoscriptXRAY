#!/bin/bash
# Hapus akun WireGuard - by znand-dev

read -p "Masukkan nama user yang ingin dihapus: " user
pubkey=$(grep -A 3 "# $user" /etc/wireguard/wg0.conf | grep PublicKey | awk '{print $3}')

if [[ -z "$pubkey" ]]; then
  echo "❌ User tidak ditemukan!"
  exit 1
fi

# Hapus dari config
sed -i "/# $user/,+4d" /etc/wireguard/wg0.conf
rm -f /etc/wireguard/clients/$user.conf

systemctl restart wg-quick@wg0
echo -e "\n✅ Akun WireGuard '$user' berhasil dihapus!"
