#!/bin/bash
# 每日天氣報告腳本 - 早上07:30執行
# 自動獲取多個分區（黃大仙、九龍灣、深水埗、觀塘）天氣並發送到「嫲嫲煩煩」群組

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/home/jasonckfan/.openclaw/workspace/logs/daily-weather.log"
GROUP_ID="85293429396-1481686102@g.us"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 開始執行每日多區天氣報告" >> "$LOG_FILE"

# 執行 Python 腳本生成報告
message=$(python3 "$SCRIPT_DIR/get-multi-district-weather.py")

if [ -z "$message" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 獲取天氣報告失敗（輸出為空）" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 準備發送天氣報告到群組 $GROUP_ID" >> "$LOG_FILE"

# 使用 OpenClaw CLI 發送
/home/jasonckfan/.local/bin/openclaw message send --channel whatsapp --target "$GROUP_ID" --message "$message" 2>&1 >> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 天氣報告發送成功" >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 天氣報告發送失敗" >> "$LOG_FILE"
fi

echo "---" >> "$LOG_FILE"