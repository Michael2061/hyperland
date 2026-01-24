#!/bin/bash

# Pfade
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WALLPAPER="$HOME/Pictures/Wallpapers/rosie.jpg"

# 1. Prüfen, ob Rosie da ist, sonst Zufallsbild
if [ ! -f "$WALLPAPER" ]; then
    echo "⚠️ Rosie nicht gefunden, lade Zufallsbild..."
    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | shuf -n 1)
fi

# 2. Pywal & Wallpaper setzen
wal -q -i "$WALLPAPER"
swww img "$WALLPAPER" --transition-step 20 --transition-fps 60 --transition-type grow

# 3. Farben aus Pywal in Variablen laden (für den Direkt-Ersatz)
COLOR0=$(xrdb -query | grep 'color0:' | awk '{print $2}')
COLOR1=$(xrdb -query | grep 'color1:' | awk '{print $2}')
COLOR2=$(xrdb -query | grep 'color2:' | awk '{print $2}')
COLOR3=$(xrdb -query | grep 'color3:' | awk '{print $2}')
COLOR4=$(xrdb -query | grep 'color4:' | awk '{print $2}')
COLOR5=$(xrdb -query | grep 'color5:' | awk '{print $2}')
COLOR6=$(xrdb -query | grep 'color6:' | awk '{print $2}')
FOREGROUND=$(xrdb -query | grep 'foreground:' | awk '{print $2}')

# 4. WAYBAR STYLE REPARIEREN & FARBEN EINTRAGEN
# Erst Benutzerpfade fixen (wie in deinem alten Skript)
sed -i "s|__USER__|$USER|g" "$WAYBAR_STYLE"
sed -i "s|__HOME__|$HOME|g" "$WAYBAR_STYLE"

# Jetzt die Farben direkt in die CSS schreiben (anhand der /* cX */ Kommentare)
sed -i "s/color: #.* !important; \/\* c4 \*\//color: $COLOR4 !important; \/\* c4 \*\//" "$WAYBAR_STYLE"
sed -i "s/color: #.* !important; \/\* c3 \*\//color: $COLOR3 !important; \/\* c3 \*\//" "$WAYBAR_STYLE"
sed -i "s/color: #.* !important; \/\* c2 \*\//color: $COLOR2 !important; \/\* c2 \*\//" "$WAYBAR_STYLE"
sed -i "s/color: #.* !important; \/\* c1 \*\//color: $COLOR1 !important; \/\* c1 \*\//" "$WAYBAR_STYLE"
sed -i "s/color: #.* !important; \/\* c6 \*\//color: $COLOR6 !important; \/\* c6 \*\//" "$WAYBAR_STYLE"
sed -i "s/color: #.* !important; \/\* c5 \*\//color: $COLOR5 !important; \/\* c5 \*\//" "$WAYBAR_STYLE"

# 5. SDDM (LOGIN SCREEN) AKTUALISIEREN
# Hintergrundbild für Login-Screen kopieren
sudo cp "$WALLPAPER" /usr/share/sddm/themes/sugar-candy/Backgrounds/current_bg.jpg

# Farben direkt in die theme.conf von SDDM schreiben
SDDM_CONF="/usr/share/sddm/themes/sugar-candy/theme.conf"
sudo sed -i "s|^background=.*|background=Backgrounds/current_bg.jpg|" "$SDDM_CONF"
sudo sed -i "s|^mainColor=.*|mainColor=\"$COLOR4\"|" "$SDDM_CONF"
sudo sed -i "s|^accentColor=.*|accentColor=\"$COLOR4\"|" "$SDDM_CONF"
sudo sed -i "s|^faceColor=.*|faceColor=\"$COLOR0\"|" "$SDDM_CONF"
sudo sed -i "s|^fontColor=.*|fontColor=\"$FOREGROUND\"|" "$SDDM_CONF"

# 6. Waybar sicher neu starten
killall waybar 2>/dev/null
sleep 0.5
waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &

echo "✅ Alles erledigt: Wallpaper, Waybar & Login-Screen sind synchron!"
