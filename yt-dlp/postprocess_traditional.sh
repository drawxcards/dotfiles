#!/bin/bash
set -e

FILE="$1"

# Convert file path (rename if needed)
DIR=$(dirname "$FILE")
BASENAME=$(basename "$FILE")
NEWNAME=$(echo "$BASENAME" | opencc -c s2t.json)

if [ "$BASENAME" != "$NEWNAME" ]; then
  mv "$DIR/$BASENAME" "$DIR/$NEWNAME"
  FILE="$DIR/$NEWNAME"
fi

# Convert ID3 tags (title, artist, album, etc.)
# Requires eyeD3 (Python tool) or mutagen
if command -v eyeD3 >/dev/null 2>&1; then
  TITLE=$(eyeD3 --no-color "$FILE" | grep "title:" | cut -d':' -f2- | xargs | opencc -c s2t.json)
  ARTIST=$(eyeD3 --no-color "$FILE" | grep "artist:" | cut -d':' -f2- | xargs | opencc -c s2t.json)
  ALBUM=$(eyeD3 --no-color "$FILE" | grep "album:" | cut -d':' -f2- | xargs | opencc -c s2t.json)

  eyeD3 --title="$TITLE" --artist="$ARTIST" --album="$ALBUM" "$FILE"
fi
