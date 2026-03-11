---
name: nvda-stock-monitor
description: Monitors NVDA stock price using technical indicators (RSI, MACD, Bollinger Bands, SMA) and determines buy/sell opportunities. Use when the user wants to check NVDA stock signals, setup price alerts, or automate technical analysis for NVIDIA.
---

# NVDA Stock Monitor

This skill implements a technical analysis monitoring system for NVIDIA (NVDA).

## Logic Overview

### Buy Signals (Combined Conditions)
- **RSI < 35**: Overbought condition.
- **MACD Gold Cross**: MACD line crosses above the Signal line.
- **Bollinger Lower Band**: Price touches or falls below the lower boundary.
- **SMA Alignment**: SMA20 > SMA50 (Short-term bullish trend).

### Sell/Exit Signals
- **RSI > 70**: Overbought threshold.
- **Target**: +10% profit.
- **Trailing Stop**: -15% stop-loss.

## Usage

### 1. Manual Check
Run the monitoring script to get a JSON report of the current price and indicators:
```bash
python3 {baseDir}/scripts/monitor.py
```

### 2. Automated Alerts
You can set up a cron job to run this check every hour during US market hours (21:30 - 04:00 HKT):
```bash
openclaw cron add --name "NVDA Price Monitor" --cron "30 21-23,0-3 * * 1-5" --command "python3 {baseDir}/scripts/monitor.py"
```

## Troubleshooting
- **No Data**: Ensure the system has internet access to reach `query1.finance.yahoo.com`.
- **Indicators Missing**: The script needs at least 5 days of hourly data (approx. 35-50 points) to compute MACD and SMA50 correctly.
