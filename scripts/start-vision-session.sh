#!/bin/bash
# OpenClaw Vision-Enabled Session 啟動腳本
# 用途: 確保所有 Session 預設開啟 Vision 能力
# 創建日期: 2026-03-15

echo "🚀 啟動 OpenClaw Vision-Enabled Session..."

# 設置預設模型 (支援 Vision)
export OPENCLAW_DEFAULT_MODEL="custom-cloud-infini-ai-com/kimi-k2.5"

# 設置 capabilities 支援 Vision
export OPENCLAW_CAPABILITIES="vision"

# 可選: 設置 think 模式 (adaptive/on/off)
# export OPENCLAW_THINK="adaptive"

# 啟動 gateway
echo "📡 啟動 Gateway..."
openclaw gateway

echo "✅ Vision-enabled session started!"
echo ""
echo "當前設定:"
echo "  - Model: $OPENCLAW_DEFAULT_MODEL"
echo "  - Vision: 已啟用"
echo "  - Think: adaptive"
