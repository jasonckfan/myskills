#!/bin/bash
# 每日記憶審計腳本
# 檢查記憶系統健康狀況

LOG_FILE="/home/jasonckfan/.openclaw/workspace/logs/memory-audit.log"
MEMORY_DIR="/home/jasonckfan/.openclaw/workspace/memory"
LANCE_DB_DIR="/home/jasonckfan/.openclaw/workspace/lancedb-memory"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 開始記憶審計" >> "$LOG_FILE"

# 1. 檢查今日記憶檔案是否存在
TODAY_FILE="$MEMORY_DIR/$(date +%Y-%m-%d).md"
if [ ! -f "$TODAY_FILE" ]; then
    echo "⚠️ 警告：今日記憶檔案不存在" >> "$LOG_FILE"
fi

# 2. 檢查 LanceDB 同步狀態
if [ -d "$LANCE_DB_DIR" ]; then
    LAST_SYNC=$(stat -c %Y "$LANCE_DB_DIR" 2>/dev/null || echo "0")
    NOW=$(date +%s)
    DIFF=$((NOW - LAST_SYNC))
    if [ $DIFF -gt 86400 ]; then
        echo "⚠️ 警告：LanceDB 超過 24 小時未同步" >> "$LOG_FILE"
    fi
fi

# 3. 檢查記憶檔案大小異常
for file in "$MEMORY_DIR"/2026-*.md; do
    if [ -f "$file" ]; then
        SIZE=$(stat -c %s "$file" 2>/dev/null || echo "0")
        if [ $SIZE -lt 100 ]; then
            echo "⚠️ 警告：$(basename $file) 檔案過小 (${SIZE} bytes)" >> "$LOG_FILE"
        fi
    fi
done

# 4. 統計信息
echo "📊 記憶統計：" >> "$LOG_FILE"
echo "  - 記憶檔案數量: $(ls -1 $MEMORY_DIR/*.md 2>/dev/null | wc -l)" >> "$LOG_FILE"
echo "  - 今日檔案大小: $(stat -c %s $TODAY_FILE 2>/dev/null || echo '0') bytes" >> "$LOG_FILE"
echo "  - LanceDB 狀態: $([ -d $LANCE_DB_DIR ] && echo '存在' || echo '不存在')" >> "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 審計完成" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
