#!/bin/bash
# Log Cleanup & Rotation - AutoScript ZNAND Security Enhancement
# Script untuk membersihkan dan merotasi log files

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

# Configuration
MAX_LOG_SIZE=10485760  # 10MB in bytes
MAX_LOG_AGE=7          # Days
BACKUP_COUNT=5         # Number of rotated logs to keep

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}          🧹 LOG CLEANUP & ROTATION           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to rotate log file
rotate_log() {
    local logfile="$1"
    local basename="$logfile"
    
    if [[ ! -f "$logfile" ]]; then
        return 0
    fi
    
    local size=$(stat -c%s "$logfile" 2>/dev/null || echo "0")
    
    if [[ $size -gt $MAX_LOG_SIZE ]]; then
        info "Rotating $logfile (Size: $(($size/1024/1024))MB)"
        
        # Shift existing rotated logs
        for i in $(seq $((BACKUP_COUNT-1)) -1 1); do
            if [[ -f "${basename}.${i}" ]]; then
                mv "${basename}.${i}" "${basename}.$((i+1))"
            fi
        done
        
        # Compress and move current log
        if command -v gzip &> /dev/null; then
            gzip -c "$logfile" > "${basename}.1.gz" 2>/dev/null
        else
            cp "$logfile" "${basename}.1"
        fi
        
        # Truncate current log
        truncate -s 0 "$logfile"
        
        # Remove old backups
        for i in $(seq $((BACKUP_COUNT+1)) 10); do
            rm -f "${basename}.${i}" "${basename}.${i}.gz" 2>/dev/null
        done
        
        info "✅ Rotated $logfile"
        return 1
    fi
    
    return 0
}

# Function to clean old logs
clean_old_logs() {
    local log_dir="$1"
    
    if [[ ! -d "$log_dir" ]]; then
        return 0
    fi
    
    info "Cleaning old logs in $log_dir..."
    
    # Find and delete old log files
    find "$log_dir" -name "*.log*" -type f -mtime +$MAX_LOG_AGE -exec rm -f {} \; 2>/dev/null
    find "$log_dir" -name "*.gz" -type f -mtime +$MAX_LOG_AGE -exec rm -f {} \; 2>/dev/null
    
    # Count remaining files
    local remaining=$(find "$log_dir" -name "*.log*" -o -name "*.gz" | wc -l)
    info "✅ $remaining log files remaining in $log_dir"
}

# Log files to process
declare -a LOG_FILES=(
    "/var/log/xray/access.log"
    "/var/log/xray/error.log"
    "/var/log/sshws.log"
    "/var/log/auth.log"
    "/var/log/syslog"
    "/var/log/daemon.log"
    "/var/log/kern.log"
)

# Log directories to clean
declare -a LOG_DIRS=(
    "/var/log"
    "/var/log/xray"
    "/tmp"
)

# Start cleanup process
info "🔍 Starting log cleanup process..."
echo ""

rotated_count=0
cleaned_dirs=0

# Process individual log files
echo -e "${CYAN}📄 Processing Log Files${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for logfile in "${LOG_FILES[@]}"; do
    if [[ -f "$logfile" ]]; then
        if rotate_log "$logfile"; then
            ((rotated_count++))
        fi
    else
        warn "Log file not found: $logfile"
    fi
done

echo ""

# Clean old logs in directories
echo -e "${CYAN}📁 Cleaning Log Directories${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for log_dir in "${LOG_DIRS[@]}"; do
    clean_old_logs "$log_dir"
    ((cleaned_dirs++))
done

echo ""

# Clean system temporary files
echo -e "${CYAN}🗑️ Cleaning Temporary Files${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Clean temp directories
temp_cleaned=0

if [[ -d "/tmp" ]]; then
    find /tmp -type f -atime +1 -delete 2>/dev/null
    ((temp_cleaned++))
    info "✅ Cleaned /tmp"
fi

# Clean apt cache
if command -v apt-get &> /dev/null; then
    apt-get clean &>/dev/null
    info "✅ Cleaned APT cache"
    ((temp_cleaned++))
fi

# Clean journal logs if systemd
if command -v journalctl &> /dev/null; then
    journalctl --vacuum-time=7d &>/dev/null
    info "✅ Cleaned systemd journal (kept 7 days)"
    ((temp_cleaned++))
fi

echo ""

# Disk space analysis
echo -e "${CYAN}💾 Disk Space Analysis${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Before and after disk usage
disk_usage_root=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
disk_free_root=$(df -h / | tail -1 | awk '{print $4}')

echo "Root filesystem: ${disk_usage_root}% used, ${disk_free_root} free"

# Log directory sizes
if [[ -d "/var/log" ]]; then
    log_size=$(du -sh /var/log 2>/dev/null | awk '{print $1}')
    echo "Log directory size: $log_size"
fi

echo ""

# Summary
echo -e "${CYAN}📋 CLEANUP SUMMARY${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Log files rotated    : $rotated_count"
echo "Directories cleaned  : $cleaned_dirs"
echo "Temp files cleaned   : $temp_cleaned"
echo ""

if [[ $rotated_count -gt 0 ]] || [[ $temp_cleaned -gt 0 ]]; then
    echo -e "${GREEN}✅ Cleanup completed successfully!${NC}"
else
    echo -e "${YELLOW}ℹ️ No cleanup needed at this time${NC}"
fi

# Create logrotate configuration if not exists
if command -v logrotate &> /dev/null && [[ ! -f "/etc/logrotate.d/autoscript-znand" ]]; then
    info "📝 Creating logrotate configuration..."
    
    cat > /etc/logrotate.d/autoscript-znand << 'EOF'
# AutoScript ZNAND Log Rotation Configuration

/var/log/xray/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
    postrotate
        systemctl reload xray &>/dev/null || true
    endscript
}

/var/log/sshws.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
    postrotate
        systemctl reload sshws &>/dev/null || true
    endscript
}
EOF
    
    info "✅ Logrotate configuration created"
fi

# Setup automatic cleanup (cron job)
if command -v crontab &> /dev/null; then
    # Check if our cron job already exists
    if ! crontab -l 2>/dev/null | grep -q "log-cleanup.sh"; then
        # Add daily cleanup at 2 AM
        (crontab -l 2>/dev/null; echo "0 2 * * * /bin/bash $(pwd)/tools/log-cleanup.sh >/dev/null 2>&1") | crontab -
        info "✅ Added automatic daily cleanup to crontab"
    fi
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Log cleanup completed at $(date)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"