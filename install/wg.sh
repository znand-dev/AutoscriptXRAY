#!/bin/bash
# Install WireGuard + config awal

apt install -y wireguard qrencode

# Buat konfigurasi dasar wg0
mkdir -p /etc/wireguard
privkey=$(wg genkey)
pubkey=$(echo "$privkey" | wg pubkey)

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.66.66.1/24
ListenPort = 51820
PrivateKey = $privkey
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp += iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown += iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/30-wg.conf
sysctl --system

# Aktifkan dan jalankan WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo "$pubkey" > /etc/wireguard/public.key

echo "✅ WireGuard berhasil di-install & aktif!"
