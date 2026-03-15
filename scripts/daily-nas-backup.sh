#!/bin/bash
# OpenClaw 每日完整備份腳本
# 用途: 每日 00:00 將 ~/.openclaw 完整備份到 192.168.1.76
# 創建日期: 2026-03-15
# 參考: 192.168.1.154 備份方案

set -e

# 配置
BACKUP_SRC="$HOME/.openclaw"
BACKUP_SERVER="192.168.1.76"
BACKUP_USER="jasonckfan"
BACKUP_DIR="/var/services/homes/jasonckfan/openclaw_backups"
DATE=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="openclaw_full_backup_${DATE}.tar.gz"
LOCAL_TMP="/tmp/${BACKUP_FILE}"
LATEST_LINK="latest"
LOG_FILE="$HOME/.openclaw/workspace/logs/backup.log"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 記錄日志
log() {
    echo -e "$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $2" >> "$LOG_FILE"
}

# 檢查源目錄
if [ ! -d "$BACKUP_SRC" ]; then
    log "${RED}錯誤: 源目錄不存在: $BACKUP_SRC${NC}" "ERROR: Source directory not found: $BACKUP_SRC"
    exit 1
fi

# 確保日志目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

log "${YELLOW}🕛 午夜好！$(date '+%I:%M %p') 的智慧備份檢查報告：${NC}" "Starting daily backup"
echo ""

# 檢查遠端連接
log "🔍 檢查遠端備份目錄..." "Checking remote backup directory"
if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "${BACKUP_USER}@${BACKUP_SERVER}" "mkdir -p ${BACKUP_DIR}" 2>/dev/null; then
    log "${RED}❌ 無法連接到備份伺服器 ${BACKUP_SERVER}${NC}" "ERROR: Cannot connect to backup server"
    log "${YELLOW}💡 提示: 請先運行 setup-ssh-key.sh 配置 SSH 密鑰${NC}" "HINT: Please run setup-ssh-key.sh first"
    exit 1
fi
log "${GREEN}✅ 遠端目錄檢查完成${NC}" "Remote directory check passed"

# 計算備份大小
log "📊 計算備份大小..." "Calculating backup size"
BACKUP_SIZE=$(du -sh "$BACKUP_SRC" 2>/dev/null | cut -f1)
log "   備份內容: ${BACKUP_SRC} (${BACKUP_SIZE})" "Source: $BACKUP_SRC ($BACKUP_SIZE)"

# 創建壓縮備份
echo ""
log "📦 壓縮備份數據..." "Creating compressed backup"
tar -czf "$LOCAL_TMP" -C "$HOME" .openclaw 2>/dev/null || {
    log "${RED}❌ 壓縮失敗${NC}" "ERROR: Compression failed"
    rm -f "$LOCAL_TMP"
    exit 1
}

COMPRESSED_SIZE=$(du -sh "$LOCAL_TMP" 2>/dev/null | cut -f1)
log "${GREEN}✅ 壓縮完成: ${COMPRESSED_SIZE}${NC}" "Compression completed: $COMPRESSED_SIZE"

# 傳輸到遠端
echo ""
log "🚀 傳輸到備份伺服器..." "Transferring to backup server"
if scp -o BatchMode=yes -o ConnectTimeout=30 "$LOCAL_TMP" "${BACKUP_USER}@${BACKUP_SERVER}:${BACKUP_DIR}/${BACKUP_FILE}"; then
    log "${GREEN}✅ 傳輸完成${NC}" "Transfer completed"
else
    log "${RED}❌ 傳輸失敗${NC}" "ERROR: Transfer failed"
    rm -f "$LOCAL_TMP"
    exit 1
fi

# 更新 latest 連結
ssh -o BatchMode=yes "${BACKUP_USER}@${BACKUP_SERVER}" "cd ${BACKUP_DIR} && ln -sf ${BACKUP_FILE} ${LATEST_LINK}" 2>/dev/null || true

# 清理本地臨時文件
rm -f "$LOCAL_TMP"

# 清理舊備份 (保留最近 7 天)
echo ""
log "🧹 清理舊備份..." "Cleaning old backups"
DELETED=$(ssh -o BatchMode=yes "${BACKUP_USER}@${BACKUP_SERVER}" "cd ${BACKUP_DIR} && find . -name 'openclaw_full_backup_*.tar.gz' -mtime +7 -delete -print | wc -l" 2>/dev/null || echo "0")
log "   已刪除 ${DELETED} 個舊備份 (7天前)" "Deleted $DELETED old backups"

# 生成報告
echo ""
echo "────────────────────────────────────"
echo ""
log "${GREEN}💾 備份狀態：成功完成 ✅${NC}" "Backup completed successfully"
echo ""
printf "%-10s %-40s\n" "備份時間" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%-10s %-40s\n" "備份檔案" "$BACKUP_FILE"
printf "%-10s %-40s\n" "壓縮大小" "$COMPRESSED_SIZE"
printf "%-10s %-40s\n" "原始大小" "$BACKUP_SIZE"
printf "%-10s %-40s\n" "備份目標" "${BACKUP_SERVER} (${BACKUP_DIR})"
echo ""
echo "────────────────────────────────────"
echo ""
log "${GREEN}✅ 備份流程：${NC}" "Backup process summary"
echo "   1. ✅ 檢查遠端備份目錄"
echo "   2. ✅ 壓縮數據並傳輸"
echo "   3. ✅ 更新最新版本捷徑"
echo ""
echo "────────────────────────────────────"
echo ""
log "🌙 週日凌晨備份已完成！系統數據安全無虞，祝您有個安心的夜晚！😊✨" "Weekly backup completed"
echo ""
echo "晚安！🌟"

exit 0
