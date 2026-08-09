# iA Writer Templates

Eigene Vorschau-Vorlagen für [iA Writer](https://ia.net/writer) (macOS).

## GitHub Kompakt

Die eingebaute GitHub-Vorlage in kleinerer Typografie. Anlass war, dass die
Vorschau zu groß wirkte — vor allem durch das h1, das im Original doppelt so
groß ist wie der Fließtext, in einer nur 830px breiten Spalte.

| Element | Original GitHub | GitHub Kompakt |
|---|---|---|
| Fließtext | 16px | **13px** |
| Zeilenhöhe | 24px | 19,5px |
| h1 | 32px | 19,5px |
| h2 | 24px | 16,25px |
| h3 | 20px | 14,3px |
| h4 | 16px | 13px |
| h5 / h6 | 14 / 13,6px | 11,4 / 11,05px |
| Listen, Zitate | 16px | 13px |
| Code (inline & Block) | 13,6px | 11,05px |

Werte mit `tools/measure.sh` gemessen, nicht geschätzt.

### Anpassen

Alle Überschriften, Code, Zitate und Listen sind in `em` definiert. **Eine
einzige Zahl** steuert die gesamte Skala — am Ende von
`templates/GitHub Kompakt.iatemplate/Contents/Resources/github.css`:

```css
html:not(.night-mode) .markdown-body,
html.night-mode .markdown-body {
  font-size: 13px;   /* alles andere hängt daran */
}
```

Nach dem Ändern `CFBundleVersion` in der `Info.plist` hochzählen, sonst
erkennt iA Writer die Vorlage unter Umständen nicht als neuer.

### Installieren

Doppelklick auf das `.iatemplate`-Bundle — iA Writer übernimmt es. Alternativ
über *Einstellungen → Templates → „Template installieren …"*.

Das Bundle wird dabei in den Sandbox-Container der App kopiert
(`~/Library/Containers/pro.writer.mac/Data/Library/`, per TCC nicht lesbar).
Die Datei in diesem Repo bleibt die bearbeitbare Quelle.

Deinstallieren über *Einstellungen → Templates → „Template deinstallieren"*.

## Zwei Fallstricke

**Die Vorschau hat zwei Render-Modi.** Der Umschalter sitzt unten links:
*Web* und *PDF*. Der PDF-Modus rendert mit `@media print`. Eine Anpassung in
`@media screen` bleibt dort wirkungslos — und fällt nicht auf, weil die
Web-Vorschau korrekt aussieht. Die Regeln hier stehen deshalb bewusst ohne
Media-Query. `tools/measure.sh` prüft genau das.

**Die Selektoren brauchen das richtige Präfix.** `github-markdown-light.css`
und `-dark.css` qualifizieren jede Regel mit `html:not(.night-mode)` bzw.
`html.night-mode`. Ein schlichtes `.markdown-body h1 { … }` verliert die
Spezifitätsschlacht. Overrides müssen das Muster spiegeln.

Nebenbei: die GitHub-Vorlage enthält keine `content-size-*`-Regeln und setzt
`font-size` absolut in px. Die Textgrößen-Einstellung der App
(*Darstellung → Textgrösse*, `⌘+` / `⌘−`) läuft daran vorbei. Die eingebauten
Vorlagen (Sans, Serif, Mono, Duo, Quattro) reagieren darauf sehr wohl — sie
mappen die Klassen in `style/typography-core.css` auf `--font-size`.

## Messen

```sh
tools/measure.sh "templates/GitHub Kompakt.iatemplate"
```

Rendert die Vorlage in Headless-Chrome und liest die berechneten
Schriftgrößen für Web, PDF und Dark Mode aus. Alle drei müssen übereinstimmen.

Der PDF-Pfad wird simuliert, indem die Media-Queries getauscht werden. Geprüft
wird damit die CSS-Kaskade — Spezifität und Reihenfolge — nicht die
Seitenumbruch-Engine von WebKit.

Voraussetzungen: Google Chrome, `python3`.

## Lizenz

Die Vorlage leitet sich von der mit iA Writer ausgelieferten GitHub-Vorlage ab.
Deren CSS stammt aus [generate-github-markdown-css](https://github.com/sindresorhus/generate-github-markdown-css)
und steht unter MIT (Copyright © 2016 GitHub Inc.) — siehe `LICENSE.txt` im
Bundle. Eigener Anteil sind die Größenanpassungen am Ende von `github.css`
sowie `tools/`.
