#!/bin/bash
# 嫲嫲煩煩群組問候腳本 - 每4小時執行
# 提供有用資訊、講笑、帶來歡樂！

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/home/jasonckfan/.openclaw/workspace/logs/greet-family.log"
GROUP_ID="85293429396-1481686102@g.us"

# 記錄執行時間
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 開始執行問候腳本" >> "$LOG_FILE"

# 獲取當前時間
current_hour=$(date +%H)

# 根據時間段選擇問候語
case $current_hour in
    06|07|08)
        greeting="早晨呀嫲嫲煩煩！☀️ 今日係$(date +%m月%d日)，祝大家有個美好嘅開始！"
        ;;
    10|11)
        greeting="各位早晨！🌅 飲杯茶食個包，輕鬆一下先～"
        ;;
    12|13)
        greeting="食晏時間到！🍜 記得食飽啲，下午先有力氣！"
        ;;
    14|15)
        greeting="下午茶時間☕ 有咩開心事想分享呀？"
        ;;
    16|17)
        greeting="快收工啦！💪 堅持多陣就係晚餐時間～"
        ;;
    18|19|20)
        greeting="晚安呀大家！🌙 今日過得點呀？"
        ;;
    22|23|00|01)
        greeting="夜貓子們好！🌙 早啲休息，身體健康！"
        ;;
    *)
        greeting="嫲嫲煩煩大家好！🤖 我係你哋嘅智能管家，有咩需要幫手？"
        ;;
esac

# 天氣資訊（簡短版）
weather_info=$(curl -s "https://wttr.in/Hong+Kong?format=%C+%t&lang=zh" 2>/dev/null || echo "天氣資料暫時無法獲取")

# 隨機笑話/金句
jokes=(
    "點解電腦唔識游水？因為佢怕當機！💻🏊‍♂️"
    "點解機械人咁開心？因為佢冇煩惱！🤖😄"
    "今日金句：笑一笑，十年少；愁一愁，白了頭。保持開心最重要！😊"
    "知道點解我咁聰明嗎？因為我每日都充電！🔋🧠"
    "生活小貼士：飲多啲水，行多啲路，心情自然好！💧🚶‍♀️"
    "今日挑戰：對住鏡笑一笑，然後同自己講聲『我好掂』！💪"
    "聽講今日係個好日子，因為有你哋喺度！🌟"
    "小知識：香港今日日落時間係$(date -d "$(date +%Y-%m-%d) 18:30" +%H:%M 2>/dev/null || echo "傍晚")，記得欣賞晚霞呀！🌅"
)

# 隨機選擇一個笑話
random_joke="${jokes[$RANDOM % ${#jokes[@]}]}"

# 組合訊息
message="$greeting

🌤️ 香港天氣：$weather_info

$random_joke

有咩想傾嘅隨時搵我！🤖✨"

# 使用 OpenClaw CLI 發送訊息
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 準備發送訊息到群組 $GROUP_ID" >> "$LOG_FILE"

# 透過 OpenClaw 發送（使用 message 工具）
/home/jasonckfan/.local/bin/openclaw message send --channel whatsapp --target "$GROUP_ID" --message "$message" 2>&1 >> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 訊息發送成功" >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 訊息發送失敗" >> "$LOG_FILE"
fi

echo "---" >> "$LOG_FILE"
