#!/bin/bash
# Trial SSH Account - by znand-dev

# Ambil domain
if [[ -e /etc/xray/domain ]]; then
  domain=$(cat /etc/xray/domain)
elif [[ -e /etc/v2ray/domain ]]; then
  domain=$(cat /etc/v2ray/domain)
else
  domain=$(cat /root/domain)
fi

# Ambil port dari log
openssh=$(grep -w "OpenSSH" /root/log-install.txt | cut -d: -f2 | awk '{print $1}')
dropbear=$(grep -w "Dropbear" /root/log-install.txt | cut -d: -f2)
ssl=$(grep -w "Stunnel4" /root/log-install.txt | cut -d: -f2)
squid=$(grep -w "Squid" /root/log-install.txt | cut -d: -f2)
sshws=$(grep -w "SSH Websocket" /root/log-install.txt | cut -d: -f2 | awk '{print $1}')
sshsslws=$(grep -w "SSH SSL Websocket" /root/log-install.txt | cut -d: -f2 | awk '{print $1}')

# Generate username & password
user="trial$(tr -dc X-Z0-9 </dev/urandom | head -c4)"
pass="1"
exp_days=1
exp_date=$(date -d "$exp_days days" +"%Y-%m-%d")

# Buat user trial
useradd -e "$exp_date" -s /bin/false -M "$user"
echo -e "$pass\n$pass" | passwd "$user" &>/dev/null

# Info umum
ip=$(curl -s ifconfig.me)
exp_display=$(chage -l "$user" | grep "Account expires" | cut -d: -f2 | sed 's/^[ \t]*//')

# Output
clear
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "\e[1;41;97m        TRIAL SSH ACCOUNT          \e[0m" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "👤 Username : $user" | tee -a /etc/log-create-ssh.log
echo -e "🔑 Password : $pass" | tee -a /etc/log-create-ssh.log
echo -e "📅 Expired  : $exp_display" | tee -a /etc/log-create-ssh.log
echo -e "\e[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m" | tee -a /etc/log-create-ssh.log
echo -e "🌐 IP VPS   : $ip" | tee -a /etc/log-create-ssh.log
echo -e "🌍 Domain   : $domain" | tee -a /etc/log-create-ssh.log
echo -e "📡 OpenSSH  : $openssh" | tee -a /etc/log-create-ssh.log
echo -e "📡 Dropbear : $dropbear" | tee -a /etc/log-create-ssh.log
echo -e "🔒 SSL/TLS  : $ssl" | tee -a /etc/log-create-ssh.log
echo -e "🕸️  SSH WS   : $sshws" | tee -a /etc/log-create-ssh.log
echo -e "🛡️  SSH SSL WS : $sshsslws" | tee -a /etc/log-create-ssh.log
echo -e "📶 UDPGW    : 7100-7900 (optional)" | tee -a /etc/log-create-ssh.log
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

# Back to menu
read -n 1 -s -r -p "➡️  Tekan enter untuk kembali ke menu"
menu
