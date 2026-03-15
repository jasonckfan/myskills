#!/bin/bash
# HomePod mini TTS 發送腳本
# 使用 pyatv 發送文字轉語音到 HomePod mini

HOMEPOD_NAME="${HOMEPOD_NAME:-HomePod mini}"
TEXT="$1"

if [ -z "$TEXT" ]; then
    echo "用法: $0 '你好嗎？'"
    exit 1
fi

echo "掃描網絡上的 HomePod mini..."

# 使用 atvremote 掃描並發送
atvremote scan | grep -i "homepod"

# 如果找到 HomePod，使用 AirPlay 協議連接
# 注意：pyatv 主要支持 Apple TV，對 HomePod 的支援有限