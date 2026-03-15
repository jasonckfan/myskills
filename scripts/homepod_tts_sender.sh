#!/bin/bash
# HomePod mini TTS 發送腳本
# 用法: ./homepod_tts_sender.sh "范治國你好"

# 檢查輸入
if [ -z "$1" ]; then
    echo "用法: $0 '要說的話'"
    echo "範例: $0 '范治國你好'"
    exit 1
fi

TEXT="$1"
MAC_IP="192.168.1.44"
MAC_USER="jasonfan"

echo "🎵 準備發送 TTS 到 HomePod mini..."
echo "📝 內容: $TEXT"

# 使用 SSH 發送 say 命令
# 注意：需要先在 Mac Mini 上設定 HomePod mini 為預設輸出
ssh -o StrictHostKeyChecking=no ${MAC_USER}@${MAC_IP} "say -v 'Ting-Ting' '$TEXT'"

if [ $? -eq 0 ]; then
    echo "✅ 發送成功！"
else
    echo "❌ 發送失敗，請檢查："
    echo "   1. Mac Mini 是否開機 (192.168.1.44)"
    echo "   2. SSH Key 是否正確設定"
    echo "   3. HomePod mini 是否已設為預設輸出"
fi
