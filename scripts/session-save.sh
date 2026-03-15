#!/bin/bash
# 會話結束時自動保存摘要
# 由 OpenClaw 在會話結束時調用

SESSION_ID="$1"
MEMORY_DIR="/home/jasonckfan/.openclaw/workspace/memory"
TODAY_FILE="$MEMORY_DIR/$(date +%Y-%m-%d).md"

# 確保目錄存在
mkdir -p "$MEMORY_DIR"

# 如果今日檔案不存在，創建標題
if [ ! -f "$TODAY_FILE" ]; then
    echo "# $(date +%Y-%m-%d) Daily Memory" > "$TODAY_FILE"
    echo "" >> "$TODAY_FILE"
fi

# 添加會話結束標記
echo "" >> "$TODAY_FILE"
echo "## Session Ended - $(date '+%H:%M')" >> "$TODAY_FILE"
echo "" >> "$TODAY_FILE"
echo "- Session ID: $SESSION_ID" >> "$TODAY_FILE"
echo "- 自動保存時間: $(date '+%Y-%m-%d %H:%M:%S')" >> "$TODAY_FILE"
echo "" >> "$TODAY_FILE"

# 觸發 LanceDB 同步
if [ -f "$HOME/.openclaw/workspace/skills/lancedb-memory-v2/scripts/sync_memory_md.py" ]; then
    python3 "$HOME/.openclaw/workspace/skills/lancedb-memory-v2/scripts/sync_memory_md.py" 2>/dev/null || true
fi

echo "會話已保存到 $TODAY_FILE"
