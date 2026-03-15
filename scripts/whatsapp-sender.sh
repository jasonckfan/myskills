#!/bin/bash
# WhatsApp 訊息發送腳本 (CallMeBot API)
# 使用方法: ./whatsapp-sender.sh "你的訊息"

# 設定
PHONE="85254224333"
APIKEY="5066138"
API_URL="https://api.callmebot.com/whatsapp.php"

# 檢查參數
if [ $# -eq 0 ]; then
    echo "❌ 使用方法: $0 \"你的訊息\""
    echo "📱 範例: $0 \"今日天氣很好！\""
    exit 1
fi

# 取得訊息並進行 URL encode
MESSAGE="$1"
ENCODED_MESSAGE=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$MESSAGE'''))" 2>/dev/null || echo "$MESSAGE" | sed 's/ /%20/g')

# 發送訊息
echo "📤 正在發送訊息..."
echo "📱 號碼: $PHONE"
echo "📝 內容: $MESSAGE"
echo ""

RESPONSE=$(curl -s "${API_URL}?phone=${PHONE}&text=${ENCODED_MESSAGE}&apikey=${APIKEY}")

# 檢查回應
if echo "$RESPONSE" | grep -q "Message queued\|Message to:"; then
    echo "✅ 訊息發送成功！"
    echo "📤 伺服器回應: $RESPONSE"
elif echo "$RESPONSE" | grep -q "APIKey is invalid"; then
    echo "❌ API Key 無效，請檢查設定"
    exit 1
else
    echo "⚠️ 發送狀態不明"
    echo "📤 伺服器回應: $RESPONSE"
fi

echo ""
echo "💡 提示: 可以用 crontab 設定定時發送"
echo "   crontab -e"
echo "   0 9 * * * /home/jasonckfan/.openclaw/workspace/scripts/whatsapp-sender.sh \"早晨！今日天氣...\""
