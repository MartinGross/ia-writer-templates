# iA Writer Templates

Custom preview templates for [iA Writer](https://ia.net/writer) on macOS.

## GitHub Compact

The bundled GitHub template, at a smaller type scale. The motivation: the
preview felt oversized — mostly because of the `h1`, which is twice the body
size in a column only 830px wide.

| Element | Stock GitHub | GitHub Compact |
|---|---|---|
| Body text | 16px | **13px** |
| Line height | 24px | 19.5px |
| h1 | 32px | 19.5px |
| h2 | 24px | 16.25px |
| h3 | 20px | 14.3px |
| h4 | 16px | 13px |
| h5 / h6 | 14 / 13.6px | 11.4 / 11.05px |
| Lists, blockquotes | 16px | 13px |
| Code (inline & block) | 13.6px | 11.05px |

Values measured with `tools/measure.sh`, not eyeballed.

### Tuning

Headings, code, blockquotes and lists are all defined in `em`, so **a single
number** drives the whole scale. It sits at the end of
`templates/GitHub Compact.iatemplate/Contents/Resources/github.css`:

```css
html:not(.night-mode) .markdown-body,
html.night-mode .markdown-body {
  font-size: 13px;   /* everything else follows */
}
```

After editing, bump `CFBundleVersion` in `Info.plist` — otherwise iA Writer
may not recognize the template as newer.

### Installing

[**Download the template**](https://github.com/MartinGross/ia-writer-templates/releases/latest/download/GitHub-Compact.iatemplate.zip)
— unzip, double-click, done. No clone needed.

If you already have the repo, double-click
`templates/GitHub Compact.iatemplate` instead. Either way you can also go
through *Settings → Templates → "Install Template …"*.

Installing copies the bundle into the app's sandbox container
(`~/Library/Containers/pro.writer.mac/Data/Library/`, unreadable due to TCC).
The file in this repo stays the editable source.

To remove: *Settings → Templates → "Uninstall Template"*.

### Releasing

`.github/workflows/release.yml` builds the zip and cuts the release when a
`v*` tag is pushed. `Info.plist` is the single source of truth for versions —
the workflow fails if the tag doesn't match `CFBundleShortVersionString`, or
if `CFBundleVersion` wasn't bumped past the previous release. That second
check exists because an unbumped build number installs silently and keeps the
old CSS.

```sh
# edit CFBundleShortVersionString + CFBundleVersion, commit, then:
git tag v1.4 && git push origin v1.4
```

The asset name stays constant across releases, which is what keeps the
`releases/latest/download/…` link above working.

## Two things that will bite you

**The preview has two render modes.** The toggle sits in the bottom left:
*Web* and *PDF*. PDF mode renders with `@media print`, so a rule scoped to
`@media screen` silently does nothing there — and you won't notice, because
the web preview looks correct. That is why the rules here carry no media
query at all. `tools/measure.sh` checks exactly this.

**Selectors need the right prefix.** `github-markdown-light.css` and
`-dark.css` qualify every rule with `html:not(.night-mode)` or
`html.night-mode`. A plain `.markdown-body h1 { … }` loses on specificity.
Overrides have to mirror that pattern.

Worth knowing: the GitHub template contains no `content-size-*` rules and sets
`font-size` in absolute px. The app's text size setting (*View → Text Size*,
`⌘+` / `⌘−`) has no effect on it. The bundled templates (Sans, Serif, Mono,
Duo, Quattro) do respond — they map those classes onto `--font-size` in
`style/typography-core.css`.

## Measuring

```sh
tools/measure.sh "templates/GitHub Compact.iatemplate"
```

Renders the template in headless Chrome and reads back the computed font
sizes for web, PDF and dark mode. All three must agree.

The PDF path is simulated by swapping the media queries. What this verifies is
the CSS cascade — specificity and order — not WebKit's pagination engine.

Requires Google Chrome and `python3`.

## License

This template derives from the GitHub template shipped with iA Writer, whose
CSS comes from [generate-github-markdown-css](https://github.com/sindresorhus/generate-github-markdown-css)
and is MIT licensed (Copyright © 2016 GitHub Inc.) — see `LICENSE.txt` inside
the bundle. Original work here is the size overrides at the end of
`github.css` plus `tools/`.
