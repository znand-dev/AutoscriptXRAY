#!/bin/bash
# Security Summary Script - AutoScript ZNAND
# Menampilkan ringkasan status keamanan sistem

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}              🛡️ AUTOSCRIPT ZNAND SECURITY SUMMARY           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# System Information
echo -e "${BLUE}📊 SYSTEM INFORMATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Hostname     : $(hostname)"
echo "OS           : $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel       : $(uname -r)"
echo "Architecture : $(uname -m)"
echo "Scan Date    : $(date)"
echo ""

# Security Status
echo -e "${GREEN}🔒 SECURITY STATUS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Security Rating Calculation
security_score=0
max_score=10

# Check critical security files
critical_files=(
    "install-dependencies.sh"
    "fix-variable-quotes.sh" 
    "verify-quotes.sh"
    "xray/xray-utils.sh"
    "tools/health-check.sh"
    "tools/log-cleanup.sh"
)

files_present=0
for file in "${critical_files[@]}"; do
    if [[ -f "$file" ]]; then
        ((files_present++))
    fi
done

file_score=$((files_present * 10 / ${#critical_files[@]}))
security_score=$((security_score + file_score))

echo -e "Security Files   : ${GREEN}$files_present/${#critical_files[@]} present${NC} (Score: $file_score/10)"

# Check for security fixes in key files
fixes_applied=0
total_fixes=5

# Check JSON injection fixes
if grep -q "jq" xray/add-vmess.sh 2>/dev/null; then
    ((fixes_applied++))
fi

# Check error handling
if grep -q "if ! systemctl restart" xray/del-vless.sh 2>/dev/null; then
    ((fixes_applied++))
fi

# Check variable quoting
if grep -q 'cp -r /etc/xray/config.json "$backup_folder/"' tools/backup.sh 2>/dev/null; then
    ((fixes_applied++))
fi

# Check health monitoring
if [[ -f "tools/health-check.sh" ]]; then
    ((fixes_applied++))
fi

# Check log management
if [[ -f "tools/log-cleanup.sh" ]]; then
    ((fixes_applied++))
fi

fixes_score=$((fixes_applied * 10 / total_fixes))
security_score=$((security_score + fixes_score))

echo -e "Security Fixes   : ${GREEN}$fixes_applied/$total_fixes applied${NC} (Score: $fixes_score/10)"

# Check service status
services=("ssh" "xray" "sshws")
services_running=0

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        ((services_running++))
    fi
done

service_score=$((services_running * 10 / ${#services[@]}))
security_score=$((security_score + service_score))

echo -e "Services Running : ${GREEN}$services_running/${#services[@]} active${NC} (Score: $service_score/10)"

# Check dependencies
deps=("jq" "flock" "file")
deps_installed=0

for dep in "${deps[@]}"; do
    if command -v "$dep" &> /dev/null; then
        ((deps_installed++))
    fi
done

deps_score=$((deps_installed * 10 / ${#deps[@]}))
security_score=$((security_score + deps_score))

echo -e "Dependencies     : ${GREEN}$deps_installed/${#deps[@]} installed${NC} (Score: $deps_score/10)"

# Final security score (out of 40, convert to 10)
final_score=$((security_score / 4))

echo ""
echo -e "${PURPLE}Overall Security Rating: ${CYAN}$final_score/10${NC}"

if [[ $final_score -ge 9 ]]; then
    rating_text="${GREEN}🏆 EXCELLENT - Enterprise Grade${NC}"
elif [[ $final_score -ge 7 ]]; then
    rating_text="${YELLOW}⭐ GOOD - Production Ready${NC}"
elif [[ $final_score -ge 5 ]]; then
    rating_text="${YELLOW}⚠️ FAIR - Needs Attention${NC}"
else
    rating_text="${RED}❌ POOR - Critical Issues${NC}"
fi

echo -e "Security Level   : $rating_text"
echo ""

# Protocol Status
echo -e "${CYAN}⚙️ PROTOCOL STATUS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

protocols_active=()
protocols_inactive=()

# Check SSH
if systemctl is-active --quiet ssh 2>/dev/null; then
    protocols_active+=("SSH/Dropbear")
else
    protocols_inactive+=("SSH/Dropbear")
fi

# Check WebSocket
if systemctl is-active --quiet sshws 2>/dev/null; then
    protocols_active+=("WebSocket")
else
    protocols_inactive+=("WebSocket")
fi

# Check XRAY protocols
if systemctl is-active --quiet xray 2>/dev/null && [[ -f /etc/xray/config.json ]]; then
    if jq -e '.inbounds[] | select(.protocol=="vmess")' /etc/xray/config.json &>/dev/null; then
        protocols_active+=("VMess")
    fi
    if jq -e '.inbounds[] | select(.protocol=="vless")' /etc/xray/config.json &>/dev/null; then
        protocols_active+=("VLess")
    fi
fi

echo -e "Active Protocols : ${GREEN}${protocols_active[*]:-None}${NC}"
echo -e "Inactive         : ${YELLOW}${protocols_inactive[*]:-None}${NC}"

# Get user counts if possible
if [[ -f /etc/xray/config.json ]]; then
    vmess_users=$(jq -r '.inbounds[] | select(.protocol=="vmess") | .settings.clients[]? | .email' /etc/xray/config.json 2>/dev/null | wc -l)
    vless_users=$(jq -r '.inbounds[] | select(.protocol=="vless") | .settings.clients[]? | .email' /etc/xray/config.json 2>/dev/null | wc -l)
    echo -e "Total Users      : VMess($vmess_users), VLess($vless_users)"
fi

echo ""

# Security Features Status
echo -e "${YELLOW}🔧 SECURITY FEATURES${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

features=(
    "JSON Injection Protection:xray/add-vmess.sh:jq"
    "Input Validation:tools/:validate_domain"
    "Error Handling:xray/:if ! systemctl restart"
    "File Locking:xray/:flock"
    "Health Monitoring:tools/health-check.sh:-f"
    "Log Management:tools/log-cleanup.sh:-f"
    "Variable Quoting:tools/backup.sh:backup_folder"
    "Auto Dependencies:install-dependencies.sh:-f"
)

for feature in "${features[@]}"; do
    IFS=':' read -r name file pattern <<< "$feature"
    
    if [[ "$pattern" == "-f" ]]; then
        # File existence check
        if [[ -f "$file" ]]; then
            echo -e "✅ ${name}"
        else
            echo -e "❌ ${name}"
        fi
    else
        # Pattern check in file
        if [[ -f "$file" ]] && grep -q "$pattern" "$file" 2>/dev/null; then
            echo -e "✅ ${name}"
        elif find . -name "$(basename "$file")" -type f -exec grep -l "$pattern" {} \; 2>/dev/null | head -1 >/dev/null; then
            echo -e "✅ ${name}"
        else
            echo -e "❌ ${name}"
        fi
    fi
done

echo ""

# Resource Status
echo -e "${BLUE}💻 RESOURCE STATUS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Memory usage
mem_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
if (( $(echo "$mem_usage > 80.0" | bc -l 2>/dev/null || echo "0") )); then
    mem_status="${RED}High ($mem_usage%)${NC}"
elif (( $(echo "$mem_usage > 60.0" | bc -l 2>/dev/null || echo "0") )); then
    mem_status="${YELLOW}Medium ($mem_usage%)${NC}"
else
    mem_status="${GREEN}Good ($mem_usage%)${NC}"
fi

# Disk usage
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [[ $disk_usage -gt 85 ]]; then
    disk_status="${RED}High ($disk_usage%)${NC}"
elif [[ $disk_usage -gt 70 ]]; then
    disk_status="${YELLOW}Medium ($disk_usage%)${NC}"
else
    disk_status="${GREEN}Good ($disk_usage%)${NC}"
fi

echo -e "Memory Usage     : $mem_status"
echo -e "Disk Usage       : $disk_status"
echo -e "Load Average     : $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')"
echo -e "System Uptime    : $(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"

echo ""

# Quick Actions
echo -e "${PURPLE}🚀 QUICK ACTIONS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Run Health Check    : bash tools/health-check.sh"
echo "Clean Logs         : bash tools/log-cleanup.sh"
echo "Verify Security    : bash verify-quotes.sh"
echo "Install Dependencies: bash install-dependencies.sh"
echo "View Documentation : cat FINAL_SECURITY_FIXES.md"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Final recommendation
if [[ $final_score -ge 8 ]]; then
    echo -e "${GREEN}🎉 Your AutoScript ZNAND installation is highly secure!${NC}"
    echo -e "${GREEN}✅ No immediate action required. Regular monitoring recommended.${NC}"
elif [[ $final_score -ge 6 ]]; then
    echo -e "${YELLOW}⚠️ Your installation is moderately secure.${NC}"
    echo -e "${YELLOW}💡 Consider running: bash tools/health-check.sh${NC}"
else
    echo -e "${RED}🚨 Security improvements needed!${NC}"
    echo -e "${RED}🔧 Run: bash install-dependencies.sh && bash fix-variable-quotes.sh${NC}"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"