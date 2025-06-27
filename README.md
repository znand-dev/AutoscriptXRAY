
# 🔐 autoscript_znand

🔥 AutoScript VPN all-in-one 🔥  
Script modular dan interaktif untuk install protokol VPN lengkap: **SSH, WebSocket, XRAY (VMess, VLess, Trojan, Shadowsocks), WireGuard**, dan berbagai tools DevOps + monitoring.

---

## 🚀 Quick Install

Jalankan perintah ini langsung di VPS lo (Debian/Ubuntu KVM Only):

```bash
# 1. Disable IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# 2. Install dependensi dasar
apt update -y && apt install -y git curl screen

# 3. Clone repo dari GitHub
git clone https://github.com/znand-dev/AutoscriptXRAY.git
cd autoscript_znand

# 4. Jalankan installer via screen
chmod +x setup.sh
screen -S setup ./setup.sh
```

---

## 📦 Fitur Utama

- ✅ SSH + Dropbear + Stunnel + WebSocket
- ✅ XRAY: Vmess, Vless, Trojan, Shadowsocks (WS + gRPC)
- ✅ WireGuard VPN
- ✅ Installer WebSocket custom
- ✅ Menu interaktif per protokol
- ✅ Tools tambahan: Backup, Domain, Speedtest
- ✅ Setup domain random/manual
- ✅ Autostart menu saat login VPS

---

## 📁 Struktur Direktori

```bash
autoscript_znand/
├── install.sh            # Master installer (internal)
├── setup.sh              # Entry point buat user (via screen)
├── menu.sh               # Menu utama
├── install/              # Sub-installer per protokol
│   ├── ssh.sh
│   ├── wg.sh
│   ├── websocket.sh
│   └── xray.sh
├── ssh/
│   ├── m-sshovpn
│   ├── add-ssh.sh
│   ├── del-ssh.sh
│   ├── cek-login.sh
│   ├── cek-aktif.sh
│   └── restart-ssh.sh
├── wg/
│   ├── m-wg
│   ├── wg-add.sh
│   ├── wg-del.sh
│   └── wg-show.sh
├── websocket/
│   ├── restart-ws.sh
│   ├── service-install.sh
│   └── stop-ws.sh
├── xray/
│   ├── m-vmess
│   ├── m-vless
│   ├── m-trojan
│   ├── m-ssws
│   ├── add-*.sh, del-*.sh, cek-*.sh, renew-*.sh (semua protokol)
├── tools/
│   ├── tools-menu
│   ├── backup.sh
│   ├── domain.sh
│   └── speedtest.sh
```

---

## ✅ Kompatibilitas

| OS           | Status    |
|--------------|-----------|
| Debian 10    | ✅ Support |
| Debian 11    | ✅ Support |
| Ubuntu 20.04 | ✅ Support |
| Ubuntu 22.04 | ✅ Support |
| OpenVZ       | ❌ Not supported |
| KVM/VMWare   | ✅ Recommended |

---

## 🤝 Credits

- Original inspirasi: [givpn/AutoScriptXray](https://github.com/givpn/AutoScriptXray)
- Custom version by: [znand-dev](https://github.com/znand-dev)

---

## 💬 Support & Diskusi

Join channel: [t.me/znanddev](https://t.me/znanddev)
Follow GitHub: [github.com/znand-dev](https://github.com/znand-dev)

---
