#!/bin/bash
# 設置每日 NAS 備份 Cron Job
# 用途: 每日 00:00 自動運行完整備份

CRON_JOB="0 0 * * * $HOME/.openclaw/workspace/scripts/daily-nas-backup.sh >> $HOME/.openclaw/workspace/logs/backup-cron.log 2>&1"

echo "🕛 設置每日 NAS 備份 Cron Job"
echo "=============================="
echo ""

# 檢查是否已存在
if crontab -l 2>/dev/null | grep -q "daily-nas-backup.sh"; then
    echo "⚠️  Cron job 已存在"
    echo ""
    echo "當前設定:"
    crontab -l | grep "daily-nas-backup.sh"
    echo ""
    read -p "是否重新設置? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏭️  保持現有設定"
        exit 0
    fi
    # 刪除舊的
    crontab -l 2>/dev/null | grep -v "daily-nas-backup.sh" | crontab -
fi

# 確保日志目錄存在
mkdir -p "$HOME/.openclaw/workspace/logs"

# 添加新的 cron job
(crontab -l 2>/dev/null || echo "") | grep -v "daily-nas-backup.sh" | { cat; echo "$CRON_JOB"; } | crontab -

echo "✅ Cron job 已設置"
echo ""
echo "備份時間: 每日 00:00"
echo "備份腳本: $HOME/.openclaw/workspace/scripts/daily-nas-backup.sh"
echo "日志文件: $HOME/.openclaw/workspace/logs/backup-cron.log"
echo ""
echo "查看所有 cron jobs:"
echo "  crontab -l"
echo ""
echo "手動測試備份:"
echo "  $HOME/.openclaw/workspace/scripts/daily-nas-backup.sh"
echo ""
