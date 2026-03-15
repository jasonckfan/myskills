import json
import urllib.request
import datetime

locations = [
    {"name": "黃大仙 (住處)", "lat": 22.3278, "lon": 114.1829},
    {"name": "九龍灣 (工作)", "lat": 22.3167, "lon": 114.1917},
    {"name": "深水埗 (工作)", "lat": 22.3264, "lon": 114.1553},
    {"name": "觀塘 (工作)", "lat": 22.3097, "lon": 114.2075}
]

weather_codes = {
    0: "☀️ 晴朗", 1: "🌤️ 大致晴朗", 2: "⛅ 部分時間有陽光", 3: "☁️ 多雲",
    45: "🌫️ 有霧", 48: "🌫️ 霧淞", 51: "🌧️ 微毛毛雨", 53: "🌧️ 中等毛毛雨", 55: "🌧️ 密毛毛雨",
    61: "🌧️ 微雨", 63: "🌧️ 中雨", 65: "🌧️ 大雨", 71: "❄️ 微雪", 73: "❄️ 中雪", 75: "❄️ 大雪",
    80: "🌦️ 陣雨", 81: "🌦️ 強陣雨", 82: "🌦️ 狂風陣雨", 95: "⛈️ 雷暴", 96: "⛈️ 伴有冰雹的雷暴", 99: "⛈️ 伴有大冰雹的雷暴"
}

today_str = datetime.datetime.now().strftime('%Y年%m月%d日')
report_lines = [f"早晨呀嫲嫲煩煩！☀️\n\n📅 {today_str} 專屬分區天氣報告\n"]

for loc in locations:
    url = f"https://api.open-meteo.com/v1/forecast?latitude={loc['lat']}&longitude={loc['lon']}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=Asia%2FHong_Kong"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        response = urllib.request.urlopen(req)
        data = json.loads(response.read().decode('utf-8'))
        
        current = data['current']
        daily = data['daily']
        
        temp_c = current['temperature_2m']
        humidity = current['relative_humidity_2m']
        wind = current['wind_speed_10m']
        w_code = current['weather_code']
        desc = weather_codes.get(w_code, "未知")
        
        t_max = daily['temperature_2m_max'][0]
        t_min = daily['temperature_2m_min'][0]
        precip = daily['precipitation_sum'][0]
        
        report_lines.append(f"📍 **{loc['name']}**")
        report_lines.append(f"天氣：{desc} | 現溫：{temp_c}°C | 濕度：{humidity}%")
        report_lines.append(f"預測：{t_min}°C - {t_max}°C | 降水：{precip}mm\n")
    except Exception as e:
        report_lines.append(f"📍 **{loc['name']}**\n獲取天氣資料失敗。\n")

# 獲取天文台警告資訊
try:
    warn_url = "https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=warnsum&lang=tc"
    req_warn = urllib.request.Request(warn_url, headers={'User-Agent': 'Mozilla/5.0'})
    response_warn = urllib.request.urlopen(req_warn)
    warn_data = json.loads(response_warn.read().decode('utf-8'))
    if warn_data:
        # warn_data is a dict where values are warning objects
        warnings = []
        for key, w in warn_data.items():
            if isinstance(w, dict) and 'name' in w:
                warnings.append(w['name'])
        if warnings:
            report_lines.append("⚠️ **特別天氣提示**：" + "、".join(warnings) + "\n")
except Exception:
    pass

report_lines.append("💡 溫馨提示：記得睇天氣著衫同帶遮啦！祝大家有美好嘅一日！🌈")

print("\n".join(report_lines))