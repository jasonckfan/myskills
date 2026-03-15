# OpenClaw 便捷 Alias 設定
# 創建日期: 2026-03-15
# 用途: 方便執行時間驗證、Vision 啟動等常用操作
# 使用方法: source ~/.openclaw/workspace/scripts/openclaw-aliases.sh

# ===========================================
# 時間驗證相關 Alias
# ===========================================
alias check-time='~/.openclaw/workspace/scripts/time-validator.sh'
alias time-now='TZ="Asia/Hong_Kong" date "+%Y-%m-%d %H:%M:%S %A (%Z)"'
alias hour-now='TZ="Asia/Hong_Kong" date +%H'

# ===========================================
# OpenClaw Vision 相關 Alias
# ===========================================
alias openclaw-vision='~/.openclaw/workspace/scripts/start-vision-session.sh'
alias oc-vision='openclaw-vision'

# ===========================================
# 定期檢查相關 Alias
# ===========================================
alias check-logs='tail -50 ~/.openclaw/workspace/logs/daily-tasks.log 2>/dev/null || echo "無日誌記錄"'
alias check-cron='crontab -l | grep -E "(openclaw|weather|daily|time-check)"'
alias check-time-errors='grep -i "error\|錯誤\|夜晚\|illegal" ~/.openclaw/workspace/logs/daily-tasks.log 2>/dev/null | tail -20'
alias check-time-log='tail -30 ~/.openclaw/workspace/logs/time-check.log 2>/dev/null || echo "無時間檢查日誌"'

# ===========================================
# 快速驗證指令
# ===========================================
alias can-send='check-time && echo "✅ 可以發送訊息" || echo "❌ 禁止發送"'
alias is-night='HOUR=$(TZ="Asia/Hong_Kong" date +%H); if [ "$HOUR" -ge 22 ] || [ "$HOUR" -lt 8 ]; then echo "🌙 係夜晚時段 (22:00-08:00)，禁止發送"; else echo "☀️ 非夜晚時段"; fi'

# ===========================================
# OpenClaw 常用指令
# ===========================================
alias oc-status='openclaw status'
alias oc-logs='openclaw logs'
alias oc-config='cat ~/.openclaw/config.json 2>/dev/null || echo "使用 openclaw config get <key>"'

# ===========================================
# 記憶檢查相關
# ===========================================
alias check-memory='ls -la ~/.openclaw/workspace/memory/*.md 2>/dev/null | tail -10'
alias today-memory='cat ~/.openclaw/workspace/memory/$(TZ="Asia/Hong_Kong" date +%Y-%m-%d).md 2>/dev/null || echo "今日暫無記錄"'

# ===========================================
# 定期檢查執行
# ===========================================
alias run-time-check='~/.openclaw/workspace/scripts/regular-time-check.sh'
alias setup-time-cron='~/.openclaw/workspace/scripts/setup-time-check-cron.sh'

echo "✅ OpenClaw alias 已載入"
echo "可用指令:"
echo "  時間: check-time, time-now, can-send, is-night"
echo "  Vision: openclaw-vision, oc-vision"
echo "  檢查: check-logs, check-cron, check-time-log, check-time-errors"
echo "  OpenClaw: oc-status, oc-logs"
