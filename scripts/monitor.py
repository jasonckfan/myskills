import urllib.request
import json
import math
import subprocess
from datetime import datetime

# --- CONFIGURATION ---
SYMBOLS = ["NVDA", "TQQQ", "UDOW"]
NOTIFY_TARGET = "telegram:8262468003"
HEADERS = {'User-Agent': 'Mozilla/5.0'}

# --- INDICATOR CALCULATIONS ---

def calculate_sma(data, period):
    if len(data) < period: return None
    return sum(data[-period:]) / period

def calculate_stddev(data, period):
    if len(data) < period: return None
    subset = data[-period:]
    mean = sum(subset) / period
    variance = sum((x - mean) ** 2 for x in subset) / period
    return math.sqrt(variance)

def calculate_rsi(data, period=14):
    if len(data) < period + 1: return None
    gains, losses = [], []
    for i in range(1, len(data)):
        diff = data[i] - data[i-1]
        gains.append(max(diff, 0))
        losses.append(max(-diff, 0))
    
    avg_gain = sum(gains[:period]) / period
    avg_loss = sum(losses[:period]) / period
    for i in range(period, len(gains)):
        avg_gain = (avg_gain * (period - 1) + gains[i]) / period
        avg_loss = (avg_loss * (period - 1) + losses[i]) / period
    if avg_loss == 0: return 100
    return 100 - (100 / (1 + (avg_gain / avg_loss)))

def calculate_macd(data):
    if len(data) < 35: return None, None, None
    cur_ema12, cur_ema26 = sum(data[:12]) / 12, sum(data[:26]) / 26
    m12, m26, m9 = 2/13, 2/27, 2/10
    macd_line_full = []
    for i, p in enumerate(data):
        if i >= 12: cur_ema12 = (p - cur_ema12) * m12 + cur_ema12
        if i >= 26: cur_ema26 = (p - cur_ema26) * m26 + cur_ema26
        if i >= 26: macd_line_full.append(cur_ema12 - cur_ema26)
    signal_line = sum(macd_line_full[:9]) / 9
    for val in macd_line_full[9:]:
        signal_line = (val - signal_line) * m9 + signal_line
    return macd_line_full[-1], signal_line, macd_line_full[-1] - signal_line

# --- LOGIC ---

def check_symbol(symbol):
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}?interval=1h&range=10d"
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req) as response:
            res = json.loads(response.read())
        prices = [p for p in res['chart']['result'][0]['indicators']['quote'][0]['close'] if p is not None]
        if not prices: return None
        
        current_price = prices[-1]
        rsi = calculate_rsi(prices)
        macd, signal, hist = calculate_macd(prices)
        sma20, sma50 = calculate_sma(prices, 20), calculate_sma(prices, 50)
        std20 = calculate_stddev(prices, 20)
        bb_lower = sma20 - (2 * std20) if sma20 and std20 else None
        
        buy_signal = all(v is not None for v in [rsi, macd, signal, sma20, sma50, bb_lower]) and \
                     (rsi < 35 and macd > signal and current_price <= bb_lower * 1.01 and sma20 > sma50)
        sell_signal = rsi > 70 if rsi else False
        
        return {
            "symbol": symbol, "price": round(current_price, 2), "rsi": round(rsi, 2) if rsi else "--",
            "buy": buy_signal, "sell": sell_signal, "bb_l": round(bb_lower, 2) if bb_lower else "--"
        }
    except Exception as e:
        return {"symbol": symbol, "error": str(e)}

def notify(message):
    subprocess.run(["openclaw", "message", "send", "--target", NOTIFY_TARGET, "--message", message])

if __name__ == "__main__":
    results = []
    alerts = []
    for sym in SYMBOLS:
        res = check_symbol(sym)
        if res:
            results.append(res)
            if res.get("buy"): alerts.append(f"🟢 [BUY] {res['symbol']} @ ${res['price']} (RSI:{res['rsi']})")
            if res.get("sell"): alerts.append(f"🔴 [SELL] {res['symbol']} @ ${res['price']} (RSI:{res['rsi']})")
    
    if alerts:
        msg = "⚠️ Stock Signal Alert!\n" + "\n".join(alerts)
        notify(msg)
    else:
        print("No alerts triggered.")
    print(json.dumps(results, indent=2))

