#!/bin/bash
# JPY/HKD 匯率監控腳本
# 當 1 日圓兌港元低於 0.05 時返回 0 (需要通知)
# 否則返回 1 (不需要通知)

THRESHOLD=0.05

# 使用 exchangerate-api 免費 API 獲取 JPY 兌 HKD 匯率
# 這個 API 不需要 API key
API_URL="https://api.exchangerate-api.com/v4/latest/JPY"

echo "=================================="
echo "🇯🇵 JPY/HKD 匯率監控"
echo "=================================="

# 獲取匯率數據
RESPONSE=$(curl -s "$API_URL")

if [ -z "$RESPONSE" ]; then
    echo "❌ 無法獲取匯率數據"
    exit 2
fi

# 提取 HKD 匯率
RATE=$(echo "$RESPONSE" | grep -o '"HKD":[0-9.]*' | cut -d':' -f2)

if [ -z "$RATE" ]; then
    echo "❌ 無法解析匯率數據"
    exit 2
fi

echo "📊 當前匯率: 1 JPY = $RATE HKD"
echo "🎯 提醒閾值: $THRESHOLD HKD"
echo "----------------------------------"

# 比較匯率
if (( $(echo "$RATE < $THRESHOLD" | bc -l) )); then
    echo "✅ 條件觸發！匯率 ($RATE) 低於 $THRESHOLD"
    echo "📱 應該發送 WhatsApp 通知"
    exit 0
else
    echo "⏳ 匯率 ($RATE) 高於閾值 ($THRESHOLD)"
    echo "😴 暫時不需要通知"
    exit 1
fi
