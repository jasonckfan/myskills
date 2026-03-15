#!/bin/bash
# Daily Shopping Deals Report - Runs at 1 PM daily
# Searches for HK supermarket deals and sends to WhatsApp group

set -e

WORKSPACE="/home/jasonckfan/.openclaw/workspace"
SEARXNG_SCRIPT="$WORKSPACE/skills/searxng/scripts/searxng.py"
LOG_FILE="$WORKSPACE/logs/shopping-deals.log"
TARGET_GROUP="85293429396-1481686102@g.us"

# Create logs directory if not exists
mkdir -p "$WORKSPACE/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Starting daily shopping deals search..."

# Search queries for different supermarkets
SEARCH_QUERIES=(
    "ParknShop 百佳 今日優惠 特價"
    "Wellcome 惠康 今日優惠 特價"
    "Donki 驚安殿堂 香港 減價 優惠"
    "HKTVmall 今日優惠 特價"
    "大生超市 零食 優惠"
    "優品360 特價 優惠"
)

# Collect results
RESULTS=""
for query in "${SEARCH_QUERIES[@]}"; do
    log "Searching: $query"
    search_result=$(uv run "$SEARXNG_SCRIPT" search "$query" -n 3 --format json 2>/dev/null || echo "[]")
    
    # Parse first result title and URL
    if echo "$search_result" | jq -e '.[0]' > /dev/null 2>&1; then
        title=$(echo "$search_result" | jq -r '.[0].title' | head -c 80)
        url=$(echo "$search_result" | jq -r '.[0].url')
        snippet=$(echo "$search_result" | jq -r '.[0].snippet' | head -c 100)
        
        if [ "$title" != "null" ] && [ -n "$title" ]; then
            RESULTS+="• $title\n  $url\n"
        fi
    fi
    
    # Small delay to be nice to the search engine
    sleep 1
done

# Format message
DATE_STR=$(date '+%m月%d日')
MESSAGE="🛒 *今日購物優惠速報* ($DATE_STR)\n\n"

if [ -n "$RESULTS" ]; then
    MESSAGE+="$RESULTS"
else
    MESSAGE+="今日暫時搵唔到特別優惠，建議大家直接上各超市網站查看最新特價！"
fi

MESSAGE+="\n💡 *溫馨提示*：優惠隨時完，有興趣就快啲去睇啦！"

# Send to WhatsApp group
log "Sending message to WhatsApp group..."
openclaw message send --target "$TARGET_GROUP" --message "$MESSAGE" >> "$LOG_FILE" 2>&1 || {
    log "ERROR: Failed to send WhatsApp message"
    exit 1
}

log "Daily shopping deals report completed successfully"
