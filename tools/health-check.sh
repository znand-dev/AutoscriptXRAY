#!/bin/bash
# Comprehensive Health Check - AutoScript ZNAND
# Script untuk monitoring kesehatan sistem secara menyeluruh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# Functions
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Health check start
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}        🏥 COMPREHENSIVE HEALTH CHECK         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. Service Health Check
echo -e "${CYAN}📡 SERVICE STATUS CHECK${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

services=("ssh" "dropbear" "sshws" "xray" "stunnel4")
service_issues=0

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        status="${GREEN}✅ Running${NC}"
        
        # Additional checks for each service
        case $service in
            "xray")
                if [[ -f /etc/xray/config.json ]]; then
                    if jq empty /etc/xray/config.json 2>/dev/null; then
                        config_status="${GREEN}✅ Valid${NC}"
                    else
                        config_status="${RED}❌ Invalid JSON${NC}"
                        ((service_issues++))
                    fi
                else
                    config_status="${RED}❌ Missing${NC}"
                    ((service_issues++))
                fi
                printf "%-15s : %s (Config: %s)\n" "$service" "$status" "$config_status"
                ;;
            "sshws")
                if [[ -f /var/log/sshws.log ]]; then
                    log_size=$(stat -c%s /var/log/sshws.log 2>/dev/null || echo "0")
                    if [[ $log_size -gt 1048576 ]]; then  # 1MB
                        log_status="${YELLOW}⚠️ Large${NC}"
                    else
                        log_status="${GREEN}✅ OK${NC}"
                    fi
                else
                    log_status="${YELLOW}⚠️ Missing${NC}"
                fi
                printf "%-15s : %s (Log: %s)\n" "$service" "$status" "$log_status"
                ;;
            *)
                printf "%-15s : %s\n" "$service" "$status"
                ;;
        esac
    else
        status="${RED}❌ Stopped${NC}"
        printf "%-15s : %s\n" "$service" "$status"
        ((service_issues++))
    fi
done

echo ""

# 2. Network & Port Check
echo -e "${CYAN}🌐 NETWORK & PORT CHECK${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

common_ports=("22" "80" "443" "8080")
port_issues=0

for port in "${common_ports[@]}"; do
    if ss -tuln | grep -q ":$port "; then
        echo -e "Port $port     : ${GREEN}✅ Listening${NC}"
    else
        echo -e "Port $port     : ${RED}❌ Not listening${NC}"
        ((port_issues++))
    fi
done

echo ""

# 3. File System Check
echo -e "${CYAN}📁 FILE SYSTEM CHECK${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

file_issues=0

# Check critical files
critical_files=(
    "/etc/xray/config.json"
    "/etc/xray/domain"
    "/etc/xray/private.key"
    "/etc/xray/cert.crt"
    "/usr/local/bin/sshws.py"
)

for file in "${critical_files[@]}"; do
    if [[ -f "$file" ]]; then
        # Check file permissions
        perms=$(stat -c "%a" "$file")
        if [[ "$file" == *"private.key" ]] && [[ "$perms" != "600" ]]; then
            echo -e "$(basename "$file") : ${YELLOW}⚠️ Insecure permissions ($perms)${NC}"
            ((file_issues++))
        else
            echo -e "$(basename "$file") : ${GREEN}✅ Present${NC}"
        fi
    else
        echo -e "$(basename "$file") : ${RED}❌ Missing${NC}"
        ((file_issues++))
    fi
done

echo ""

# 4. Resource Usage Check
echo -e "${CYAN}💻 RESOURCE USAGE CHECK${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

resource_issues=0

# Memory usage
mem_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
if (( $(echo "$mem_usage > 90.0" | bc -l) )); then
    mem_status="${RED}❌ Critical ($mem_usage%)${NC}"
    ((resource_issues++))
elif (( $(echo "$mem_usage > 80.0" | bc -l) )); then
    mem_status="${YELLOW}⚠️ High ($mem_usage%)${NC}"
else
    mem_status="${GREEN}✅ OK ($mem_usage%)${NC}"
fi
echo -e "Memory Usage   : $mem_status"

# Disk usage
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [[ $disk_usage -gt 90 ]]; then
    disk_status="${RED}❌ Critical ($disk_usage%)${NC}"
    ((resource_issues++))
elif [[ $disk_usage -gt 80 ]]; then
    disk_status="${YELLOW}⚠️ High ($disk_usage%)${NC}"
else
    disk_status="${GREEN}✅ OK ($disk_usage%)${NC}"
fi
echo -e "Disk Usage     : $disk_status"

# Load average
load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
cpu_cores=$(nproc)
if (( $(echo "$load_avg > $cpu_cores" | bc -l) )); then
    load_status="${YELLOW}⚠️ High ($load_avg)${NC}"
    ((resource_issues++))
else
    load_status="${GREEN}✅ OK ($load_avg)${NC}"
fi
echo -e "Load Average   : $load_status"

echo ""

# 5. Security Check
echo -e "${CYAN}🔒 SECURITY CHECK${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

security_issues=0

# Check for security updates
if command -v apt &> /dev/null; then
    security_updates=$(apt list --upgradable 2>/dev/null | grep -c security || echo "0")
    if [[ $security_updates -gt 0 ]]; then
        echo -e "Security Updates: ${YELLOW}⚠️ $security_updates available${NC}"
        ((security_issues++))
    else
        echo -e "Security Updates: ${GREEN}✅ Up to date${NC}"
    fi
fi

# Check SSH configuration
if [[ -f /etc/ssh/sshd_config ]]; then
    if grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
        echo -e "SSH Root Login  : ${YELLOW}⚠️ Enabled${NC}"
        ((security_issues++))
    else
        echo -e "SSH Root Login  : ${GREEN}✅ Restricted${NC}"
    fi
fi

# Check firewall status
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        echo -e "Firewall       : ${GREEN}✅ Active${NC}"
    else
        echo -e "Firewall       : ${YELLOW}⚠️ Inactive${NC}"
        ((security_issues++))
    fi
elif command -v iptables &> /dev/null; then
    rules_count=$(iptables -L | grep -c "^ACCEPT\|^DROP\|^REJECT")
    if [[ $rules_count -gt 3 ]]; then
        echo -e "Firewall       : ${GREEN}✅ Active (iptables)${NC}"
    else
        echo -e "Firewall       : ${YELLOW}⚠️ Basic rules${NC}"
    fi
fi

echo ""

# 6. Performance Metrics
echo -e "${CYAN}⚡ PERFORMANCE METRICS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Connection counts
if command -v ss &> /dev/null; then
    connections=$(ss -tuln | wc -l)
    echo -e "Active Connections: $connections"
    
    # XRAY connections (if running)
    if systemctl is-active --quiet xray; then
        xray_connections=$(ss -tuln | grep -E ":443|:80" | wc -l)
        echo -e "XRAY Ports     : $xray_connections listening"
    fi
fi

# System uptime
uptime_info=$(uptime -p)
echo -e "System Uptime  : $uptime_info"

echo ""

# 7. Summary
echo -e "${CYAN}📋 HEALTH CHECK SUMMARY${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

total_issues=$((service_issues + port_issues + file_issues + resource_issues + security_issues))

if [[ $total_issues -eq 0 ]]; then
    echo -e "${GREEN}✅ EXCELLENT - No issues detected!${NC}"
    overall_status="${GREEN}HEALTHY${NC}"
elif [[ $total_issues -le 3 ]]; then
    echo -e "${YELLOW}⚠️ GOOD - Minor issues detected ($total_issues)${NC}"
    overall_status="${YELLOW}STABLE${NC}"
else
    echo -e "${RED}❌ ATTENTION NEEDED - Multiple issues detected ($total_issues)${NC}"
    overall_status="${RED}NEEDS ATTENTION${NC}"
fi

echo ""
echo "Service Issues    : $service_issues"
echo "Port Issues       : $port_issues"
echo "File Issues       : $file_issues"
echo "Resource Issues   : $resource_issues"
echo "Security Issues   : $security_issues"
echo ""
echo -e "Overall Status    : $overall_status"

# 8. Recommendations
if [[ $total_issues -gt 0 ]]; then
    echo ""
    echo -e "${CYAN}💡 RECOMMENDATIONS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $service_issues -gt 0 ]]; then
        echo "• Restart failed services: systemctl restart <service>"
    fi
    
    if [[ $port_issues -gt 0 ]]; then
        echo "• Check service configurations and restart"
    fi
    
    if [[ $file_issues -gt 0 ]]; then
        echo "• Restore missing files or fix permissions"
    fi
    
    if [[ $resource_issues -gt 0 ]]; then
        echo "• Monitor resource usage and optimize if needed"
    fi
    
    if [[ $security_issues -gt 0 ]]; then
        echo "• Apply security updates and review configurations"
    fi
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Health check completed at $(date)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Generate simple status code for automation
exit $total_issues