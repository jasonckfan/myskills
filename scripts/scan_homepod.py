#!/usr/bin/env python3
"""掃描 HomePod mini 並發送 TTS"""
import asyncio
import pyatv

async def scan_homepods():
    """掃描網絡上的 HomePod"""
    print("正在掃描 HomePod mini...")
    atvs = await pyatv.scan(loop=asyncio.get_event_loop())
    
    if not atvs:
        print("未找到任何 Apple TV 或 HomePod")
        return None
    
    print(f"找到 {len(atvs)} 個裝置:")
    for i, atv in enumerate(atvs):
        print(f"{i+1}. {atv.name} ({atv.address}) - {atv.device_info.model}")
    
    return atvs

if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    atvs = loop.run_until_complete(scan_homepods())
