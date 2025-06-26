#!/bin/bash
# Cek login aktif VMess - by znand-dev

echo -e "🔎 User VMess aktif (log xray access):"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_file="/var/log/xray/access.log"

if [[ ! -f $log_file ]]; then
    echo "Log file tidak ditemukan!"
    exit 1
fi

grep 'accepted' $log_file | awk '{print $3}' | cut -d':' -f1 | sort | uniq -c | sort -nr
