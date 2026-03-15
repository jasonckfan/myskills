#!/usr/bin/env python3
"""使用 Zeroconf 發現 HomePod mini"""
import socket
from zeroconf import Zeroconf, ServiceBrowser, ServiceListener

class HomePodListener(ServiceListener):
    def __init__(self):
        self.homepods = []
    
    def add_service(self, zc, type_, name):
        info = zc.get_service_info(type_, name)
        if info:
            print(f"發現: {name}")
            print(f"  地址: {socket.inet_ntoa(info.addresses[0]) if info.addresses else 'N/A'}")
            print(f"  端口: {info.port}")
            print(f"  屬性: {info.properties}")
            self.homepods.append((name, info))
    
    def remove_service(self, zc, type_, name):
        print(f"移除: {name}")
    
    def update_service(self, zc, type_, name):
        print(f"更新: {name}")

print("正在掃描 HomePod mini (AirPlay 服務)...")
print("=" * 50)

zeroconf = Zeroconf()
listener = HomePodListener()

# 掃描 AirPlay 服務
browser = ServiceBrowser(zeroconf, "_raop._tcp.local.", listener)

import time
time.sleep(5)

print("=" * 50)
if listener.homepods:
    print(f"共發現 {len(listener.homepods)} 個 AirPlay 裝置")
else:
    print("未發現任何 AirPlay 裝置")
    print("\n可能原因：")
    print("1. HomePod mini 未開啟或不在同一網絡")
    print("2. 防火牆阻擋 mDNS 廣播")
    print("3. 需要手動在 Mac 上配對 HomePod")

zeroconf.close()
