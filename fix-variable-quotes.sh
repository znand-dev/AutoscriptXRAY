#!/bin/bash
# Fix Variable Quotes - AutoScript ZNAND Security Enhancement
# Script untuk memperbaiki variable expansion yang tidak di-quote

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

info "🔧 Fixing variable expansion security issues..."

# List of critical fixes yang harus dilakukan manual
critical_fixes=(
    "setup.sh:70:dpkg -s \"\$headerpkg\""
    "setup.sh:72:apt install -y \"\$headerpkg\""
    "uninstall.sh:23:systemctl stop \"\$svc\""
    "uninstall.sh:24:systemctl disable \"\$svc\""
    "uninstall.sh:42:rm -f \"/usr/bin/\$bin\""
    "uninstall.sh:48:userdel -f \"\$u\""
    "tools/running.sh:25:systemctl is-active \"\$svc\""
    "wg/wg-del.sh:13:rm -f \"/etc/wireguard/clients/\$user.conf\""
    "wg/wg-add.sh:11:\"/etc/wireguard/clients/\$user.conf\""
    "wg/wg-add.sh:22:cat > \"\$client_config\""
    "wg/wg-add.sh:42:rm -f \"/etc/wireguard/clients/\$user.conf\""
    "wg/wg-add.sh:57:cat \"\$client_config\""
    "wg/wg-add.sh:60:qrencode -t ansiutf8 < \"\$client_config\""
)

info "Applying critical variable expansion fixes..."

# Fix setup.sh
if [[ -f "setup.sh" ]]; then
    info "Fixing setup.sh..."
    
    # Fix dpkg -s command
    sed -i 's/dpkg -s $headerpkg/dpkg -s "$headerpkg"/g' setup.sh
    
    # Fix apt install command  
    sed -i 's/apt install -y $headerpkg/apt install -y "$headerpkg"/g' setup.sh
    
    info "✅ setup.sh fixed"
fi

# Fix uninstall.sh
if [[ -f "uninstall.sh" ]]; then
    info "Fixing uninstall.sh..."
    
    # Fix systemctl commands
    sed -i 's/systemctl stop $svc/systemctl stop "$svc"/g' uninstall.sh
    sed -i 's/systemctl disable $svc/systemctl disable "$svc"/g' uninstall.sh
    
    # Fix rm commands
    sed -i 's|rm -f /usr/bin/$bin|rm -f "/usr/bin/$bin"|g' uninstall.sh
    sed -i 's/userdel -f $u/userdel -f "$u"/g' uninstall.sh
    
    info "✅ uninstall.sh fixed"
fi

# Fix tools/running.sh
if [[ -f "tools/running.sh" ]]; then
    info "Fixing tools/running.sh..."
    
    # Fix systemctl command
    sed -i 's/systemctl is-active $svc/systemctl is-active "$svc"/g' tools/running.sh
    
    info "✅ tools/running.sh fixed"
fi

# WireGuard scripts removed - no longer applicable

# Additional safety fixes for variables yang sering bermasalah
info "Applying additional safety fixes..."

# Fix $EUID references (sudah benar di install-dependencies.sh)
find . -name "*.sh" -type f -exec grep -l "EUID" {} \; | while read -r file; do
    if grep -q "\\$EUID" "$file" && ! grep -q "\"\$EUID\"" "$file"; then
        warn "Potential EUID fix needed in: $file"
    fi
done

# Verify fixes
info "🔍 Verifying fixes..."

error_count=0

# Check for remaining unquoted critical variables
for pattern in "\$svc" "\$bin" "\$user.conf" "\$headerpkg"; do
    if grep -r --include="*.sh" "$pattern" . | grep -v "\"$pattern\"" | grep -v "# Fixed"; then
        warn "Still found unquoted: $pattern"
        ((error_count++))
    fi
done

if [[ $error_count -eq 0 ]]; then
    info "✅ All critical variable expansions have been quoted!"
    info "🔒 Variable expansion security improved"
else
    warn "⚠️ Found $error_count potential issues that may need manual review"
fi

# Create verification script
cat > verify-quotes.sh << 'EOF'
#!/bin/bash
# Verification script untuk variable quotes

echo "🔍 Checking for unquoted variables that might be security risks..."

# Patterns yang harus di-quote
critical_patterns=(
    '\$svc'
    '\$bin' 
    '\$user\.conf'
    '\$headerpkg'
    '\$temp_[a-zA-Z]*'
    '\$backup_[a-zA-Z]*'
    '\$config[^_]'
)

issues_found=0

for pattern in "${critical_patterns[@]}"; do
    if grep -r --include="*.sh" -E "$pattern" . | grep -v "\".*$pattern.*\"" | grep -v "#.*$pattern"; then
        echo "⚠️ Found unquoted: $pattern"
        ((issues_found++))
    fi
done

if [[ $issues_found -eq 0 ]]; then
    echo "✅ No critical unquoted variables found!"
else
    echo "❌ Found $issues_found potential issues"
fi
EOF

chmod +x verify-quotes.sh

info "✅ Variable expansion fixes completed!"
info "📋 Run './verify-quotes.sh' to check for any remaining issues"
info "🔒 Security improvement: Reduced risk of word splitting and glob expansion"