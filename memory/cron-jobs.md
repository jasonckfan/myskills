# Cron Jobs Memory

## Linux Gateway (每 30 分鐘)

| Job Name | Schedule | 描述 |
|----------|----------|------|
| Model Failover Check | every 30min | Gateway health check + model failover |
| System Health Check | every 30min | Homelab health check |
| Session Cleanup | hourly (0 * * * *) | 清理舊 sessions |
| Nightly Memory Consolidation | 23:00 daily | 整理每日記憶 |
| Daily Homelab Health Report | 08:00 daily | 每日健康報告 |
| Usage Alert Check | 09:00 daily | 使用量警告 |
| Movie Folder Check | 09:00 daily | 新電影 folder check |
| Daily Session Reset | 04:00 daily | 開新 session |

## Mac Mini

| Job Name | Schedule | 描述 |
|----------|----------|------|
| Backup | daily 00:00 | 備份去 /Volumes/2TB |
| Session Cleanup | hourly | 刪除 >1 日既 sessions |
| Model Failover | every 30min | 檢查 model 狀態 |

## Ubuntu

| Job Name | Schedule | 描述 |
|----------|----------|------|
| Backup | daily 00:00 | 備份 |
| Memory Consolidation | 23:00 daily | 記憶整理 |
| Log Cleanup | 03:00 daily | 清理 logs |
| Temp Cleanup | 04:00 daily | 清理 temp |

---

Last updated: 2026-02-22
