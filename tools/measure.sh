#!/usr/bin/env bash
#
# Measures the actually rendered font sizes of an iA Writer template.
#
# Background: the iA Writer preview has two render modes (Web and PDF, toggled
# in the bottom left). PDF mode renders with @media print, so a rule scoped to
# @media screen silently does nothing there — a mistake that is invisible to
# the eye, because the web preview still looks correct.
#
# This script therefore checks three paths: web, PDF and dark mode.
# The PDF path is simulated by swapping the media queries, which verifies the
# cascade — specificity and order — not WebKit's pagination engine.
#
# Usage:  tools/measure.sh "templates/GitHub Compact.iatemplate"

set -euo pipefail

TEMPLATE="${1:?pass the path to a .iatemplate bundle}"
RES="$TEMPLATE/Contents/Resources"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PROBE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/probe.html"

[ -d "$RES" ]    || { echo "No Resources folder in $TEMPLATE" >&2; exit 1; }
[ -x "$CHROME" ] || { echo "Google Chrome not found at $CHROME" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

render () {  # render <directory>
  "$CHROME" --headless --disable-gpu --no-first-run \
            --window-size=1300,900 --virtual-time-budget=2000 \
            --dump-dom "file://$1/probe.html" 2>/dev/null \
    | sed -n '/<pre id="out">/,/<\/pre>/p' | sed 's/<[^>]*>//g'
}

# --- web (light) ---
mkdir -p "$WORK/web"; cp "$RES"/*.css "$WORK/web/"; cp "$PROBE" "$WORK/web/probe.html"

# --- dark: identical, only .night-mode added to <html> ---
cp -R "$WORK/web" "$WORK/dark"
sed 's|<html>|<html class="night-mode">|' "$PROBE" > "$WORK/dark/probe.html"

# --- pdf: activate the print rules, disable the screen ones ---
cp -R "$WORK/web" "$WORK/pdf"
python3 - "$WORK/pdf/github.css" <<'PY'
import sys, re
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = s.replace("@import 'github-markdown-dark.css' screen;",
              "@import 'github-markdown-dark.css' not all;")
s = s.replace("@import 'github-markdown-light.css' screen, print;",
              "@import 'github-markdown-light.css' screen;")
s = re.sub(r'@media screen', '@media not all', s)   # disable screen rules
s = re.sub(r'@media print',  '@media screen', s)    # activate print rules
open(p, 'w', encoding='utf-8').write(s)
PY

for mode in web pdf dark; do
  echo "=== ${mode} ==="
  render "$WORK/$mode"
done

echo
echo "Web, PDF and dark must all report the same values."
