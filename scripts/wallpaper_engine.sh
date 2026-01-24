#!/bin/bash

# Pfade
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

# 1. Log-Datei bei jedem Start NEU erstellen (löscht alten Inhalt)
echo "--- System-Start: $(date) ---" > "$LOG_FILE"

# 2. Prüfen, ob das Skript bereits läuft (Sperre)
if pgrep -x "wallpaper_engine.sh" | grep -qv $$; then
    echo "Skript läuft bereits, breche ab." >> "$LOG_FILE"
    exit 1
fi

# 3. Wallpaper & Farben
# Prüfen ob swww-daemon läuft
pgrep swww-daemon > /dev/null || swww-daemon &
sleep 0.5

# Zufälliges Bild finden
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "FEHLER: Kein Wallpaper gefunden in $WALLPAPER_DIR" >> "$LOG_FILE"
    exit 1
fi

swww img "$WALLPAPER" --transition-type wipe &
wal -i "$WALLPAPER" -q
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"

# 4. Tastatur auf DE
hyprctl keyword input:kb_layout de

# 5. Waybar NEU STARTEN
killall waybar 2>/dev/null
waybar &

echo "Setup erfolgreich abgeschlossen: $WALLPAPER" >> "$LOG_FILE"
