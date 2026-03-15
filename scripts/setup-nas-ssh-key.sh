#!/bin/bash
# SSH 密鑰設置腳本 (用於 NAS 備份)
# 用途: 為 192.168.1.76 設置免密碼 SSH 登錄

set -e

NAS_IP="192.168.1.76"
NAS_USER="jasonckfan"

echo "🔐 OpenClaw NAS 備份 - SSH 密鑰設置"
echo "===================================="
echo ""

# 檢查是否已有密鑰
if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "✅ 已存在 SSH 密鑰"
else
    echo "🆕 生成新的 SSH 密鑰..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "openclaw-backup-$(hostname)"
    echo "✅ SSH 密鑰已生成"
fi

echo ""
echo "📋 下一步："
echo ""
echo "請手動將以下公鑰複製到 NAS (${NAS_IP})："
echo ""
cat "$HOME/.ssh/id_rsa.pub"
echo ""
echo "複製方法："
echo "1. SSH 登錄 NAS: ssh ${NAS_USER}@${NAS_IP}"
echo "2. 編輯 authorized_keys: nano ~/.ssh/authorized_keys"
echo "3. 貼上以上公鑰內容"
echo "4. 保存並退出"
echo ""
echo "或者使用以下指令（需要密碼）："
echo "  ssh-copy-id ${NAS_USER}@${NAS_IP}"
echo ""
echo "設置完成後，請測試連接："
echo "  ssh ${NAS_USER}@${NAS_IP} 'echo SSH OK'"
echo ""
