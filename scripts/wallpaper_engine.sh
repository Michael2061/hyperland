#!/bin/bash

# Prüfen ob ein Bild übergeben wurde
if [ -z "$1" ]; then
    echo "Benutzung: ./wallpaper_engine.sh /pfad/zum/bild.jpg"
    exit 1
fi

WALLPAPER="$1"

# 1. Wallpaper setzen (mit hyprpaper oder swww)
# Wenn du hyprpaper nutzt, muss die config angepasst werden.
# Hier als Beispiel mit swww (sehr beliebt für Animationen):
swww img "$WALLPAPER" --transition-type center

# 2. Farben mit pywal generieren
wal -i "$WALLPAPER"

# 3. Den Pfad-Fix für SwayOSD ausführen (damit __HOME__ ersetzt wird)
sed -i "s|__HOME__|$HOME|g" ~/.config/swayosd/style.css

# 4. SwayOSD befehlen, das Design neu zu laden
swayosd-client --reload-style

echo "🎨 Wallpaper und SwayOSD-Farben aktualisiert!"
