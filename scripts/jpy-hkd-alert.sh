#!/bin/bash
# JPY/HKD 匯率監控與自動通知腳本
# 當 1 日圓兌港元低於 0.05 時自動發送 WhatsApp 通知

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$WORKSPACE_DIR/logs/jpy-hkd-alert.log"
LOCK_FILE="/tmp/jpy-hkd-alert.lock"
THRESHOLD=0.05
TARGET_GROUP="85293429396-1481686102@g.us"

# 確保日誌目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

# 防止重複運行
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        echo "$(date): 腳本已在運行中 (PID: $PID)" >> "$LOG_FILE"
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"

# 清理 lock 文件的函數
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# 記錄開始
echo "$(date '+%Y-%m-%d %H:%M:%S'): 開始檢查 JPY/HKD 匯率..." >> "$LOG_FILE"

# 使用 exchangerate-api 免費 API
API_URL="https://api.exchangerate-api.com/v4/latest/JPY"

# 獲取匯率數據
RESPONSE=$(curl -s --max-time 30 "$API_URL" 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ❌ 無法獲取匯率數據" >> "$LOG_FILE"
    exit 1
fi

# 提取 HKD 匯率
RATE=$(echo "$RESPONSE" | grep -o '"HKD":[0-9.]*' | cut -d':' -f2)

if [ -z "$RATE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ❌ 無法解析匯率數據" >> "$LOG_FILE"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S'): 當前匯率: 1 JPY = $RATE HKD" >> "$LOG_FILE"

# 檢查是否已經發送過今日通知
TODAY=$(date +%Y%m%d)
NOTIFICATION_SENT_FILE="$WORKSPACE_DIR/data/jpy-hkd-notified-$TODAY"

# 比較匯率
if (( $(echo "$RATE < $THRESHOLD" | bc -l) )); then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ✅ 匯率 ($RATE) 低於 $THRESHOLD" >> "$LOG_FILE"
    
    # 檢查今日是否已發送過通知
    if [ -f "$NOTIFICATION_SENT_FILE" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): ⏳ 今日已發送過通知，跳過" >> "$LOG_FILE"
        exit 0
    fi
    
    # 發送 WhatsApp 通知
    MESSAGE="🇯🇵💰 日圓匯率提醒！

📊 當前匯率：1 日圓 = $RATE 港元
🎯 已低於 0.05 的目標價！

✅ 現在是兌換日圓的好時機！

💡 小提示：
• 匯率持續波動，建議分批兌換
• 留意銀行/找換店的手續費
• 如有日本旅行計劃，可考慮提前準備

⏰ 檢查時間：$(date '+%Y-%m-%d %H:%M')"

    # 使用 openclaw 發送消息
    cd "$WORKSPACE_DIR"
    if /usr/bin/openclaw message send --channel whatsapp --target "$TARGET_GROUP" --message "$MESSAGE" >> "$LOG_FILE" 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): ✅ WhatsApp 通知發送成功" >> "$LOG_FILE"
        # 記錄今日已發送
        mkdir -p "$WORKSPACE_DIR/data"
        touch "$NOTIFICATION_SENT_FILE"
        # 清理舊的通知記錄文件（保留最近7天）
        find "$WORKSPACE_DIR/data" -name "jpy-hkd-notified-*" -mtime +7 -delete 2>/dev/null || true
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): ❌ WhatsApp 通知發送失敗" >> "$LOG_FILE"
        exit 1
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ⏳ 匯率 ($RATE) 高於閾值 ($THRESHOLD)，暫不通知" >> "$LOG_FILE"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S'): 檢查完成" >> "$LOG_FILE"
exit 0
