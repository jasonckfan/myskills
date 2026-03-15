#!/bin/bash
# 緊急天氣及突發警告監察腳本
# 檢查香港天文台警告並即時通知群組

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/home/jasonckfan/.openclaw/workspace/logs/weather-alert.log"
STATE_FILE="/home/jasonckfan/.openclaw/workspace/data/weather-alert-state.json"
GROUP_ID="85293429396-1481686102@g.us"

# 記錄執行
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 開始檢查天氣警告" >> "$LOG_FILE"

# 確保目錄存在
mkdir -p "$(dirname "$STATE_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# 獲取天文台警告資訊
warning_data=$(curl -s "https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=warnsum&lang=tc" 2>/dev/null)

if [ -z "$warning_data" ] || [ "$warning_data" = "{}" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️ 沒有活躍警告" >> "$LOG_FILE"
    exit 0
fi

# 檢查是否有警告
has_warning=$(echo "$warning_data" | grep -c '"code"' || echo "0")

if [ "$has_warning" -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️ 沒有活躍警告" >> "$LOG_FILE"
    # 清空狀態文件
    echo "{}" > "$STATE_FILE"
    exit 0
fi

# 解析警告資訊
warning_code=$(echo "$warning_data" | grep -o '"code":"[^"]*"' | head -1 | cut -d'"' -f4)
warning_name=$(echo "$warning_data" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
warning_action=$(echo "$warning_data" | grep -o '"action":"[^"]*"' | head -1 | cut -d'"' -f4)

# 讀取上次狀態
last_warning=""
if [ -f "$STATE_FILE" ]; then
    last_warning=$(cat "$STATE_FILE" | grep -o '"code":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
fi

# 如果是新警告或警告變更
if [ "$warning_code" != "$last_warning" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🚨 檢測到新警告: $warning_code - $warning_name" >> "$LOG_FILE"
    
    # 保存當前狀態
    echo "$warning_data" > "$STATE_FILE"
    
    # 根據警告類型給予建議
    case "$warning_code" in
        "WRAIN")
            icon="🌧️"
            advice="記得帶遮出門！路面濕滑要小心！"
            urgency="高"
            ;;
        "WRAINA")
            icon="🌧️"
            advice="黃雨警告生效中！外出記得帶遮！"
            urgency="中"
            ;;
        "WRAINR")
            icon="🌧️🌧️"
            advice="紅雨警告！避免外出，如必須外出請帶雨具並小心安全！"
            urgency="高"
            ;;
        "WRAINB")
            icon="🌧️🌧️🌧️"
            advice="⚠️ 黑雨警告！極端暴雨，請留在室內安全地方！"
            urgency="緊急"
            ;;
        "WTCSGNL")
            icon="💨"
            advice="熱帶氣旋警告生效！留意最新風暴消息！"
            urgency="高"
            ;;
        "WTMW")
            icon="🌪️"
            advice="強烈季候風！注意防風措施！"
            urgency="中"
            ;;
        "WTS")
            icon="⛈️"
            advice="雷暴警告！避免戶外活動，留意閃電！"
            urgency="高"
            ;;
        "WFROST")
            icon="❄️"
            advice="霜凍警告！農作物及戶外植物需保護！"
            urgency="中"
            ;;
        "WFIRE")
            icon="🔥"
            advice="火災危險警告！注意防火！"
            urgency="中"
            ;;
        "WMSGNL")
            icon="🌫️"
            advice="濃霧警告！駕駛要特別小心！"
            urgency="中"
            ;;
        "WCOLD")
            icon="🥶"
            advice="寒冷天氣警告！著多啲衫，注意保暖！"
            urgency="中"
            ;;
        "WHOT")
            icon="🥵"
            advice="酷熱天氣警告！多喝水，避免長時間戶外活動！"
            urgency="中"
            ;;
        *)
            icon="⚠️"
            advice="請留意天文台最新資訊！"
            urgency="中"
            ;;
    esac
    
    # 組合緊急訊息
    message="🚨 緊急天氣警告 $icon

⚠️ **$warning_name** 現正生效！

📍 香港天文台發布
⏰ $(date '+%Y-%m-%d %H:%M')

💡 溫馨提示：$advice

請大家注意安全！🙏"
    
    # 發送訊息
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📤 發送警告到群組 $GROUP_ID" >> "$LOG_FILE"
    /home/jasonckfan/.local/bin/openclaw message send --channel whatsapp --target "$GROUP_ID" --message "$message" 2>&1 >> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 警告發送成功" >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 警告發送失敗" >> "$LOG_FILE"
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️ 警告狀態未變更: $warning_code" >> "$LOG_FILE"
fi

echo "---" >> "$LOG_FILE"
