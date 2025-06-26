#!/bin/bash
# Tambah akun VLESS - by znand-dev

domain=$(cat /etc/xray/domain)
read -p "Username: " user
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif

exp_date=$(date -d "$masaaktif days" +%Y-%m-%d)

# Tambahkan ke config.json
cat >> /etc/xray/config.json <<EOF
### $user $exp_date
{
  "id": "$uuid",
  "flow": "",
  "email": "$user"
},
EOF

systemctl restart xray

# Buat link config
vless_link="vless://$uuid@$domain:443?encryption=none&security=tls&type=ws&path=/vless&host=$domain#${user}"

# Output
echo -e "\n✅ Akun VLESS berhasil dibuat!"
echo -e "Username : $user"
echo -e "Expired  : $exp_date"
echo -e "UUID     : $uuid"
echo -e "Link     : $vless_link"
