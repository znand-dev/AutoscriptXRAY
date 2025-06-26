#!/bin/bash
# Add SSH user - by znand-dev

read -p "Username baru      : " username
read -p "Password           : " password
read -p "Expired (hari)     : " exp_days

# Validasi username
if id "$username" &>/dev/null; then
    echo "❌ Username '$username' sudah ada!"
    exit 1
fi

# Buat user
exp_date=$(date -d "$exp_days days" +%Y-%m-%d)
useradd -e "$exp_date" -s /bin/false -M "$username"
echo -e "$password\n$password" | passwd "$username" &>/dev/null

# Output info akun
IP=$(curl -s ifconfig.me)
echo -e ""
echo -e "✅ SSH Account Created!"
echo -e "────────────────────────────────"
echo -e "Host     : $IP"
echo -e "Username : $username"
echo -e "Password : $password"
echo -e "Expired  : $exp_date"
echo -e "Port     : 22"
echo -e "────────────────────────────────"
