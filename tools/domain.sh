#!/bin/bash
# Atur ulang domain - by znand-dev

# Warna
CYAN='\e[1;36m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
NC='\e[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}              🌐 GANTI DOMAIN XRAY            ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Minta domain baru
read -rp "📌 Masukkan domain baru: " new_domain

# Validasi input
if [[ -z "$new_domain" ]]; then
    echo -e "${YELLOW}❌ Domain tidak boleh kosong!${NC}"
    exit 1
fi

# Simpan domain baru ke file
echo "$new_domain" > /etc/xray/domain

# Restart service dengan error handling
if ! systemctl restart xray; then
    echo -e "${YELLOW}❌ Gagal restart xray service!${NC}"
    exit 1
fi

# Health check
sleep 2
if ! systemctl is-active --quiet xray; then
    echo -e "${YELLOW}❌ Service xray tidak running setelah restart!${NC}"
    exit 1
fi

# Output
echo -e "${GREEN}✅ Domain berhasil diganti!${NC}"
echo -e "🌐 Domain baru: ${CYAN}$new_domain${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
