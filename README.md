# OpenClaw 自動備份

備份日期: 2026-03-16 00:00:02

## 目錄結構

```
.
├── AGENTS.md           # Agent 行為準則
├── SOUL.md             # 核心身份定義
├── MEMORY.md           # 長期記憶
├── USER.md             # 用戶資料
├── TOOLS.md            # 本地工具設定
├── HEARTBEAT.md        # Heartbeat 任務
├── IDENTITY.md         # 身份設定
├── config/             # 配置檔案
├── cron/               # Cron 任務列表
├── skills/             # Skills 清單
├── scripts/            # 自定義腳本
└── memory/             # 近期記憶檔案
```

## 注意事項

- `openclaw.json` 包含敏感資訊，已從備份中排除
- 此備份由自動化腳本於每日 00:00 執行
- 完整 skill 檔案需從原系統或 ClawHub 重新安裝

## 還原方式

1. 克隆此倉庫
2. 將 .md 檔案複製到 `~/.openclaw/workspace/`
3. 將 scripts 複製到 `~/.openclaw/workspace/scripts/`
4. 使用 `crontab crontab.txt` 導入定時任務
