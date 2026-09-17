#!/bin/sh
set -eu

GAME_DIR=""
try_dir() {
  if [ -f "$1/libGalaxy64.so" ]; then
    GAME_DIR="$1"
    return 0
  fi
  return 1
}

try_dir "$HOME/.local/share/Steam/steamapps/common/Stardew Valley" || try_dir "$HOME/.steam/steam/steamapps/common/Stardew Valley" || try_dir "$HOME/.steam/root/steamapps/common/Stardew Valley" || try_dir "${XDG_DATA_HOME:-$HOME/.local/share}/Steam/steamapps/common/Stardew Valley" || try_dir "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Stardew Valley" || try_dir "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/common/Stardew Valley" || true

if [ -z "$GAME_DIR" ]; then
  for f in "$HOME/.local/share/Steam/steamapps/libraryfolders.vdf" "$HOME/.steam/steam/steamapps/libraryfolders.vdf" "$HOME/.steam/root/steamapps/libraryfolders.vdf" "${XDG_DATA_HOME:-$HOME/.local/share}/Steam/steamapps/libraryfolders.vdf" "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf" "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf"; do
    if [ -f "$f" ]; then
      paths=$(sed -n 's/.*"path"[[:space:]]*"\([^"]*\)".*/\1/p' "$f")
      old_ifs=$IFS
      IFS='
'
      for b in $paths; do
        if [ -n "$b" ] && [ -f "$b/steamapps/common/Stardew Valley/libGalaxy64.so" ]; then
          GAME_DIR="$b/steamapps/common/Stardew Valley"
          break 2
        fi
      done
      IFS=$old_ifs
    fi
  done
fi

if [ -z "$GAME_DIR" ]; then
  echo "error: Stardew Valley install not found" >&2
  exit 1
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

case "$0" in
  */*) SCRIPT_DIR=$(dirname "$0") ;;
  *) SCRIPT_DIR="." ;;
esac

if [ $# -ge 1 ]; then
  ZIP="$1"
elif [ -f "$SCRIPT_DIR/libraries.zip" ]; then
  ZIP="$SCRIPT_DIR/libraries.zip"
elif [ -f "./libraries.zip" ]; then
  ZIP="./libraries.zip"
elif [ -f "$HOME/Downloads/libraries.zip" ]; then
  ZIP="$HOME/Downloads/libraries.zip"
else
  ZIP="$TMP/libraries.zip"
  URL="https://raw.githubusercontent.com/mukulx/stardew-galaxy-fix/master/libraries.zip"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$ZIP" "$URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$ZIP" "$URL"
  else
    echo "error: libraries.zip not found and need curl or wget to download it" >&2
    exit 1
  fi
fi

BACKUP="$HOME/Downloads/galaxy-backup-original"
mkdir -p "$BACKUP"
cp -n "$GAME_DIR/libGalaxy64.so" "$BACKUP/" 2>/dev/null || cp "$GAME_DIR/libGalaxy64.so" "$BACKUP/"
cp -n "$GAME_DIR/libGalaxyCSharpGlue.so" "$BACKUP/" 2>/dev/null || cp "$GAME_DIR/libGalaxyCSharpGlue.so" "$BACKUP/"

if command -v unzip >/dev/null 2>&1; then
  unzip -o -q "$ZIP" -d "$TMP"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m zipfile -e "$ZIP" "$TMP"
else
  echo "error: need unzip or python3 to extract libraries.zip" >&2
  exit 1
fi

cp "$TMP/libGalaxy64.so" "$TMP/libGalaxyCSharpGlue.so" "$GAME_DIR/"
chmod 755 "$GAME_DIR/libGalaxy64.so" "$GAME_DIR/libGalaxyCSharpGlue.so"

echo "patched: $GAME_DIR"
echo "backup: $BACKUP"
