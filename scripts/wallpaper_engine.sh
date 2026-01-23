#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

echo "--- Systemd Start: $(date) ---" >> "$LOG_FILE"

# 1. Wallpaper & Farben (einmalig)
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww-daemon &
sleep 1
swww img "$WALLPAPER" --transition-type wipe
wal -i "$WALLPAPER"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"

# 2. Tastatur auf DE
hyprctl keyword input:kb_layout de

# 3. Waybar starten (OHNE & am Ende, damit Systemd sie überwachen kann!)
# Wir nutzen 'exec', damit Waybar zum Hauptprozess des Services wird
exec waybar
