#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
# Zufälliges Bild wählen
WALLPAPER=$(ls $WALLPAPER_DIR/*.jpg | shuf -n 1)

# 1. Bild setzen & Farben generieren
swww img "$WALLPAPER" --transition-type wipe
wal -i "$WALLPAPER"

# 2. DER TRICK FÜR HYPRLOCK:
# Wir erstellen einen festen Link, den hyprlock immer finden kann
ln -sf "$WALLPAPER" "$HOME/Pictures/Wallpapers/current_wallpaper.jpg"

# 3. Pfade in den Styles fixen
sed -i "s|__HOME__|$HOME|g" ~/.config/waybar/style.css
sed -i "s|__HOME__|$HOME|g" ~/.config/swayosd/style.css

# 4. Reloads
killall -SIGUSR2 waybar
swayosd-client --reload-style
