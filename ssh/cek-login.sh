#!/bin/bash
# Cek login SSH aktif - by znand-dev

echo -e "🔍 User login aktif (dropbear + ssh):"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# SSH
echo -e "\n📦 OpenSSH sessions:"
ps -ef | grep sshd | grep -v grep | grep -iE "pts|tty"

# Dropbear
echo -e "\n📦 Dropbear sessions:"
PIDS=$(pgrep dropbear)
for pid in $PIDS; do
    dropbear_proc=$(cat /proc/$pid/environ 2>/dev/null | tr '\0' '\n' | grep SSH_CONNECTION)
    if [[ ! -z "$dropbear_proc" ]]; then
        login_user=$(ps -p $pid -o user=)
        echo "User: $login_user  |  PID: $pid"
    fi
done

# Stunnel (optional)
echo -e "\n📦 Stunnel (Port 443):"
netstat -tunap | grep ESTABLISHED | grep stunnel || echo "Ga ada yg login via Stunnel"
