#!/bin/bash
# Tambah akun VMess - by znand-dev

domain=$(cat /etc/xray/domain)
read -p "Username: " user
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif

exp_date=$(date -d "$masaaktif days" +%Y-%m-%d)

# Buat config di JSON Xray
cat >> /etc/xray/config.json <<EOF
### $user $exp_date
{
  "id": "$uuid",
  "alterId": 0,
  "email": "$user"
},
EOF

# Restart Xray biar config kebaca
systemctl restart xray

# Buat link config
vmess_json=$(cat <<EOF
{
  "v": "2",
  "ps": "$user",
  "add": "$domain",
  "port": "443",
  "id": "$uuid",
  "aid": "0",
  "net": "ws",
  "path": "/vmess",
  "type": "none",
  "host": "$domain",
  "tls": "tls"
}
EOF
)

vmess_link="vmess://$(echo "$vmess_json" | base64 -w0)"

# Output
echo -e "\n✅ Akun VMess berhasil dibuat!"
echo -e "Username : $user"
echo -e "Expired  : $exp_date"
echo -e "UUID     : $uuid"
echo -e "Link     : $vmess_link"
