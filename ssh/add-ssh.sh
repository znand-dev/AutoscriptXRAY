#!/bin/bash
# Add SSH user - by znand-dev

# Ambil domain
if [[ -e /etc/xray/domain ]]; then
  domain=$(cat /etc/xray/domain)
elif [[ -e /etc/v2ray/domain ]]; then
  domain=$(cat /etc/v2ray/domain)
else
  domain=$(cat /root/domain)
fi

# Ambil port dari log-install.txt
openssh=$(grep -w "OpenSSH" /root/log-install.txt | cut -d: -f2 | awk '{print $1}')
dropbear=$(grep -w "Dropbear" /root/log-install.txt | cut -d: -f2)
ssl=$(grep -w "Stunnel4" /root/log-install.txt | cut -d: -f2)
squid=$(grep -w "Squid" /root/log-install.txt | cut -d: -f2)
sshws=$(grep -w "SSH Websocket" /root/log-install.txt | cut -d: -f2 | awk '{print $1}')
sshsslws=$(grep -w "SSH SSL Websocket" /root/log-install.txt | cut -d: -f2 | awk '{print $1}')

# Input user
read -p "👤 Username baru      : " username
read -p "🔑 Password           : " password
read -p "⏰ Expired (hari)     : " exp_days

# Validasi
if id "$username" &>/dev/null; then
  echo "❌ Username '$username' sudah terdaftar!"
  exit 1
fi

# Buat akun
exp_date=$(date -d "$exp_days days" +"%Y-%m-%d")
useradd -e "$exp_date" -s /bin/false -M "$username"
echo -e "$password\n$password" | passwd "$username" &>/dev/null
exp_display=$(chage -l "$username" | grep "Account expires" | cut -d: -f2 | sed 's/^[ \t]*//')

# Info Umum
ip=$(curl -s ifconfig.me)

# Output ke layar dan log
clear
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "\e[1;41;97m           SSH ACCOUNT             \e[0m" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "👤 Username : $username" | tee -a /etc/log-create-ssh.log
echo -e "🔑 Password : $password" | tee -a /etc/log-create-ssh.log
echo -e "📅 Expired  : $exp_display" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "🌐 IP VPS   : $ip" | tee -a /etc/log-create-ssh.log
echo -e "🌍 Domain   : $domain" | tee -a /etc/log-create-ssh.log
echo -e "📡 OpenSSH  : $openssh" | tee -a /etc/log-create-ssh.log
echo -e "📡 Dropbear : $dropbear" | tee -a /etc/log-create-ssh.log
echo -e "🔒 SSL/TLS  : $ssl" | tee -a /etc/log-create-ssh.log
echo -e "🕸️  SSH WS   : $sshws" | tee -a /etc/log-create-ssh.log
echo -e "🛡️  SSH SSL WS : $sshsslws" | tee -a /etc/log-create-ssh.log
echo -e "📶 UDPGW    : 7100-7900 (bisa disesuaikan)" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "⚙️  Payload WebSocket (WS)" | tee -a /etc/log-create-ssh.log
echo -e "
GET / HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]
" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "⚙️  Payload WebSocket (WSS)" | tee -a /etc/log-create-ssh.log
echo -e "
GET wss://bug.com/ HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]
" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo "" | tee -a /etc/log-create-ssh.log

# Kembali ke menu
read -n 1 -s -r -p "➡️  Tekan enter untuk kembali ke menu"
menu
