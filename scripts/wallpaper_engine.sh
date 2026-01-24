#!/bin/bash

# Pfade (Nutzen $HOME, damit es bei jedem User klappt)
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="$HOME/waybar_error.log"

# 1. Log-Datei neu erstellen
echo "--- System-Start: $(date) ---" > "$LOG_FILE"

# 2. Prüfen, ob das Skript bereits läuft
if pgrep -x "wallpaper_engine.sh" | grep -qv $$; then
    echo "Skript läuft bereits." >> "$LOG_FILE"
    exit 1
fi

# 3. Wallpaper & Farben
pgrep swww-daemon > /dev/null || swww-daemon &
sleep 0.5

WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "FEHLER: Kein Bild in $WALLPAPER_DIR" >> "$LOG_FILE"
    exit 1
fi

swww img "$WALLPAPER" --transition-type wipe &
wal -i "$WALLPAPER" -q

# --- DYNAMISCHE PFAD-ANPASSUNG ---
# Wir suchen nach __USER__, __SUER__ oder __HOME__ und ersetzen es durch deinen echten Pfad
sed -i "s|__USER__|$USER|g" "$WAYBAR_STYLE"
sed -i "s|__SUER__|$USER|g" "$WAYBAR_STYLE"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"
# --------------------------------

# 4. Tastatur auf DE
hyprctl keyword input:kb_layout de

# 5. Waybar NEU STARTEN
killall waybar 2>/dev/null
waybar &

echo "Setup erfolgreich für User $USER: $WALLPAPER" >> "$LOG_FILE"
