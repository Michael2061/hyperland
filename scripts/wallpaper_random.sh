#!/bin/bash

# Ordner mit deinen Wallpapern
DIR="$HOME/Pictures/Wallpapers"

# Ein zufälliges Bild auswählen
PICS=($DIR/*)
RANDOM_PIC=${PICS[$RANDOM % ${#PICS[@]}]}

# 1. Wallpaper setzen (über Hyprpaper)
# Hinweis: Da du 3 Monitore hast, setzen wir es hier für alle 3 gleich.
hyprctl hyprpaper wallpaper "DP-1,$RANDOM_PIC"
hyprctl hyprpaper wallpaper "DP-2,$RANDOM_PIC"
hyprctl hyprpaper wallpaper "DP-3,$RANDOM_PIC"

# 2. Farben generieren
wal -i "$RANDOM_PIC"

# 3. Waybar neu laden, um Farben zu übernehmen
killall waybar
waybar &
