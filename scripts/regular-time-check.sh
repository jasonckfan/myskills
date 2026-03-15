#!/bin/bash
# 定期檢查機制 - 確保時間準確性
# 運行頻率: 每小時 (由 cron 觸發)
# 創建日期: 2026-03-15

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.openclaw/workspace/logs/time-check.log"
ALERT_LOG="$HOME/.openclaw/workspace/logs/time-alerts.log"

# 確保日誌目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

# 獲取當前時間
DATE_HKT=$(TZ="Asia/Hong_Kong" date "+%Y-%m-%d")
TIME_HKT=$(TZ="Asia/Hong_Kong" date "+%H:%M:%S")
HOUR_HKT=$(TZ="Asia/Hong_Kong" date +%H)

echo "========================================" >> "$LOG_FILE"
echo "檢查時間: $DATE_HKT $TIME_HKT" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 檢查 1: 驗證時間格式正確
if ! [[ "$HOUR_HKT" =~ ^[0-9]+$ ]]; then
    echo "❌ 錯誤: 時間格式異常 (HOUR=$HOUR_HKT)" | tee -a "$LOG_FILE" "$ALERT_LOG"
    exit 1
fi

# 檢查 2: 驗證是否係合法時間範圍 (0-23)
if [ "$HOUR_HKT" -lt 0 ] || [ "$HOUR_HKT" -gt 23 ]; then
    echo "❌ 錯誤: 小時數超出範圍 ($HOUR_HKT)" | tee -a "$LOG_FILE" "$ALERT_LOG"
    exit 1
fi

echo "✅ 時間格式驗證通過" >> "$LOG_FILE"

# 檢查 3: 檢查是否有錯誤發送記錄
if [ -f "$HOME/.openclaw/workspace/logs/daily-tasks.log" ]; then
    ERRORS=$(grep -i "error\|錯誤\|illegal\|夜晚" "$HOME/.openclaw/workspace/logs/daily-tasks.log" 2>/dev/null | tail -5 || true)
    if [ -n "$ERRORS" ]; then
        echo "⚠️  發現近期錯誤記錄:" >> "$LOG_FILE"
        echo "$ERRORS" >> "$LOG_FILE"
    else
        echo "✅ 無近期錯誤記錄" >> "$LOG_FILE"
    fi
fi

# 檢查 4: 檢查 cron job 設定
echo "📋 當前定時任務:" >> "$LOG_FILE"
crontab -l 2>/dev/null | grep -E "(openclaw|weather|daily|time-check)" >> "$LOG_FILE" || echo "   (無相關定時任務)" >> "$LOG_FILE"

# 檢查 5: 驗證時間驗證腳本存在且可執行
if [ -x "$SCRIPT_DIR/time-validator.sh" ]; then
    echo "✅ time-validator.sh 可用" >> "$LOG_FILE"
else
    echo "⚠️  time-validator.sh 不存在或不可執行" | tee -a "$LOG_FILE" "$ALERT_LOG"
fi

# 檢查 6: 如果是 07:30，提醒可以發送嫲嫲煩煩第一條訊息
if [ "$HOUR_HKT" -eq 7 ] && [ "$(TZ="Asia/Hong_Kong" date +%M)" -ge 30 ]; then
    echo "🌅 07:30 已到達，嫲嫲煩煩群組可以開始發送訊息" >> "$LOG_FILE"
fi

# 檢查 7: 如果是 22:00，提醒進入夜晚禁止時段
if [ "$HOUR_HKT" -eq 22 ]; then
    echo "🌙 22:00 已到達，進入夜晚禁止發送時段" >> "$LOG_FILE"
fi

echo "✅ 定期檢查完成" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 保留最近 1000 行日誌
tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE" 2>/dev/null || true
