#!/usr/bin/env python3
"""
JPY/HKD 匯率監控腳本
當 1 日圓兌港元低於 0.05 時發送通知到 WhatsApp 群組
"""

import yfinance as yf
import sys

def get_jpy_hkd_rate():
    """獲取 JPY/HKD 匯率"""
    try:
        # JPYHKD=X 是 Yahoo Finance 的日圓兌港元代號
        ticker = yf.Ticker("JPYHKD=X")
        data = ticker.history(period="1d")
        
        if data.empty:
            print("ERROR: 無法獲取匯率數據")
            return None
        
        # 獲取最新收盤價
        current_rate = data['Close'].iloc[-1]
        return current_rate
    except Exception as e:
        print(f"ERROR: 獲取匯率時出錯: {e}")
        return None

def main():
    threshold = 0.05  # 提醒閾值
    
    print("=" * 50)
    print("🇯🇵 JPY/HKD 匯率監控")
    print("=" * 50)
    
    rate = get_jpy_hkd_rate()
    
    if rate is None:
        print("❌ 無法獲取匯率，請檢查網絡連接")
        sys.exit(1)
    
    print(f"📊 當前匯率: 1 JPY = {rate:.5f} HKD")
    print(f"🎯 提醒閾值: {threshold:.2f} HKD")
    print("-" * 50)
    
    if rate < threshold:
        print(f"✅ 條件觸發！匯率 ({rate:.5f}) 低於 {threshold}")
        print("📱 應該發送 WhatsApp 通知")
        # 返回 0 表示需要發送通知
        sys.exit(0)
    else:
        print(f"⏳ 匯率 ({rate:.5f}) 高於閾值 ({threshold})")
        print("😴 暫時不需要通知")
        # 返回 1 表示不需要發送通知
        sys.exit(1)

if __name__ == "__main__":
    main()
