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

# Input user dengan validasi
while true; do
  read -p "👤 Username baru      : " username
  
  # Validasi format username
  if [[ -z "$username" ]]; then
    echo "❌ Username tidak boleh kosong!"
    continue
  fi
  
  if [[ ! "$username" =~ ^[a-zA-Z0-9_-]{3,32}$ ]]; then
    echo "❌ Username tidak valid! (3-32 karakter: huruf, angka, underscore, dash)"
    continue
  fi
  
  # Check reserved usernames
  reserved_users=("root" "admin" "administrator" "test" "guest" "user" "daemon" "sys" "www-data" "nobody")
  if [[ " ${reserved_users[@]} " =~ " ${username} " ]]; then
    echo "❌ Username '$username' adalah reserved system user!"
    continue
  fi
  
  # Validasi apakah user sudah exist
  if id "$username" &>/dev/null; then
    echo "❌ Username '$username' sudah terdaftar!"
    continue
  fi
  
  break
done

while true; do
  read -s -p "🔑 Password           : " password
  echo
  
  # Password validation
  if [[ -z "$password" ]]; then
    echo "❌ Password tidak boleh kosong!"
    continue
  fi
  
  if [[ ${#password} -lt 6 ]]; then
    echo "❌ Password minimal 6 karakter!"
    continue
  fi
  
  if [[ ${#password} -gt 128 ]]; then
    echo "❌ Password maksimal 128 karakter!"
    continue
  fi
  
  # Confirm password
  read -s -p "🔑 Konfirmasi password: " password_confirm
  echo
  
  if [[ "$password" != "$password_confirm" ]]; then
    echo "❌ Password tidak cocok!"
    continue
  fi
  
  break
done

while true; do
  read -p "⏰ Expired (hari)     : " exp_days
  
  # Validasi masa aktif
  if [[ ! "$exp_days" =~ ^[0-9]{1,3}$ ]]; then
    echo "❌ Masa aktif harus berupa angka!"
    continue
  fi
  
  if [[ "$exp_days" -lt 1 ]] || [[ "$exp_days" -gt 365 ]]; then
    echo "❌ Masa aktif harus 1-365 hari!"
    continue
  fi
  
  break
done

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
