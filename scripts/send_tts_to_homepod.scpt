-- AppleScript: 發送 TTS 到 HomePod mini
-- 用法: osascript send_tts_to_homepod.scpt "范治國你好"

on run argv
    if (count of argv) = 0 then
        display dialog "請提供文字訊息" buttons {"確定"} default button "確定"
        return
    end if
    
    set theText to item 1 of argv
    
    tell application "System Preferences"
        activate
        set current pane to pane "com.apple.preference.sound"
    end tell
    
    tell application "System Events"
        tell process "System Preferences"
            delay 0.5
            click radio button "輸出" of tab group 1 of window "聲音"
            delay 0.5
            
            -- 嘗試選擇 HomePod mini
            try
                select row 1 of table 1 of scroll area 1 of tab group 1 of window "聲音" where name of static text 1 contains "HomePod"
            on error
                display notification "未找到 HomePod mini，請確保已連接" with title "TTS 發送失敗"
                return
            end try
        end tell
    end tell
    
    -- 朗讀文字
    say theText using "Ting-Ting"
    
    display notification "已發送到 HomePod mini: " & theText with title "TTS 發送成功"
end run
