#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS"
clear

# Load domain
source /var/lib/ipvps.conf
if [[ "$IP" = "" ]]; then
  domain=$(cat /etc/xray/domain)
else
  domain=$IP
fi

# Ambil port TLS & non-TLS dari log-install
tls="$(grep -w "Vless WS TLS" ~/log-install.txt | cut -d: -f2 | tr -d ' ')"
none="$(grep -w "Vless WS none TLS" ~/log-install.txt | cut -d: -f2 | tr -d ' ')"

# Input user
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[44;1;39m       Add Vless Account        \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  read -rp "Username: " -e user
  CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    echo -e "\n\033[1;31mUser '$user' sudah ada, coba nama lain!\033[0m"
    read -n 1 -s -r -p "Tekan apa saja untuk kembali..."
    m-vless
    exit
  fi
done

# Generate UUID & tanggal expired
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Tambah user ke config
sed -i '/#vless$/a\#& '"$user $exp"'\n},{"id": "'"$uuid"'","email": "'"$user"'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#& '"$user $exp"'\n},{"id": "'"$uuid"'","email": "'"$user"'"' /etc/xray/config.json

# Generate link
vlesslink1="vless://${uuid}@${domain}:${tls}?path=/vless&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:${none}?path=/vless&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:${tls}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#${user}"

# Restart xray
systemctl restart xray

# Output
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo -e "\E[44;1;39m        XRAY Vless ACCOUNT        \E[0m" | tee -a /etc/log-create-vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo -e "Remarks        : ${user}" | tee -a /etc/log-create-vless.log
echo -e "Domain         : ${domain}" | tee -a /etc/log-create-vless.log
echo -e "Wildcard       : (bug.com).${domain}" | tee -a /etc/log-create-vless.log
echo -e "Port TLS       : ${tls}" | tee -a /etc/log-create-vless.log
echo -e "Port none TLS  : ${none}" | tee -a /etc/log-create-vless.log
echo -e "Port gRPC      : ${tls}" | tee -a /etc/log-create-vless.log
echo -e "id             : ${uuid}" | tee -a /etc/log-create-vless.log
echo -e "Encryption     : none" | tee -a /etc/log-create-vless.log
echo -e "Network        : ws / grpc" | tee -a /etc/log-create-vless.log
echo -e "Path           : /vless" | tee -a /etc/log-create-vless.log
echo -e "ServiceName    : vless-grpc" | tee -a /etc/log-create-vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo -e "Link TLS       : ${vlesslink1}" | tee -a /etc/log-create-vless.log
echo -e "Link none TLS  : ${vlesslink2}" | tee -a /etc/log-create-vless.log
echo -e "Link gRPC      : ${vlesslink3}" | tee -a /etc/log-create-vless.log
echo -e "Expired On     : ${exp}" | tee -a /etc/log-create-vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo "" | tee -a /etc/log-create-vless.log
read -n 1 -s -r -p "Tekan apa saja untuk kembali ke menu..."

m-vless

