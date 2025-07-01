#!/bin/bash
# XRAY Utility Functions untuk Error Handling
# AutoScript ZNAND - Security Enhancement

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error handling functions
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Safe restart XRAY service with error handling
restart_xray_safe() {
    local backup_config="${1:-/etc/xray/config.json.backup}"
    
    info "Restarting XRAY service..."
    
    if ! systemctl restart xray; then
        error "Gagal restart xray service!"
        
        # Try to restore backup if provided and exists
        if [[ -f "$backup_config" ]]; then
            warn "Restoring backup configuration..."
            cp "$backup_config" /etc/xray/config.json
            
            if systemctl restart xray; then
                info "Backup configuration restored successfully"
            else
                error "Failed to restore backup configuration"
            fi
        fi
        
        return 1
    fi
    
    # Health check
    sleep 2
    if ! systemctl is-active --quiet xray; then
        error "Service xray tidak running setelah restart!"
        return 1
    fi
    
    info "XRAY service restarted successfully"
    return 0
}

# Safe restart WireGuard service with error handling
restart_wireguard_safe() {
    info "Restarting WireGuard service..."
    
    if ! systemctl restart wg-quick@wg0; then
        error "Gagal restart WireGuard service!"
        return 1
    fi
    
    # Health check
    sleep 2
    if ! systemctl is-active --quiet wg-quick@wg0; then
        error "Service WireGuard tidak running setelah restart!"
        return 1
    fi
    
    info "WireGuard service restarted successfully"
    return 0
}

# Safe restart SSH WebSocket service
restart_sshws_safe() {
    info "Restarting SSH WebSocket service..."
    
    if ! systemctl restart sshws; then
        error "Gagal restart SSH WebSocket service!"
        return 1
    fi
    
    # Health check
    sleep 2
    if ! systemctl is-active --quiet sshws; then
        error "Service SSH WebSocket tidak running setelah restart!"
        return 1
    fi
    
    info "SSH WebSocket service restarted successfully"
    return 0
}

# Validate JSON configuration
validate_xray_config() {
    local config_file="${1:-/etc/xray/config.json}"
    
    if ! jq empty "$config_file" 2>/dev/null; then
        error "Config JSON tidak valid: $config_file"
        return 1
    fi
    
    info "Config JSON valid: $config_file"
    return 0
}

# Backup XRAY configuration
backup_xray_config() {
    local backup_suffix="${1:-$(date +%s)}"
    local backup_file="/etc/xray/config.json.backup.$backup_suffix"
    
    if cp /etc/xray/config.json "$backup_file"; then
        info "Config backup created: $backup_file"
        echo "$backup_file"
        return 0
    else
        error "Failed to create config backup"
        return 1
    fi
}

# Restore XRAY configuration from backup
restore_xray_config() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    if ! validate_xray_config "$backup_file"; then
        error "Backup config is invalid"
        return 1
    fi
    
    if cp "$backup_file" /etc/xray/config.json; then
        info "Config restored from: $backup_file"
        return 0
    else
        error "Failed to restore config"
        return 1
    fi
}

# Check if user exists in XRAY config
xray_user_exists() {
    local username="$1"
    local config_file="${2:-/etc/xray/config.json}"
    
    if grep -q "\"email\": \"$username\"" "$config_file"; then
        return 0  # User exists
    else
        return 1  # User not found
    fi
}

# Get service status with color coding
get_service_status() {
    local service_name="$1"
    
    if systemctl is-active --quiet "$service_name"; then
        echo -e "${GREEN}✅ Running${NC}"
    elif systemctl is-enabled --quiet "$service_name"; then
        echo -e "${YELLOW}⚠️ Stopped${NC}"
    else
        echo -e "${RED}❌ Disabled${NC}"
    fi
}

# Usage examples (uncomment untuk testing):
# restart_xray_safe
# validate_xray_config
# backup_file=$(backup_xray_config)
# echo "Backup created: $backup_file"