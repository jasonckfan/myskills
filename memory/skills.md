# Skills Memory

## Custom Skills

### web-search-fallback
- **位置**: ~/.openclaw/workspace/skills/web-search-fallback/
- **功能**: 自動搜尋，Brave fail 時轉用 SearXNG
- **用法**: `search for xxx` 或 `搜尋 xxx`

### homelab-health
- **位置**: ~/.openclaw/workspace/skills/homelab-health/
- **功能**: 系統健康檢查 script
- **Scripts**: 
  - health-check.sh - 即時檢查
  - daily-report.sh - 每日報告

### incremental-backup-gfs
- **功能**: GFS 風格 incremental backup

### lancedb-memory-v2
- **位置**: ~/.openclaw/workspace/skills/lancedb-memory-v2/
- **功能**: 雙軌長短期記憶整合機制 (基礎版本)
- **Scripts**:
  - save_session_summary.sh - 單一 Session 保存
  - sync_memory_md.py - 向量化入庫 (支援 VISION_SETUP.md, TIME_ACCURACY_PROTOCOL.md)

### lancedb-memory-v3 ⭐
- **位置**: ~/.openclaw/workspace/skills/lancedb-memory-v3/
- **功能**: 多 Session 同步版本，可完整保存所有通道對話
- **Scripts**:
  - save_session_summary.sh (V3) - 多 Session 同步
  - sync_memory_md.py (V3) - 向量化入庫 (支援 VISION_SETUP.md, TIME_ACCURACY_PROTOCOL.md)
- **特點**: 完整保存 Telegram、WhatsApp 等所有通道內容
- **同步**: 已更新支援 Guardian 文件

### openclaw-guardian ⭐ NEW
- **位置**: ~/.openclaw/workspace/skills/openclaw-guardian/
- **功能**: OpenClaw 守護機制 - Vision 設置、時間準確性防錯、定期檢查
- **Scripts**:
  - time-validator.sh - 時間驗證
  - regular-time-check.sh - 每小時定期檢查
  - daily-task-runner.sh - 帶雙重確認的任務執行
  - setup-time-check-cron.sh - 設置 Cron Job
  - start-vision-session.sh - 啟動 Vision session
  - openclaw-guardian-aliases.sh - 便捷指令
  - install.sh - 一鍵安裝
- **Docs**:
  - VISION_SETUP.md - Vision 設置指南
  - TIME_ACCURACY_PROTOCOL.md - 時間準確性協議
- **安裝**: `~/.openclaw/workspace/skills/openclaw-guardian/scripts/install.sh`

## Backup Scripts

### daily-nas-backup.sh ⭐ NEW
- **位置**: ~/.openclaw/workspace/scripts/daily-nas-backup.sh
- **功能**: 每日 00:00 將 ~/.openclaw 完整備份到 192.168.1.76/application
- **格式**: tar.gz 壓縮，保留 7 天
- **參考**: 192.168.1.154 備份方案
- **相關腳本**:
  - setup-nas-ssh-key.sh - 設置 SSH 密鑰
  - setup-daily-nas-backup-cron.sh - 設置 Cron Job

## Skill 安裝位置

| Machine | Skill Path |
|---------|-------------|
| Linux Gateway | ~/.openclaw/workspace/skills/ |
| Mac Mini | ~/.openclaw/workspace/skills/ |
| Ubuntu | ~/.openclaw/workspace/skills/ |

## Scripts

- **gateway-model-check.sh**: ~/.openclaw/scripts/gateway-model-check.sh
  - Check 3台 OpenCLAW 狀態
  - Gateway down 會自動 restart
  - 跟住做 model failover check

- **model-failover-recovery.sh**: 
  - Mac Mini: ~/scripts/model-failover-recovery.sh
  - Ubuntu: ~/.openclaw/scripts/model-failover-recovery.sh

- **session-cleanup.sh**: ~/.openclaw/scripts/session-cleanup.sh

- **daily-nas-backup.sh**: ~/.openclaw/workspace/scripts/daily-nas-backup.sh
  - 每日完整備份到 NAS (192.168.1.76)
  - 保留 7 天，自動清理舊備份

---

Last updated: 2026-03-15
