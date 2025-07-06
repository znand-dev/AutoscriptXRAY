#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS"
clear

# Load domain dari config
source /var/lib/ipvps.conf
if [[ "$IP" = "" ]]; then
  domain=$(cat /etc/xray/domain)
else
  domain=$IP
fi

# Ambil port dari log
tls=$(grep -w "XRAY TLS" /root/log-install.txt | cut -d: -f2 | tr -d ' ')
none=$(grep -w "XRAY None TLS" /root/log-install.txt | cut -d: -f2 | tr -d ' ')

# Input username
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[44;1;39m       Add VMess Account        \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  read -rp "Username: " -e user
  CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    echo ""
    echo -e "\033[1;31mUser '$user' sudah ada, coba nama lain!\033[0m"
    read -n 1 -s -r -p "Tekan apa saja untuk kembali..."
    m-vmess
    exit
  fi
done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (hari): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Inject user ke config
sed -i "/#vmess-tls\$/a\#& $user $exp\n      ,{\"id\": \"$uuid\",\"alterId\": 0,\"email\": \"$user\"}" /etc/xray/config.json
sed -i "/#vmess-nontls\$/a\#& $user $exp\n      ,{\"id\": \"$uuid\",\"alterId\": 0,\"email\": \"$user\"}" /etc/xray/config.json

# Buat link
vmesslink1="vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"${user}\",\"add\":\"${domain}\",\"port\":\"${tls}\",\"id\":\"${uuid}\",\"aid\":\"0\",\"net\":\"ws\",\"path\":\"/vmess\",\"type\":\"none\",\"host\":\"${domain}\",\"tls\":\"tls\"}" | base64 -w 0)"
vmesslink2="vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"${user}\",\"add\":\"${domain}\",\"port\":\"${none}\",\"id\":\"${uuid}\",\"aid\":\"0\",\"net\":\"ws\",\"path\":\"/vmess\",\"type\":\"none\",\"host\":\"${domain}\",\"tls\":\"none\"}" | base64 -w 0)"
vmesslink3="vmess://${uuid}@${domain}:${tls}?mode=gun&security=tls&type=grpc&serviceName=vmess-grpc&sni=bug.com#${user}"

# Restart Xray
systemctl restart xray

# Output
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo -e "\E[44;1;39m        XRAY VMess ACCOUNT        \E[0m" | tee -a /etc/log-create-vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo -e "Remarks        : ${user}" | tee -a /etc/log-create-vmess.log
echo -e "Domain         : ${domain}" | tee -a /etc/log-create-vmess.log
echo -e "Wildcard       : (bug.com).${domain}" | tee -a /etc/log-create-vmess.log
echo -e "Port TLS       : ${tls}" | tee -a /etc/log-create-vmess.log
echo -e "Port none TLS  : ${none}" | tee -a /etc/log-create-vmess.log
echo -e "Port gRPC      : ${tls}" | tee -a /etc/log-create-vmess.log
echo -e "id             : ${uuid}" | tee -a /etc/log-create-vmess.log
echo -e "Alter ID       : 0" | tee -a /etc/log-create-vmess.log
echo -e "Encryption     : auto" | tee -a /etc/log-create-vmess.log
echo -e "Network        : ws / grpc" | tee -a /etc/log-create-vmess.log
echo -e "Path           : /vmess" | tee -a /etc/log-create-vmess.log
echo -e "ServiceName    : vmess-grpc" | tee -a /etc/log-create-vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo -e "Link TLS       : ${vmesslink1}" | tee -a /etc/log-create-vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo -e "Link none TLS  : ${vmesslink2}" | tee -a /etc/log-create-vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo -e "Link gRPC      : ${vmesslink3}" | tee -a /etc/log-create-vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo -e "Expired On     : ${exp}" | tee -a /etc/log-create-vmess.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vmess.log
echo "" | tee -a /etc/log-create-vmess.log
read -n 1 -s -r -p "Tekan apa saja untuk kembali ke menu..."

m-vmess
