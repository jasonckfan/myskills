
### 2026-02-23 Update
- **Model Config**:
  - Primary: `google-gemini-cli/gemini-3-pro-preview`
  - Fallback 1: `openai-codex/gpt-5.3-codex` (Auth sync from Mac Mini)
  - Removed: `nvidia/moonshotai/kimi-k2.5` (Fallback)
- **NAS (192.168.1.76)**:
  - Cleaned up ~2500+ duplicate subtitle files (.srt) caused by Emby auto-download loop.
  - Target: `/volume1/movie` (Ghosted, Greenland, etc.)
  - Action: Deleted files matching `*.[0-9]{1,3}.zh-CN.srt` modified in last 90 days.
- **Memory Automation**:
  - Attempted to deploy `memory-worker.py` for daily auto-summary.
  - Status: **Failed** due to lack of usable LLM API for external scripts (Region/Quota/Scope issues).
  - Workaround: Manual consolidation by agent.
