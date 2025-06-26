#!/bin/bash
# Tambah akun Trojan - by znand-dev

domain=$(cat /etc/xray/domain)
read -p "Username: " user
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif

exp_date=$(date -d "$masaaktif days" +%Y-%m-%d)

# Tambah ke config Xray
cat >> /etc/xray/config.json <<EOF
### $user $exp_date
{
  "password": "$uuid",
  "email": "$user"
},
EOF

systemctl restart xray

# Buat link config
trojan_link="trojan://$uuid@$domain:443?security=tls&type=ws&path=/trojan&host=$domain#$user"

# Output
echo -e "\n✅ Akun Trojan berhasil dibuat!"
echo -e "Username : $user"
echo -e "Expired  : $exp_date"
echo -e "Password : $uuid"
echo -e "Link     : $trojan_link"
