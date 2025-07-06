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

# Ambil port dari log-install
tls="$(grep -w "Trojan WS TLS" ~/log-install.txt | cut -d: -f2 | tr -d ' ')"
none="$(grep -w "Trojan WS none TLS" ~/log-install.txt | cut -d: -f2 | tr -d ' ')"

# Input user
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[44;1;39m      Add Trojan Account       \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  read -rp "Username: " -e user
  CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    echo -e "\n\033[1;31mUser '$user' sudah ada, coba nama lain!\033[0m"
    read -n 1 -s -r -p "Tekan apa saja untuk kembali..."
    m-trojan
    exit
  fi
done

# Generate password & expired
trojan_pwd=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Tambah user ke config
sed -i '/#trojan$/a\#& '"$user $exp"'\n},{"password": "'"$trojan_pwd"'","email": "'"$user"'"' /etc/xray/config.json

# Generate link
trojanlink1="trojan://${trojan_pwd}@${domain}:${tls}?path=/trojan&security=tls&type=ws#${user}"
trojanlink2="trojan://${trojan_pwd}@${domain}:${none}?path=/trojan&type=ws#${user}"
trojanlink3="trojan://${trojan_pwd}@${domain}:${tls}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"

# Restart xray
systemctl restart xray

# Output
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "\E[44;1;39m       XRAY Trojan ACCOUNT       \E[0m" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Remarks        : ${user}" | tee -a /etc/log-create-trojan.log
echo -e "Domain         : ${domain}" | tee -a /etc/log-create-trojan.log
echo -e "Port TLS       : ${tls}" | tee -a /etc/log-create-trojan.log
echo -e "Port none TLS  : ${none}" | tee -a /etc/log-create-trojan.log
echo -e "Port gRPC      : ${tls}" | tee -a /etc/log-create-trojan.log
echo -e "Password       : ${trojan_pwd}" | tee -a /etc/log-create-trojan.log
echo -e "Network        : ws / grpc" | tee -a /etc/log-create-trojan.log
echo -e "Path           : /trojan" | tee -a /etc/log-create-trojan.log
echo -e "ServiceName    : trojan-grpc" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Link TLS       : ${trojanlink1}" | tee -a /etc/log-create-trojan.log
echo -e "Link none TLS  : ${trojanlink2}" | tee -a /etc/log-create-trojan.log
echo -e "Link gRPC      : ${trojanlink3}" | tee -a /etc/log-create-trojan.log
echo -e "Expired On     : ${exp}" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo "" | tee -a /etc/log-create-trojan.log
read -n 1 -s -r -p "Tekan apa saja untuk kembali ke menu..."

m-trojan
