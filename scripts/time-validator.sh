#!/bin/bash
# 時間驗證腳本 - 防止錯誤時間發送訊息
# 用途: 所有自動化發送前必須調用

# 獲取當前時間 (香港時間)
CURRENT_HOUR=$(TZ="Asia/Hong_Kong" date +%H)
CURRENT_TIME=$(TZ="Asia/Hong_Kong" date "+%Y-%m-%d %H:%M:%S")
CURRENT_WEEKDAY=$(TZ="Asia/Hong_Kong" date +%u) # 1=Monday, 7=Sunday

echo "🔍 時間驗證檢查"
echo "   當前時間: $CURRENT_TIME (HKT)"
echo "   當前鐘點: $CURRENT_HOUR"
echo "   星期幾: $CURRENT_WEEKDAY (1=一, 7=日)"

# 檢查是否係夜晚 (22:00 - 08:00)
if [ "$CURRENT_HOUR" -ge 22 ] || [ "$CURRENT_HOUR" -lt 8 ]; then
    echo "❌ 錯誤: 現在係夜晚/凌晨時段 (22:00-08:00)"
    echo "   根據 MEMORY.md 規則，絕對不可以在夜晚發訊息！"
    exit 1
fi

# 檢查是否係嫲嫲煩煩群組發送時間 (必須 07:30 後)
if [ "$CURRENT_HOUR" -lt 7 ] || ([ "$CURRENT_HOUR" -eq 7 ] && [ "$(TZ="Asia/Hong_Kong" date +%M)" -lt 30 ]); then
    echo "⚠️  警告: 現在早於 07:30，不應向嫲嫲煩煩發送第一條訊息"
    # 這是警告，但不阻止，因為可能是回覆
fi

echo "✅ 時間驗證通過，可以發送訊息"
exit 0
