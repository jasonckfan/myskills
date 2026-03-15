# HEARTBEAT.md

# 🔄 Heartbeat 记忆维护机制

## 基础检查（每30分钟）

1. **检查紧急事项** - 邮件/日历/待办事项
2. **整理记忆** - 短期记忆 → 长期记忆
3. **清理日志** - 自动删除7天前日志
4. **检查提醒** - 重要事项提醒

## 🚨 緊急天氣及突發警告監察（每15分鐘）

- [ ] **Weather Alert Monitor** (每15分鐘檢查):
  - 每當收到 heartbeat，自動檢查香港天文台警告 API
  - Script: `/home/jasonckfan/.openclaw/workspace/scripts/weather-alert-monitor.sh`
  - 檢查內容：
    - 🌧️ 暴雨警告 (黃/紅/黑雨)
    - 🌪️ 熱帶氣旋 / 強烈季候風
    - ⛈️ 雷暴警告
    - 🥶 寒冷天氣 / 🥵 酷熱天氣
    - 🌫️ 濃霧 / ❄️ 霜凍 / 🔥 火災危險
  - **觸發條件**：發現新警告或警告變更時
  - **行動**：即時發送 WhatsApp 訊息到「嫲嫲煩煩」群組
  - **避免重複**：記錄已發送警告，相同警告不重複通知

## ⏰ 時間準確性檢查（每次 Heartbeat）

> ⚠️ **關鍵防錯機制** - 防止日期時間錯誤重演 (Source: memory/2026-03-14-wrong-timing.md)

- [ ] **Time Verification** (每次收到 heartbeat 必檢查):
  - 運行時間驗證腳本: `/home/jasonckfan/.openclaw/workspace/scripts/time-validator.sh`
  - 確認當前時間 (HKT): `TZ="Asia/Hong_Kong" date "+%Y-%m-%d %H:%M:%S"`
  - 檢查是否係夜晚 (22:00-08:00)
  - **如果係夜晚**: 絕對不發送任何訊息到嫲嫲煩煩群組
  - **如果早於 07:30**: 不發送群組第一條訊息
  - Script: `/home/jasonckfan/.openclaw/workspace/scripts/regular-time-check.sh`
  
- [ ] **定期檢查執行**:
  - 每小時自動運行: `regular-time-check.sh`
  - 檢查日誌: `~/.openclaw/workspace/logs/time-check.log`
  - 發現異常立即記錄到 `time-alerts.log`

- [ ] **Cron Job 狀態檢查**:
  - 檢查定時任務是否正常運行
  - 驗證: `crontab -l | grep time-check`
  - 如有異常，運行: `setup-time-check-cron.sh`

## Memory V2: 每日記憶歸檔與同步

- [ ] **Session Auto-Save** (每日記憶歸檔):
  - 每當收到 heartbeat，自動檢查及運行保存腳本：
  - Script: `/home/jasonckfan/.openclaw/workspace/skills/lancedb-memory-v2/scripts/save_session_summary.sh`
  - 運行後，將結果寫入 `memory/heartbeat-state.json` 記錄 `last_save_ts` 及 `last_save_status`。
  - 確保每日的所有重要信息、決策及待辦事項均被歸檔到 `memory/YYYY-MM-DD.md`。

- [ ] **Weekly Review & Sync** (每週記憶整合):
  - 若今日為星期日，或者超過 7 日未做 Weekly Review，請自動生成一份過去 7 日的摘要。
  - 將 7 日內仍然有效的重要信息及決策同步寫入 `MEMORY.md` (Long-term memory)。

- [ ] **Vectorize Memory** (記憶向量化):
  - 定期運行：`/home/jasonckfan/.openclaw/workspace/skills/lancedb-memory-v2/scripts/sync_memory_md.py`
  - 將所有 `memory/*.md` 和 `MEMORY.md` 向量化存入 LanceDB

## 每日维护任务

1. ✅ 检查24h记忆 - 检查昨天的memory文件
2. ✅ 提取决策 - 重要决策/偏好 → MEMORY.md
3. ✅ 清理临时信息 - 删除已处理的临时信息

## 每周维护任务（周日）

1. ✅ 回顾MEMORY.md - 补充遗漏的重要信息
2. ✅ 更新项目状态 - 同步项目进度
3. ✅ 清理旧记忆 - 删除30天前的daily memory

## 汇报要求

- 所有汇报内容必须使用【繁體中文】
- 汇报需包含：模型池健康状态、技能学习进度、记忆维护情况
- 如发现新报告或需要引起注意的事项，请主动汇报

## Self-Evolving v2.0 任務

- [ ] **Daily Evolution** (每日22:00):
  - 收到 `self_evolution_daily` 事件時執行
  - Script: `/home/jasonckfan/.openclaw/workspace/skills/self-evolving-skill/scripts/daily-evolution.py`
  - 輸出: `memory/YYYY-MM-DD-evolution.md`
  - 內容: 對話歷史分析、錯誤模式識別、改進機會

- [ ] **Weekly Skill Discovery** (每週日09:00):
  - 收到 `skill_discovery_weekly` 事件時執行
  - Script: `/home/jasonckfan/.openclaw/workspace/skills/self-evolving-skill/scripts/skill-discovery.py`
  - 輸出: `memory/skill-discovery-YYYY-MM-DD.md`
  - 內容: 最新AI Agent研究趨勢、能力缺口分析、技能建議

## 汇报格式

```markdown
# 📊 系统狀態報告

## 📊 今日數據
- 會話次數: X次
- 完成任務: X個
- Token消耗: X
- 學習技能: X個

## 🎓 學會的新東西
1. ...
2. ...
3. ...

## ⚠️ 犯的錯誤
1. ...
   - 原因: ...
   - 解決: ...

## 💡 可以固化的技能
1. **技能名稱**: 說明
2. **技能名稱**: 說明
3. **技能名稱**: 說明

## 📝 明日改進計劃
1. ...
2. ...
3. ...
```

---

## 📚 相關文件

- 時間準確性協議: `TIME_ACCURACY_PROTOCOL.md`
- 時間驗證腳本: `scripts/time-validator.sh`
- 定期檢查腳本: `scripts/regular-time-check.sh`
- Cron 設置腳本: `scripts/setup-time-check-cron.sh`
- 便捷 Alias: `scripts/openclaw-aliases.sh`

---

*最後更新: 2026-03-15 - 加入時間準確性檢查機制*
