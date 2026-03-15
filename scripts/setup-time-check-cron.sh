#!/bin/bash
# 設置定期檢查 Cron Job
# 創建日期: 2026-03-15

echo "🕐 正在設置時間準確性定期檢查..."

# 檢查腳本路徑
CHECK_SCRIPT="$HOME/.openclaw/workspace/scripts/regular-time-check.sh"

if [ ! -f "$CHECK_SCRIPT" ]; then
    echo "❌ 錯誤: 檢查腳本不存在: $CHECK_SCRIPT"
    exit 1
fi

# 設置為可執行
chmod +x "$CHECK_SCRIPT"

# 創建臨時 crontab 文件
TEMP_CRON=$(mktemp)

# 導出現有 crontab
crontab -l 2>/dev/null > "$TEMP_CRON" || true

# 檢查是否已存在相關任務
if grep -q "regular-time-check" "$TEMP_CRON"; then
    echo "⚠️  定期檢查任務已存在，跳過添加"
else
    # 添加新的定時任務
    echo "" >> "$TEMP_CRON"
    echo "# OpenClaw 時間準確性定期檢查 (每小時運行)" >> "$TEMP_CRON"
    echo "0 * * * * $CHECK_SCRIPT >> $HOME/.openclaw/workspace/logs/cron.log 2>&1" >> "$TEMP_CRON"
    
    # 安裝新的 crontab
    crontab "$TEMP_CRON"
    echo "✅ 已添加每小時時間檢查任務"
fi

# 清理臨時文件
rm -f "$TEMP_CRON"

# 顯示當前 crontab
echo ""
echo "📋 當前定時任務:"
crontab -l | grep -E "(openclaw|time-check)" || echo "   (無相關任務)"

echo ""
echo "✅ 設置完成！"
echo "檢查日誌: ~/.openclaw/workspace/logs/time-check.log"
