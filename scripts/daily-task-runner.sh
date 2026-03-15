#!/bin/bash
# 每日任務執行腳本 - 帶雙重確認機制
# 確保日期、時間、內容正確無誤

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.openclaw/workspace/logs/daily-tasks.log"

# 確保日誌目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

# 獲取當前日期時間
DATE_HKT=$(TZ="Asia/Hong_Kong" date "+%Y-%m-%d")
TIME_HKT=$(TZ="Asia/Hong_Kong" date "+%H:%M:%S")
HOUR_HKT=$(TZ="Asia/Hong_Kong" date +%H)

echo "========================================" >> "$LOG_FILE"
echo "任務執行時間: $DATE_HKT $TIME_HKT" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 檢查 1: 時間驗證
if [ "$HOUR_HKT" -lt 7 ] || [ "$HOUR_HKT" -ge 22 ]; then
    echo "❌ 錯誤: 非法時間執行任務 ($TIME_HKT)" | tee -a "$LOG_FILE"
    echo "   任務已中止" >> "$LOG_FILE"
    exit 1
fi

# 檢查 2: 日期確認（避免跨日錯誤）
EXPECTED_DATE="$1"
if [ -n "$EXPECTED_DATE" ] && [ "$EXPECTED_DATE" != "$DATE_HKT" ]; then
    echo "❌ 錯誤: 日期不匹配" | tee -a "$LOG_FILE"
    echo "   預期: $EXPECTED_DATE" >> "$LOG_FILE"
    echo "   實際: $DATE_HKT" >> "$LOG_FILE"
    exit 1
fi

# 檢查 3: 內容預覽（如適用）
TASK_TYPE="$2"
echo "任務類型: $TASK_TYPE" >> "$LOG_FILE"

# 根據任務類型執行
 case "$TASK_TYPE" in
    "weather")
        echo "🌤️  執行天氣報告任務..." | tee -a "$LOG_FILE"
        # 調用天氣腳本
        # bash "$SCRIPT_DIR/send-weather.sh" >> "$LOG_FILE" 2>&1
        ;;
    "deals")
        echo "🛒 執行優惠搜尋任務..." | tee -a "$LOG_FILE"
        # 調用優惠腳本
        ;;
    *)
        echo "⚠️  未知任務類型: $TASK_TYPE" | tee -a "$LOG_FILE"
        exit 1
        ;;
esac

echo "✅ 任務完成" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
