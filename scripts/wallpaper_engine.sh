#!/bin/bash

# Pfade definieren
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WALLPAPER="$HOME/Pictures/Wallpapers/rosie.png"
SDDM_BG_DIR="/usr/share/sddm/themes/sugar-candy/Backgrounds"
SDDM_FACE_DIR="/usr/share/sddm/faces"

echo "🎨 Rosie-Engine: Synchronisiere Desktop, SDDM und Avatar..."

# 1. Pywal & Wallpaper setzen
if [ -f "$WALLPAPER" ]; then
    wal -q -i "$WALLPAPER"
    swww img "$WALLPAPER" --transition-type wipe
else
    # Fallback, falls rosie.png fehlt
    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | shuf -n 1)
    wal -q -i "$WALLPAPER"
    swww img "$WALLPAPER"
fi

# 2. SDDM Hintergrund & Avatar (Rechte-Check vorausgesetzt)
if [ -d "$SDDM_BG_DIR" ]; then
    cp "$WALLPAPER" "$SDDM_BG_DIR/current_bg.png"
    echo "🖥️ SDDM Hintergrund aktualisiert."
fi

if [ -d "$SDDM_FACE_DIR" ]; then
    cp "$WALLPAPER" "$SDDM_FACE_DIR/$USER.face.icon"
    echo "👤 SDDM Avatar aktualisiert."
fi

# 3. Hyprland Farben exportieren
COLOR_VAL=$(cat "$HOME/.cache/wal/colors" | sed -n '2p' | sed 's/#//')
echo "\$color1 = rgb($COLOR_VAL)" > "$HOME/.cache/wal/colors-hyprland.conf"

# 4. Caches für Hyprlock
cp "$WALLPAPER" "$HOME/.cache/current_wallpaper.png"
cp "$WALLPAPER" "$HOME/.cache/rosie_avatar.png"

# 5. Waybar Pfade fixen
if [ -f "$WAYBAR_STYLE" ]; then
    sed -i "s|/home/[^/]*|/home/$USER|g" "$WAYBAR_STYLE"
fi

# 6. Alles neu laden
hyprctl reload
killall waybar 2>/dev/null
waybar &

echo "✅ Alles erledigt!"