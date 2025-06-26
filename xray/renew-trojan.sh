#!/bin/bash
# Perpanjang akun Trojan - by znand-dev

read -p "Masukkan username yang ingin diperpanjang: " user
read -p "Tambah masa aktif (hari): " tambah

exp_now=$(grep -w "### $user" /etc/xray/config.json | cut -d ' ' -f3)
if [[ -z "$exp_now" ]]; then
    echo "❌ Username tidak ditemukan!"
    exit 1
fi

exp_ts=$(date -d "$exp_now" +%s)
now_ts=$(date +%s)
remain_days=$(( (exp_ts - now_ts) / 86400 ))
total_days=$(( remain_days + tambah ))
new_exp=$(date -d "$total_days days" +%Y-%m-%d)

sed -i "s/### $user.*/### $user $new_exp/" /etc/xray/config.json
systemctl restart xray

echo -e "\n✅ Masa aktif akun '$user' diperpanjang hingga $new_exp"
