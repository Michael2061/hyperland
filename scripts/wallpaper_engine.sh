#!/bin/bash

# Pfade
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
# Dein neues Wunschbild
MY_FAV_WALLPAPER="$WALLPAPER_DIR/cyberpunk_car.jpg"

# 1. Log neu starten
echo "--- Start: $(date) ---" > "$LOG_FILE"

# 2. Wallpaper auswählen
# Wir prüfen: Existiert dein Wunschbild?
if [ -f "$MY_FAV_WALLPAPER" ]; then
    WALLPAPER="$MY_FAV_WALLPAPER"
else
    # Falls das Bild fehlt, nimm ein zufälliges aus dem Ordner
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
fi

# Falls der Ordner komplett leer ist, nehmen wir ein Online-Bild als Notfall-Backup
if [ -z "$WALLPAPER" ]; then
    echo "⚠️ Kein lokales Bild gefunden. Lade Notfall-Wallpaper..." >> "$LOG_FILE"
    wget -O "$MY_FAV_WALLPAPER" "https://images.peakpx.com/wallpaper/342/261/3440x1440/cyberpunk-car-neon-artwork-wallpaper-preview.jpg" -q
    WALLPAPER="$MY_FAV_WALLPAPER"
fi

# Farben generieren & Wallpaper setzen
swww img "$WALLPAPER" --transition-type wipe &
wal -i "$WALLPAPER" -q

# 3. CSS DYNAMISCH REPARIEREN
if [ ! -f "${WAYBAR_STYLE}.bak" ]; then
    cp "$WAYBAR_STYLE" "${WAYBAR_STYLE}.bak"
fi

sed "s|__USER__|$USER|g" "${WAYBAR_STYLE}.bak" > "$WAYBAR_STYLE"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"

# 4. Waybar sicher neu starten
killall waybar 2>/dev/null
sleep 0.5
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

echo "Setup erfolgreich für $USER: $WALLPAPER" >> "$LOG_FILE"
