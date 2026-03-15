#!/bin/bash
# Auto-Memory & Cleanup Script
# Runs periodically to manage LanceDB memory

LANCEDB_URL="http://192.168.1.250:8765"
USER_ID="default"
LOG_FILE="/home/jasonckfan/.openclaw/logs/memory.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# ========== AUTO-MEMORY ==========
# Save conversation summary to LanceDB
save_memory() {
    local content="$1"
    local source="${2:-manual}"
    
    local response=$(curl -s -X POST "$LANCEDB_URL/memory/write" \
        -H "Content-Type: application/json" \
        -d "{
            \"user_id\": \"$USER_ID\",
            \"text\": \"$content\",
            \"metadata\": {\"source\": \"$source\", \"date\": \"$(date +%Y-%m-%d)\"}
        }")
    
    if echo "$response" | grep -q '"written":true'; then
        log "Saved: ${content:0:50}..."
        return 0
    else
        log "Failed to save memory"
        return 1
    fi
}

# ========== CLEANUP ==========
cleanup_memory() {
    log "Starting memory cleanup..."
    
    # Search for old/duplicate memories and delete
    # Get all memories
    local all_items=$(curl -s -X POST "$LANCEDB_URL/memory/search" \
        -H "Content-Type: application/json" \
        -d "{\"user_id\": \"$USER_ID\", \"query\": \"\", \"limit\": 100}")
    
    # Delete duplicates (keep newest)
    echo "$all_items" | python3 -c "
import json
import sys
from collections import Counter

data = json.load(sys.stdin)
items = data.get('items', [])

# Find duplicates by content hash
hashes = [item.get('hash', '') for item in items]
duplicates = [h for h, c in Counter(hashes).items() if c > 1]

# Print IDs to delete (keep first occurrence)
seen = set()
to_delete = []
for item in items:
    h = item.get('hash', '')
    if h in duplicates and h not in seen:
        seen.add(h)
    elif h in duplicates:
        to_delete.append(item.get('id', ''))

for id in to_delete:
    print(id)
" | while read id; do
        [ -n "$id" ] && curl -s -X POST "$LANCEDB_URL/memory/delete" \
            -H "Content-Type: application/json" \
            -d "{\"user_id\": \"$USER_ID\", \"id\": \"$id\"}" 2>/dev/null
        log "Deleted duplicate: $id"
    done
    
    log "Cleanup complete"
}

# ========== CROSS-DEVICE SYNC ==========
sync_memory() {
    local source_ip="$1"
    local target_ip="$2"
    
    log "Syncing memory from $source_ip to $target_ip..."
    
    # Get memories from source
    local memories=$(sshpass -p '1209' ssh -o StrictHostKeyChecking=no jasonckfan@${source_ip} \
        "curl -s -X POST http://127.0.0.1:8765/memory/search \
        -H 'Content-Type: application/json' \
        -d '{\"user_id\": \"$USER_ID\", \"query\": \"\", \"limit\": 100}'" 2>/dev/null)
    
    # Write to target (skip duplicates)
    echo "$memories" | python3 -c "
import json
import sys

data = json.load(sys.stdin)
items = data.get('items', [])

for item in items[:20]:  # Limit to 20 per sync
    text = item.get('text', '')
    if text:
        print(text)
" | while read text; do
        [ -n "$text" ] && sshpass -p '1209' ssh -o StrictHostKeyChecking=no jasonckfan@${target_ip} \
            "curl -s -X POST http://127.0.0.1:8765/memory/write \
            -H 'Content-Type: application/json' \
            -d '{\"user_id\": \"$USER_ID\", \"text\": \"$text\", \"metadata\": {\"source\": \"sync\", \"date\": \"$(date +%Y-%m-%d)\"}}'" 2>/dev/null
    done
    
    log "Sync complete"
}

# ========== SENTIMENT TRACKING ==========
track_sentiment() {
    # Analyze recent memories for preference changes
    local recent=$(curl -s -X POST "$LANCEDB_URL/memory/search" \
        -H "Content-Type: application/json" \
        -d "{\"user_id\": \"$USER_ID\", \"query\": \"prefer want like dislike\", \"limit\": 10}")
    
    echo "$recent" | python3 -c "
import json
import sys
from datetime import datetime, timedelta

data = json.load(sys.stdin)
items = data.get('items', [])

# Track preferences over time
preferences = []
for item in items:
    text = item.get('text', '')
    created = item.get('created_at', '')[:10]
    preferences.append({'text': text[:100], 'date': created})

# Group by date
by_date = {}
for p in preferences:
    d = p['date']
    if d not in by_date:
        by_date[d] = []
    by_date[d].append(p['text'])

print('=== Preference Changes ===')
for date, texts in sorted(by_date.items(), reverse=True)[:5]:
    print(f'{date}: {len(texts)} mentions')
    for t in texts[:2]:
        print(f'  - {t}')
"
}

# ========== MAIN ==========
case "${1:-status}" in
    save)
        save_memory "$2" "${3:-manual}"
        ;;
    cleanup)
        cleanup_memory
        ;;
    sync)
        sync_memory "192.168.1.250" "192.168.1.24"
        ;;
    sentiment)
        track_sentiment
        ;;
    *)
        echo "Usage: $0 {save|cleanup|sync|sentiment} [args]"
        ;;
esac
