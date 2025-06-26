#!/bin/bash
# Cek semua akun SSH aktif (non-expired) - by znand-dev

echo -e "🔎 Daftar akun aktif di server:"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
today=$(date +%s)

while IFS=: read -r username _ uid _ _ home shell; do
    if [[ $uid -ge 1000 && $shell == "/bin/false" ]]; then
        exp_date=$(chage -l "$username" | grep "Account expires" | awk -F": " '{print $2}')
        if [[ $exp_date != "never" ]]; then
            exp_ts=$(date -d "$exp_date" +%s)
            if [[ $exp_ts -ge $today ]]; then
                echo "✅ $username → Exp: $exp_date"
            else
                echo "❌ $username → Expired!"
            fi
        fi
    fi
done < /etc/passwd
