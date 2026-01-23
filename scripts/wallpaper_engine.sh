#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

echo "--- BOOT LOG: $(date) ---" > "$LOG_FILE"

# 1. Wallpaper & Pywal
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww-daemon &> /dev/null &
sleep 2
swww img "$WALLPAPER" --transition-type wipe >> "$LOG_FILE" 2>&1
wal -i "$WALLPAPER" >> "$LOG_FILE" 2>&1
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE" 2>> "$LOG_FILE"

# 2. Die Waybar-Schleife
(
    for i in {1..15}; do
        echo "🚀 Versuch $i: Starte Waybar..." >> "$LOG_FILE"

        # Tastatur auf DE
        hyprctl keyword input:kb_layout de >> "$LOG_FILE" 2>&1

        killall -9 waybar 2>/dev/null
        sleep 5 # Kurze Pause für den Grafik-Socket

        waybar 2>> "$LOG_FILE" &

        sleep 8

        if pgrep -x "waybar" > /dev/null; then
            echo "✅ ERFOLG: Waybar läuft nach Versuch $i!" >> "$LOG_FILE"
            # BENACHRICHTIGUNG BEI ERFOLG
            notify-send -u low -i "emblem-ok-symbolic" "Waybar" "Erfolgreich geladen (Versuch $i)"
            exit 0
        fi

        echo "⚠️ Versuch $i abgestürzt." >> "$LOG_FILE"
    done

    # BENACHRICHTIGUNG BEI TOTALAUSFALL
    notify-send -u critical -i "dialog-error" "Waybar Error" "Konnte nach 15 Versuchen nicht starten!"
) &

echo "✅ Skript läuft im Hintergrund..." >> "$LOG_FILE"
