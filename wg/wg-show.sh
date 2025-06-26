#!/bin/bash
# Lihat daftar akun aktif WireGuard - by znand-dev

echo -e "🔍 Daftar Akun Aktif WireGuard:"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
wg show wg0
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
