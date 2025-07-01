#!/bin/bash
# Install Dependencies untuk Security Fixes
# AutoScript ZNAND - Security Enhancement

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "Script ini harus dijalankan sebagai root"
   exit 1
fi

info "Installing security dependencies..."

# Update package list
info "Updating package list..."
if ! apt update -y; then
    error "Gagal update package list"
    exit 1
fi

# Install jq for safe JSON manipulation
if ! command -v jq &> /dev/null; then
    info "Installing jq..."
    if ! apt install -y jq; then
        error "Gagal install jq"
        exit 1
    fi
else
    info "jq sudah terinstall"
fi

# Install util-linux for flock
if ! command -v flock &> /dev/null; then
    info "Installing util-linux for flock..."
    if ! apt install -y util-linux; then
        error "Gagal install util-linux"
        exit 1
    fi
else
    info "flock sudah tersedia"
fi

# Install file command for file type detection
if ! command -v file &> /dev/null; then
    info "Installing file command..."
    if ! apt install -y file; then
        error "Gagal install file command"
        exit 1
    fi
else
    info "file command sudah tersedia"
fi

# Create lock directory
info "Creating lock directory..."
mkdir -p /var/lock
chmod 755 /var/lock

# Create log directory for WebSocket
info "Creating log directory..."
mkdir -p /var/log
touch /var/log/sshws.log
chmod 644 /var/log/sshws.log

# Set proper permissions
info "Setting proper permissions..."
chmod +x /usr/local/bin/sshws.py 2>/dev/null || true

info "✅ Dependencies berhasil diinstall!"
info "Dependencies yang terinstall:"
echo "  - jq: $(jq --version)"
echo "  - flock: available"
echo "  - file: $(file --version | head -1)"

info "🔒 Security enhancements siap digunakan!"