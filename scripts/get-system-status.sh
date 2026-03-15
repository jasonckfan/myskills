#!/bin/bash
# 動態獲取系統狀態腳本

# 主機信息 (實際獲取)
HOSTNAME=$(hostname)
CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | sed 's/^ *//')
HOST_INFO="$HOSTNAME ($CPU_MODEL)"

# 模型信息 (從 openclaw.json 獲取)
MODEL_INFO="kimi-k2.5 (256k ctx)"

# 記憶體使用
MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
MEM_USED=$(free -m | grep Mem | awk '{print $3}')
MEM_GB=$(echo "scale=1; $MEM_USED/1024" | bc)
MEM_TOTAL_GB=$(echo "scale=1; $MEM_TOTAL/1024" | bc)
MEM_PCT=$(free | grep Mem | awk '{printf "%.0f", $3/$2*100}')

# 儲存使用
DISK_USED=$(df -h / | tail -1 | awk '{print $3}' | sed 's/G//')
DISK_TOTAL=$(df -h / | tail -1 | awk '{print $2}' | sed 's/G//')
DISK_PCT=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')

# 運行時間
UPTIME=$(uptime | grep -oP 'up \K[^,]+' | sed 's/ //g')

# Gateway 狀態
GATEWAY_PID=$(openclaw status 2>/dev/null | grep -oP 'pid \K[0-9]+' | head -1)
if [ -n "$GATEWAY_PID" ]; then
    GATEWAY_STATUS="運行中 (pid $GATEWAY_PID)"
else
    GATEWAY_STATUS="未運行"
fi

# Telegram Bot 狀態 (檢查是否有 Telegram 配置)
if [ -f "$HOME/.openclaw/openclaw.json" ] && grep -q "telegram" "$HOME/.openclaw/openclaw.json" 2>/dev/null; then
    TELEGRAM_BOT=$(grep -o '"botToken"[^}]*' "$HOME/.openclaw/openclaw.json" 2>/dev/null | head -1 | grep -o '"[^"]*"' | tail -1 | tr -d '"')
    if [ -n "$TELEGRAM_BOT" ]; then
        TELEGRAM_STATUS="已配置"
    else
        TELEGRAM_STATUS="未配置"
    fi
else
    TELEGRAM_STATUS="未配置"
fi

# 獲取當前使用中的模型 (從 sessions 文件獲取)
SESSIONS_FILE="$HOME/.openclaw/agents/main/sessions/sessions.json"
if [ -f "$SESSIONS_FILE" ]; then
    CURRENT_MODEL=$(grep -o '"model": *"[^"]*"' "$SESSIONS_FILE" 2>/dev/null | tail -1 | sed 's/.*"model": *"\([^"]*\)".*/\1/' || echo "kimi-k2.5")
else
    CURRENT_MODEL="kimi-k2.5"
fi

# 輸出格式 (簡潔版)
echo ""
echo "───"
echo ""
echo "• 🤖 模型: $CURRENT_MODEL"
echo "• 💾 記憶體: ${MEM_GB}Gi / ${MEM_TOTAL_GB}Gi (${MEM_PCT}%)"
echo "• 🗄️ 儲存: ${DISK_USED}G / ${DISK_TOTAL} (${DISK_PCT}%)"
echo "• ⏱️ 運行時間: $UPTIME"
echo "• 🔌 Gateway: $GATEWAY_STATUS"
echo ""
echo "───"
