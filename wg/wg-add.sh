#!/bin/bash
# Tambah akun WireGuard - by znand-dev

read -p "Masukkan nama user: " user
priv_key=$(wg genkey)
pub_key=$(echo "$priv_key" | wg pubkey)
psk=$(wg genpsk)
client_ip="10.66.66.$((RANDOM % 200 + 2))/32"

# Buat folder klien
mkdir -p /etc/wireguard/clients
client_config="/etc/wireguard/clients/$user.conf"

# Ambil info server
server_ip=$(curl -s ifconfig.me)
server_port=$(grep ListenPort /etc/wireguard/wg0.conf | awk '{print $3}')
server_pubkey=$(wg show wg0 public-key)

# Tambah ke config server
echo -e "\n# $user\n[Peer]\nPublicKey = $pub_key\nPresharedKey = $psk\nAllowedIPs = $client_ip" >> /etc/wireguard/wg0.conf

# Buat config klien
cat > $client_config <<EOF
[Interface]
PrivateKey = $priv_key
Address = $client_ip
DNS = 1.1.1.1

[Peer]
PublicKey = $server_pubkey
PresharedKey = $psk
Endpoint = $server_ip:$server_port
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Apply config dengan error handling
if ! systemctl restart wg-quick@wg0; then
    echo -e "\n❌ Gagal restart WireGuard service!"
    # Cleanup config yang baru ditambah
    wg-quick down wg0 2>/dev/null
    sed -i "/# $user/,+3d" /etc/wireguard/wg0.conf
    rm -f "/etc/wireguard/clients/$user.conf"
    wg-quick up wg0 2>/dev/null
    exit 1
fi

# Health check
sleep 2
if ! systemctl is-active --quiet wg-quick@wg0; then
    echo -e "\n❌ WireGuard service tidak running setelah restart!"
    exit 1
fi

# Tampilkan config + QR
echo -e "\n✅ Akun WireGuard '$user' berhasil dibuat!"
echo -e "📄 Config:\n"
cat $client_config

echo -e "\n📷 QR Code (scan via WireGuard app):"
qrencode -t ansiutf8 < $client_config
