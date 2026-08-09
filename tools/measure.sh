#!/usr/bin/env bash
#
# Misst die tatsächlich gerenderten Schriftgrößen einer iA-Writer-Vorlage.
#
# Hintergrund: die Vorschau in iA Writer hat zwei Render-Modi (Web und PDF,
# Umschalter unten links). Der PDF-Modus rendert mit @media print. Eine Regel
# in @media screen bleibt dort wirkungslos — ein Fehler, der beim bloßen
# Hinsehen nicht auffällt, weil die Web-Vorschau korrekt aussieht.
#
# Das Skript prüft deshalb drei Pfade: Web, PDF und Dark Mode.
# Der PDF-Pfad wird simuliert, indem die Media-Queries getauscht werden —
# geprüft wird damit die Kaskade (Spezifität und Reihenfolge), nicht die
# Seitenumbruch-Engine von WebKit.
#
# Aufruf:  tools/measure.sh "templates/GitHub Kompakt.iatemplate"

set -euo pipefail

TEMPLATE="${1:?Pfad zum .iatemplate-Bundle angeben}"
RES="$TEMPLATE/Contents/Resources"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PROBE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/probe.html"

[ -d "$RES" ]     || { echo "Kein Resources-Ordner in $TEMPLATE" >&2; exit 1; }
[ -x "$CHROME" ]  || { echo "Google Chrome nicht gefunden: $CHROME" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

render () {  # render <verzeichnis>
  "$CHROME" --headless --disable-gpu --no-first-run \
            --window-size=1300,900 --virtual-time-budget=2000 \
            --dump-dom "file://$1/probe.html" 2>/dev/null \
    | sed -n '/<pre id="out">/,/<\/pre>/p' | sed 's/<[^>]*>//g'
}

# --- Web (Light) ---
mkdir -p "$WORK/web"; cp "$RES"/*.css "$WORK/web/"; cp "$PROBE" "$WORK/web/probe.html"

# --- Dark: identisch, nur mit .night-mode auf <html> ---
cp -R "$WORK/web" "$WORK/dark"
sed 's|<html>|<html class="night-mode">|' "$PROBE" > "$WORK/dark/probe.html"

# --- PDF: print-Regeln aktiv schalten, screen-Regeln aus ---
cp -R "$WORK/web" "$WORK/pdf"
python3 - "$WORK/pdf/github.css" <<'PY'
import sys, re
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = s.replace("@import 'github-markdown-dark.css' screen;",
              "@import 'github-markdown-dark.css' not all;")
s = s.replace("@import 'github-markdown-light.css' screen, print;",
              "@import 'github-markdown-light.css' screen;")
s = re.sub(r'@media screen', '@media not all', s)   # screen-Regeln deaktivieren
s = re.sub(r'@media print',  '@media screen', s)    # print-Regeln aktivieren
open(p, 'w', encoding='utf-8').write(s)
PY

for mode in web pdf dark; do
  echo "=== ${mode} ==="
  render "$WORK/$mode"
done

echo
echo "Web, PDF und Dark müssen dieselben Werte liefern."
