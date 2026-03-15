#!/bin/bash
# OpenClaw Network Monitor v5 - Multi-device with custom ports/users

NETWORK="192.168.1"
# Format: OCTET|SSH_USER|GATEWAY_PORT
DEVICES=("250|jasonckfan|18792" "24|jasonckfan|18792" "35|jasonckfan|18792" "241|jasonckfan|18792" "44|jasonfan|18789")
SSH_PASS="1209"
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"
LOG_DIR="/home/jasonckfan/.openclaw/logs"
LOG_FILE="$LOG_DIR/monitor.log"
ALERT_LOG="$LOG_DIR/alerts.log"
UPTIME_FILE="$LOG_DIR/uptime_stats.json"
AUTO_FIX=true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
alert() { log "ALERT: $*"; echo "[$(date)] ALERT: $*" >> "$ALERT_LOG"; }

get_ssh_user() { echo "$1" | cut -d'|' -f2; }
get_gateway_port() { echo "$1" | cut -d'|' -f3; }

check_memory() {
    local ip=$1
    local user=$2
    # Try Linux first
    local mem=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
        "free -m 2>/dev/null | grep Mem | awk '{printf \"%.0f\", \$3/\$2*100}'" 2>/dev/null)
    
    if [ -z "$mem" ] || [[ ! "$mem" =~ ^[0-9]+$ ]]; then
        # Mac - use top
        mem=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
            "top -l 1 -n 0 2>/dev/null | grep 'PhysMem:' | awk '{gsub(/[a-zA-Z]/,\"\",\$2); gsub(/G/,\"000\",\$2); print \$2}'" 2>/dev/null)
    fi
    
    if [ -n "$mem" ] && [[ "$mem" =~ ^[0-9]+$ ]]; then
        [ "$mem" -gt 85 ] && { alert "Memory HIGH on $ip: $mem%"; auto_cleanup "$ip" "$user"; }
        [ "$mem" -gt 80 ] && echo -e "${YELLOW}${mem}%${NC}" || echo -e "${GREEN}${mem}%${NC}"
    else
        echo -e "${GREEN}?${NC}"
    fi
}

check_disk() {
    local ip=$1
    local user=$2
    # Try Linux first
    local disk=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
        "df -h / 2>/dev/null | tail -1 | awk '{print \$5}' | tr -d '%'" 2>/dev/null)
    
    if [ -z "$disk" ]; then
        # Mac
        disk=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
            "df -h / 2>/dev/null | tail -1 | awk '{print \$5}' | tr -d '%'" 2>/dev/null)
    fi
    
    [ -n "$disk" ] && [ "$disk" -gt 90 ] && { echo -e "${RED}${disk}%${NC}"; alert "Disk critical on $ip"; } || echo -e "${GREEN}${disk}%${NC}"
}

check_gateway() {
    local ip=$1
    local user=$2
    local port=$3
    local result=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
        "curl -s --connect-timeout 3 http://127.0.0.1:${port}/ 2>/dev/null" 2>/dev/null)
    
    [ -n "$result" ] && echo -e "${GREEN}ONLINE${NC}" || { echo -e "${RED}OFFLINE${NC}"; return 1; }
}

check_process() {
    local ip=$1
    local user=$2
    local proc=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
        "ps aux | grep 'openclaw-gateway' | grep -v grep" 2>/dev/null)
    
    [ -n "$proc" ] && echo -e "${GREEN}RUNNING${NC}" || { echo -e "${RED}NOT RUNNING${NC}"; return 1; }
}

check_cron() {
    local ip=$1
    local user=$2
    # Try Linux cron first
    local exec_count=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
        "journalctl -u cron --no-pager --since '1 hour ago' 2>/dev/null | grep -c CMD" 2>/dev/null)
    
    if [ -z "$exec_count" ]; then
        # Mac - check launchd for openclaw
        exec_count=$(sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
            "launchctl list | grep -c openclaw" 2>/dev/null)
        [ -n "$exec_count" ] && [ "$exec_count" -gt 0 ] && echo -e "${GREEN}active${NC}" || echo -e "${YELLOW}none${NC}"
        return
    fi
    
    [ -n "$exec_count" ] && [ "$exec_count" -gt 0 ] && echo -e "${GREEN}${exec_count} execs${NC}" || echo -e "${YELLOW}none${NC}"
}

auto_cleanup() {
    local ip=$1
    local user=$2
    sshpass -p "$SSH_PASS" ssh $SSH_OPTS ${user}@${ip} \
        "pkill -f 'firefox.*contentproc' 2>/dev/null; pkill -f 'snap-store' 2>/dev/null" 2>/dev/null
}

report() {
    echo ""
    echo "=============================================="
    echo "  OpenClaw Network Monitor v5"
    echo "  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=============================================="
    echo ""
    
    mkdir -p "$LOG_DIR"
    local issues=0
    
    echo -e "${BLUE}=== Gateway ===${NC}"
    for dev in "${DEVICES[@]}"; do
        octet=$(echo "$dev" | cut -d'|' -f1)
        ip="${NETWORK}.${octet}"
        user=$(get_ssh_user "$dev")
        port=$(get_gateway_port "$dev")
        printf "%-18s " ".${octet}"
        check_gateway "$ip" "$user" "$port"
        [ $? -ne 0 ] && ((issues++))
    done
    echo ""
    
    echo -e "${BLUE}=== Process ===${NC}"
    for dev in "${DEVICES[@]}"; do
        octet=$(echo "$dev" | cut -d'|' -f1)
        ip="${NETWORK}.${octet}"
        user=$(get_ssh_user "$dev")
        printf "%-18s " ".${octet}"
        check_process "$ip" "$user"
    done
    echo ""
    
    echo -e "${BLUE}=== Cron ===${NC}"
    for dev in "${DEVICES[@]}"; do
        octet=$(echo "$dev" | cut -d'|' -f1)
        ip="${NETWORK}.${octet}"
        user=$(get_ssh_user "$dev")
        printf "%-18s " ".${octet}"
        check_cron "$ip" "$user"
    done
    echo ""
    
    echo -e "${BLUE}=== Memory ===${NC}"
    for dev in "${DEVICES[@]}"; do
        octet=$(echo "$dev" | cut -d'|' -f1)
        ip="${NETWORK}.${octet}"
        user=$(get_ssh_user "$dev")
        printf "%-18s " ".${octet}"
        check_memory "$ip" "$user"
    done
    echo ""
    
    echo -e "${BLUE}=== Disk ===${NC}"
    for dev in "${DEVICES[@]}"; do
        octet=$(echo "$dev" | cut -d'|' -f1)
        ip="${NETWORK}.${octet}"
        user=$(get_ssh_user "$dev")
        printf "%-18s " ".${octet}"
        check_disk "$ip" "$user"
    done
    echo ""
    
    [ "$issues" -gt 0 ] && echo -e "${YELLOW}⚠️  $issues issue(s)${NC}" || echo -e "${GREEN}✅ All OK${NC}"
    echo ""
}

report | tee -a "$LOG_FILE"
