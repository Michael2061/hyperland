#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

echo "--- Start: $(date) ---" >> "$LOG_FILE"

# 1. Wallpaper & Farben
# Prüfen ob swww-daemon läuft, falls nicht -> starten
pgrep swww-daemon > /dev/null || swww-daemon &
sleep 0.5

WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww img "$WALLPAPER" --transition-type wipe &
wal -i "$WALLPAPER" -q  # -q für quiet (weniger Log-Müll)
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"

# 2. Tastatur auf DE
hyprctl keyword input:kb_layout de

# 3. Waybar NEU STARTEN
killall waybar 2>/dev/null
waybar &  # Startet im Hintergrund, Terminal wird sofort wieder frei!

echo "Setup abgeschlossen: $WALLPAPER" >> "$LOG_FILE"
