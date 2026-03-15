#!/bin/bash
# OpenClaw 設定每日自動備份到 GitHub
# 執行時間: 每天 00:00

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="/home/jasonckfan/.openclaw/workspace"
BACKUP_DIR="/tmp/openclaw-backup-$(date +%Y%m%d)"
LOG_FILE="/home/jasonckfan/.openclaw/workspace/logs/github-backup.log"
GITHUB_REPO="https://github.com/jasonckfan/myskills.git"
GITHUB_TOKEN="${GITHUB_PAT:-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}"

# 記錄開始
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 開始每日 GitHub 備份" >> "$LOG_FILE"

# 清理舊備份目錄
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# 1. 複製核心設定檔
cp "$WORKSPACE_DIR/AGENTS.md" "$BACKUP_DIR/" 2>/dev/null || true
cp "$WORKSPACE_DIR/SOUL.md" "$BACKUP_DIR/" 2>/dev/null || true
cp "$WORKSPACE_DIR/MEMORY.md" "$BACKUP_DIR/" 2>/dev/null || true
cp "$WORKSPACE_DIR/USER.md" "$BACKUP_DIR/" 2>/dev/null || true
cp "$WORKSPACE_DIR/TOOLS.md" "$BACKUP_DIR/" 2>/dev/null || true
cp "$WORKSPACE_DIR/HEARTBEAT.md" "$BACKUP_DIR/" 2>/dev/null || true
cp "$WORKSPACE_DIR/IDENTITY.md" "$BACKUP_DIR/" 2>/dev/null || true

# 2. 建立目錄結構
mkdir -p "$BACKUP_DIR/config" "$BACKUP_DIR/cron" "$BACKUP_DIR/scripts" "$BACKUP_DIR/memory" "$BACKUP_DIR/skills"

# 3. 備份 Cron 任務
crontab -l > "$BACKUP_DIR/cron/crontab.txt" 2>/dev/null || echo "# No crontab" > "$BACKUP_DIR/cron/crontab.txt"

# 4. 備份腳本
cp -r "$WORKSPACE_DIR/scripts/"* "$BACKUP_DIR/scripts/" 2>/dev/null || true

# 5. 備份近期記憶 (最近 30 天)
find "$WORKSPACE_DIR/memory" -name "*.md" -mtime -30 -exec cp {} "$BACKUP_DIR/memory/" \; 2>/dev/null || true

# 6. 建立 Skills 清單
cat > "$BACKUP_DIR/skills/README.md" << EOF
# OpenClaw Skills 清單

## 已安裝 Skills

| Skill 名稱 | 安裝日期 | 功能描述 |
|:---|:---|:---|
EOF

ls -1 "$WORKSPACE_DIR/skills/" | while read skill; do
    if [ -d "$WORKSPACE_DIR/skills/$skill" ]; then
        skill_date=$(stat -c %y "$WORKSPACE_DIR/skills/$skill" 2>/dev/null | cut -d' ' -f1 || echo "未知")
        echo "| $skill | $skill_date | (詳見 SKILL.md) |" >> "$BACKUP_DIR/skills/README.md"
    fi
done

# 7. 建立 README
cat > "$BACKUP_DIR/README.md" << EOF
# OpenClaw 自動備份

備份日期: $(date '+%Y-%m-%d %H:%M:%S')

## 目錄結構

\`\`\`
.
├── AGENTS.md           # Agent 行為準則
├── SOUL.md             # 核心身份定義
├── MEMORY.md           # 長期記憶
├── USER.md             # 用戶資料
├── TOOLS.md            # 本地工具設定
├── HEARTBEAT.md        # Heartbeat 任務
├── IDENTITY.md         # 身份設定
├── config/             # 配置檔案
├── cron/               # Cron 任務列表
├── skills/             # Skills 清單
├── scripts/            # 自定義腳本
└── memory/             # 近期記憶檔案
\`\`\`

## 注意事項

- \`openclaw.json\` 包含敏感資訊，已從備份中排除
- 此備份由自動化腳本於每日 00:00 執行
- 完整 skill 檔案需從原系統或 ClawHub 重新安裝

## 還原方式

1. 克隆此倉庫
2. 將 .md 檔案複製到 \`~/.openclaw/workspace/\`
3. 將 scripts 複製到 \`~/.openclaw/workspace/scripts/\`
4. 使用 \`crontab crontab.txt\` 導入定時任務
EOF

# 8. 初始化 Git 並推送
cd "$BACKUP_DIR"
git init --quiet
git config user.email "backup@openclaw.local"
git config user.name "OpenClaw Backup"
git add .
git commit -m "自動備份 - $(date '+%Y-%m-%d %H:%M:%S')" --quiet

# 9. 推送到 GitHub
git remote add origin "https://${GITHUB_TOKEN}@github.com/jasonckfan/myskills.git" 2>/dev/null || \
    git remote set-url origin "https://${GITHUB_TOKEN}@github.com/jasonckfan/myskills.git"

# 強制推送 (覆蓋舊備份)
if git push -u origin master:main --force --quiet 2>> "$LOG_FILE"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 備份成功推送到 GitHub" >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 推送失敗" >> "$LOG_FILE"
    exit 1
fi

# 10. 清理
cd /
rm -rf "$BACKUP_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 備份完成" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
