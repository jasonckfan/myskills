#!/bin/bash
# Movie folder new content checker

MOVIE_PATH="/volume1/movie"
STATE_FILE="/tmp/movie-folders.state"
REPORT=""

# Get current folders (top-level only)
CURRENT_FOLDERS=$(sshpass -p Jason_Fan1209 ssh -o StrictHostKeyChecking=no jasonckfan@192.168.1.76 "ls -1t \"$MOVIE_PATH/\" 2>/dev/null" | head -50)

if [ -f "$STATE_FILE" ]; then
    PREVIOUS_FOLDERS=$(cat "$STATE_FILE")
    
    # Find new folders
    NEW_FOLDERS=$(echo "$CURRENT_FOLDERS" | while read folder; do
        if ! echo "$PREVIOUS_FOLDERS" | grep -q "^${folder}$"; then
            echo "$folder"
        fi
    done)
    
    if [ -n "$NEW_FOLDERS" ]; then
        REPORT="📁 Movie Folder New Content:"
        echo "$NEW_FOLDERS" | while read folder; do
            REPORT="$REPORT\n- $folder"
        done
        echo -e "$REPORT"
    else
        echo "No new movie folders today"
    fi
else
    echo "First run - initializing state file"
fi

# Save current state
echo "$CURRENT_FOLDERS" > "$STATE_FILE"
