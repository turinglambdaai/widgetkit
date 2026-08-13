# widgetkit

A curated collection of GUI widgets for Racket. It gathers the controls almost every `racket/gui` app wants but that the core toolkit leaves you to build yourself — tooltips and placeholder text, grid layout, date entry, virtualized lists, status bars, spinners and steppers — behind a single `(require widgetkit)`, with one manual and a runnable example per widget.

![Racket](https://img.shields.io/badge/Racket-9F1D20?logo=racket&logoColor=white) [![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

**English** · [中文](README.zh-CN.md)

## Features

- **One require, one manual** — the commonly-needed controls in one place, instead of hunting across packages
- **Curated, not redundant** — every widget fills a gap core `racket/gui` leaves open; nothing duplicates the toolkit
- **Reuse over rewrite** — when a mature package already does the job, widgetkit depends on it; new code only where no good solution exists
- **Runnable example per widget** — plus a showcase gallery you can click through
- **Fully contracted API** — every widget method and key argument is runtime-checked via `provide/contract` + `class/c`, so misuse fails fast with clear blame (and gives AI agents a machine-readable API)

## Requirements

| Dependency | Purpose / Version |
|------------|-------------------|
| Racket | 8.0 or later |
| `gui-lib` | the `racket/gui` toolkit (pulled in automatically) |

## Quick Start

### 1. Clone

```bash
git clone https://github.com/turinglambdaai/widgetkit.git
cd widgetkit
```

### 2. Install

```bash
raco pkg install
```

### 3. Run the showcase

```bash
racket examples/showcase.rkt
```

### 4. Use it

```racket
#lang racket/base
(require racket/gui/base
         widgetkit)

(define f (new frame% [label "my app"] [width 400] [height 160]))
(new stepper% [parent f] [min-value 0] [max-value 20] [initial 5])
(new status-bar% [parent f] [show-progress #t] [initial-message "Ready."])
(send f show #t)
```

## Included widgets

### Gap-filling (new, MIT)

| Widget | Why core `racket/gui` isn't enough |
|--------|------------------------------------|
| `status-bar%` | `message%` + `gauge%` exist, but there's no ready-made status bar with text + progress |
| `spinner%` | only the determinate `gauge%` ships; no "busy, unknown duration" indicator |
| `stepper%` | `slider%` covers ranges, but there's no compact `[-] value [+]` numeric stepper |
| `disclosure%` | no collapsible / expand-collapse container (the "Advanced options…" pattern) |
| `image-view%` | `canvas%` exists, but no ready-made widget to just display an image (fit / fixed scale) |
| `progress-dialog%` | no modal "Working… / Cancel" dialog for long tasks (core has `gauge%` only) |
| `log-view%` | no scrolling, read-only, auto-scroll log/console; raw `editor-canvas%` + `text%` traps users on stretch & auto-scroll |
| `split-view%` | no draggable split panes (Qt QSplitter / GTK GtkPaned) |
| `toolbar%` | no standard action toolbar with separators |
| `search-field%` | no live "Search…" box (clear + filter-on-type) |
| `stack%` | no clean page-switcher; also de-traps `tab-panel%` (no callback) |

### Convenience wrappers (new, MIT)

Thin wrappers around the aggregated widgets that hide their API footguns behind one consistent class.

| Widget | Wraps | Why |
|--------|-------|-----|
| `labeled-field%` | `cue-mixin` + `tooltip-mixin` | hides `cue-mixin`'s 2-argument footgun; one class with consistent `[cue]` / `[tooltip]` init |
| `text-list%` | `canvas-list%` | hides the 3-argument callback; accept a simple `(λ (item) ...)` action |

### Aggregated (re-exported from mature packages)

| Widget | Upstream package | Why core `racket/gui` isn't enough |
|--------|------------------|------------------------------------|
| `tooltip-mixin`, `cue-mixin`, `validate-mixin` | [gui-widget-mixins](https://github.com/alex-hhh/gui-widget-mixins) (Apache-2.0/MIT) | no tooltips, no placeholder/cue text, no validation on `text-field%` |
| `table-panel%` | [table-panel](https://github.com/spdegabrielle/table-panel) (LGPL-2.1) | only horizontal/vertical panels; no aligned grid layout |
| `canvas-list%` | [canvas-list](https://github.com/massung/racket-canvas-list) (MIT) | `list-box%` can't virtualize huge lists or custom-draw items |
| `date-text-field%` | [text-date](https://github.com/Kalimehtar/text-date) (MIT) | no date entry widget |

## Examples

Every widget has a minimal, standalone runnable example in [`examples/`](examples). Each is a copy-paste starting point:

| Example | Demonstrates |
|---------|--------------|
| `showcase.rkt` | a gallery tour of the core widgets |
| `mini-task-list.rkt` | a realistic small app combining several widgets — clone this |
| `status-bar-demo.rkt` | `status-bar%` |
| `spinner-demo.rkt` | `spinner%` |
| `stepper-demo.rkt` | `stepper%` |
| `tooltip-cue-demo.rkt` | `cue-mixin` + `tooltip-mixin` |
| `table-panel-demo.rkt` | `table-panel%` |
| `canvas-list-demo.rkt` | `canvas-list%` |
| `date-input-demo.rkt` | `date-text-field%` |
| `labeled-field-demo.rkt` | `labeled-field%` (cue + tooltip convenience) |
| `text-list-demo.rkt` | `text-list%` (simple-action list) |
| `disclosure-demo.rkt` | `disclosure%` (collapsible section) |
| `image-view-demo.rkt` | `image-view%` (display a bitmap) |
| `progress-dialog-demo.rkt` | `progress-dialog%` (modal progress + cancel) |
| `log-view-demo.rkt` | `log-view%` (scrolling log, flashing-tool style) |
| `split-view-demo.rkt` | `split-view%` (draggable divider) |
| `toolbar-demo.rkt` | `toolbar%` (toolbar driving a log) |
| `search-field-demo.rkt` | `search-field%` (live list filter) |
| `stack-demo.rkt` | `stack%` (switch pages via a choice%) |

```bash
racket examples/status-bar-demo.rkt   # any of them
```

## Recommended companions

Heavier controls are deliberately **not** hard dependencies, to keep `(require widgetkit)` light. Install the ones you need:

| Control | Install |
|---------|---------|
| Interactive OSM map | `raco pkg install map-widget` |
| Sortable multi-column data grid | `raco pkg install qresults-list` |
| Spreadsheet editor | `raco pkg install spreadsheet-editor` |
| Embed `plot` snips in a window | `raco pkg install plot-container` |
| Web view (Chromium / native) | `raco pkg install racket-webview` |

A tree / outline view already ships with Racket as [`mrlib/hierlist`](https://docs.racket-lang.org/mrlib/hierlist.html) — no install needed.

## Development

```bash
raco test test/run.rkt        # logic tests (run anywhere, no display needed)
raco make main.rkt examples/*.rkt
raco scribble --dest doc widgetkit.scrbl # build the manual into doc/
```

Contributions that add a widget are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). The bar is simple: it must fill a real gap core `racket/gui` leaves open, ship with a runnable example, and be documented.

## License

Licensed under the [MIT License](LICENSE). Aggregated widgets retain their upstream licenses (Apache-2.0/MIT, LGPL-2.1, MIT); see each package for details.
