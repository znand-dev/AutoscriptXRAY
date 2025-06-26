#!/bin/bash
# Tambah akun SS WS - by znand-dev

domain=$(cat /etc/xray/domain)
read -p "Username: " user
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif

exp_date=$(date -d "$masaaktif days" +%Y-%m-%d)

# Tambah ke config
cat >> /etc/xray/config.json <<EOF
### $user $exp_date
{
  "method": "aes-128-gcm",
  "password": "$uuid",
  "email": "$user"
},
EOF

systemctl restart xray

ss_link="ss://$(echo -n aes-128-gcm:$uuid | base64)@$domain:443?plugin=xray-plugin%3Bpath=%2Fss-ws%3Bhost=$domain%3Btls#${user}"

echo -e "\n✅ Akun Shadowsocks WS berhasil dibuat!"
echo -e "User     : $user"
echo -e "Expired  : $exp_date"
echo -e "UUID     : $uuid"
echo -e "Link     : $ss_link"
