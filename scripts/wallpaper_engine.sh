#!/bin/bash

# Pfade definieren
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
SWAYOSD_STYLE="$HOME/.config/swayosd/style.css"
LOG_FILE="$HOME/waybar_error.log"

# Log-Datei neu starten
echo "--- Start Log: $(date) ---" > "$LOG_FILE"

# 1. Bild wählen
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "❌ Fehler: Keine Bilder gefunden in $WALLPAPER_DIR" >> "$LOG_FILE"
    exit 1
fi

# 2. Hintergrund & Farben
echo "🖼️ Setze Wallpaper: $WALLPAPER" >> "$LOG_FILE"
# Startet den Daemon falls er nicht läuft und setzt das Bild
swww-daemon &> /dev/null &
sleep 1
swww img "$WALLPAPER" --transition-type wipe >> "$LOG_FILE" 2>&1
wal -i "$WALLPAPER" >> "$LOG_FILE" 2>&1

# 3. Pfade sicherstellen & sed
mkdir -p ~/.config/swayosd
touch "$SWAYOSD_STYLE"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE" 2>> "$LOG_FILE"
sed -i "s|__HOME__|$HOME|g" "$SWAYOSD_STYLE" 2>> "$LOG_FILE"

# 4. Waybar Neustart & Tastatur-Force
echo "🔄 Initialisiere Waybar..." >> "$LOG_FILE"
killall -9 waybar 2>/dev/null
sleep 2

# Tastatur auf Deutsch zwingen
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl keyword input:kb_layout de >> "$LOG_FILE" 2>&1
    echo "⌨️ Tastatur auf DE gesetzt." >> "$LOG_FILE"
fi

# WAYBAR START MIT AUTOMATISCHEM RESTART BEI CRASH
echo "🚀 Starte Waybar Prozess..." >> "$LOG_FILE"

start_waybar() {
    # Startet Waybar im Hintergrund und schreibt Fehler ins Log
    (waybar 2>> "$LOG_FILE" &)
}

start_waybar

# Wächter: Prüfen ob Waybar nach 5 Sekunden noch lebt
sleep 5
if ! pgrep -x "waybar" > /dev/null; then
    echo "⚠️ Waybar wegen Broken Pipe abgestürzt. Zweiter Versuch..." >> "$LOG_FILE"
    # Nochmal Umgebungsvariablen auffrischen für diesen Prozess
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
    sleep 2
    start_waybar
fi

# SwayOSD Check
if pgrep -x "swayosd-server" > /dev/null; then
    swayosd-client --reload-style >> "$LOG_FILE" 2>&1
else
    echo "⚠️ SwayOSD Server nicht erreichbar - überspringe Reload." >> "$LOG_FILE"
fi

echo "--- Log Ende ---" >> "$LOG_FILE"
