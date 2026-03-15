#!/bin/bash
# 每週記憶整合腳本
# 每週日 09:00 執行

MEMORY_DIR="/home/jasonckfan/.openclaw/workspace/memory"
MEMORY_MD="/home/jasonckfan/.openclaw/workspace/MEMORY.md"
LOG_FILE="/home/jasonckfan/.openclaw/workspace/logs/weekly-memory-sync.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 開始每週記憶整合" >> "$LOG_FILE"

# 1. 檢查過去 7 天的記憶檔案
echo "📅 檢查過去 7 天記憶..." >> "$LOG_FILE"
for i in {0..6}; do
    DATE=$(date -d "$i days ago" +%Y-%m-%d 2>/dev/null || date -v-${i}d +%Y-%m-%d)
    FILE="$MEMORY_DIR/$DATE.md"
    if [ -f "$FILE" ]; then
        echo "  ✅ $DATE.md 存在" >> "$LOG_FILE"
    else
        echo "  ⚠️ $DATE.md 缺失" >> "$LOG_FILE"
    fi
done

# 2. 提取重要決策 (簡單關鍵詞搜尋)
echo "🔍 提取重要決策..." >> "$LOG_FILE"
grep -h "## 核心決策\|## 重要\|## 決定" $MEMORY_DIR/2026-*.md 2>/dev/null | head -10 >> "$LOG_FILE" || echo "  未找到標記的決策" >> "$LOG_FILE"

# 3. 更新 MEMORY.md 的「最後更新」時間
sed -i "s/最後更新:.*/最後更新: $(date +%Y-%m-%d)/" "$MEMORY_MD" 2>/dev/null || true

# 4. 觸發 LanceDB 完整同步
if [ -f "$HOME/.openclaw/workspace/skills/lancedb-memory-v2/scripts/sync_memory_md.py" ]; then
    python3 "$HOME/.openclaw/workspace/skills/lancedb-memory-v2/scripts/sync_memory_md.py" >> "$LOG_FILE" 2>&1
    echo "✅ LanceDB 同步完成" >> "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 每週整合完成" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
