import urllib.request
import csv
import sqlite3
import os
import io
from datetime import datetime

# URLs
CSV_URL = "https://online-price-watch.consumer.org.hk/opw/opendata/pricewatch_zh-Hant.csv"
# Database path
DB_DIR = os.path.expanduser("~/.openclaw/workspace/data")
DB_PATH = os.path.join(DB_DIR, "pricewatch.db")

def init_db():
    os.makedirs(DB_DIR, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    # Create table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS prices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            category1 TEXT,
            category2 TEXT,
            category3 TEXT,
            item_code TEXT,
            brand TEXT,
            item_name TEXT,
            supermarket TEXT,
            price REAL,
            offer TEXT,
            UNIQUE(date, item_code, supermarket)
        )
    ''')
    conn.commit()
    return conn

def download_and_sync():
    print(f"Downloading CSV from {CSV_URL}...")
    req = urllib.request.Request(CSV_URL, headers={'User-Agent': 'Mozilla/5.0'})
    
    with urllib.request.urlopen(req) as response:
        csv_data = response.read().decode('utf-8')
    
    conn = init_db()
    cursor = conn.cursor()
    today_str = datetime.now().strftime('%Y-%m-%d')
    
    print(f"Parsing and inserting data into SQLite ({DB_PATH})...")
    reader = csv.reader(io.StringIO(csv_data))
    header = next(reader, None)  # Skip header
    
    count = 0
    for row in reader:
        if len(row) < 9:
            continue
            
        category1, category2, category3, item_code, brand, item_name, supermarket, price_str, offer = row[:9]
        
        try:
            price = float(price_str)
        except ValueError:
            price = 0.0
            
        cursor.execute('''
            INSERT OR REPLACE INTO prices 
            (date, category1, category2, category3, item_code, brand, item_name, supermarket, price, offer)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (today_str, category1, category2, category3, item_code, brand, item_name, supermarket, price, offer))
        count += 1

    conn.commit()
    conn.close()
    print(f"Successfully synced {count} price records for {today_str}.")

if __name__ == "__main__":
    download_and_sync()
