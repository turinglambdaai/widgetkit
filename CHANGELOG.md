# Changelog

All notable changes to widgetkit are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.5.0] — 2026-08-13

### Added — gap-filling widgets
- `split-view%` — two panes with a draggable divider (Qt QSplitter / GTK GtkPaned).
- `toolbar%` — fixed-height row of action buttons with separators.
- `search-field%` — live "Search…" box with a clear button.
- `stack%` — a page-switcher (QStackedWidget); also de-traps `tab-panel%`.

### Added — footguns
- Custom panel layout: the child-info passed to `place-children` /
  `container-size` is a 4-element `(min-width min-height stretchable-width
  stretchable-height)`; force a relayout with `change-children`; screen
  coordinates are `client->screen` (not `client-to-screen`).

## [0.4.0] — 2026-08-13

### Added — gap-filling widgets
- `log-view%` — a scrolling, read-only, monospace log/console that stretches to
  fill its parent, auto-scrolls on append, and trims old lines past a cap.
  Directly addresses the "build a flashing-tool log panel" use case that is
  painful to assemble from raw `editor-canvas%` + `text%`.

### Added — footguns
- Stretchability rule: a widget only resizes with the window if it is
  stretchable AND its parent stretches children (`pane%` and `group-panel%` do
  not stretch children — use a `panel%`/`horizontal-panel%`/`vertical-panel%`).

## [0.3.0] — 2026-08-13

### Added — gap-filling widgets
- `progress-dialog%` — a modal "Working… / Cancel" progress dialog for
  long-running tasks, driven from a worker thread via `queue-callback`.

## [0.2.0] — 2026-08-13

### Added — gap-filling widgets
- `disclosure%` — collapsible section (the "Advanced options…" pattern).
- `image-view%` — display a bitmap, fit-to-view or at a fixed scale.

### Added — consistency wrappers
- `labeled-field%` — `text-field%` with cue + tooltip baked in (hides the
  `cue-mixin` 2-argument footgun).
- `text-list%` — `canvas-list%` with a one-argument action callback.

### Added — agent-friendliness
- `AGENTS.md`: an intent-first single-file reference, a core `racket/gui`
  "don't reinvent" table, and a footguns list (`button%` 2-arg callback,
  `gauge%` uses `min-width`, `tab-panel%` has no selection callback,
  `cue-mixin` is 2-arg, `canvas-list%` 3-arg callbacks, `bitmap%` via
  `make-object`, class errors surface only at load, etc.).
- `test/smoke-examples.sh` (and CI) actually launches every example, catching
  runtime errors that `raco make` cannot.
- `examples/mini-task-list.rkt` — a realistic small app combining several
  widgets, as a cloneable starting point.

### Changed
- `status-bar-demo` drives progress from a timer instead of blocking with
  `sleep`.
- `showcase.rkt` now demonstrates every widget.

## [0.1.0] — 2026-08-12

First release. A curated collection of GUI widgets for Racket, gathered behind
a single `require`.

### Added — gap-filling widgets (new, MIT)

- `status-bar%` — bottom-of-window bar with a status message and optional
  determinate progress gauge.
- `spinner%` — indeterminate circular activity indicator.
- `stepper%` — compact `[-] value [+]` numeric stepper with clamping and an
  on-change callback. Exports the `clamp` helper.

### Added — aggregated widgets (re-exported from mature packages)

- `tooltip-mixin`, `cue-mixin`, `validate-mixin`, `decorate-mixin`,
  `decorate-with` — from `gui-widget-mixins` (Apache-2.0 OR MIT).
- `table-panel%` — from `table-panel` (LGPL-2.1).
- `canvas-list%` — from `canvas-list` (MIT).
- `date-text-field%` — from `text-date` (MIT).

### Added — documentation & examples

- One runnable example per widget in `examples/`, plus a `showcase.rkt`
  gallery.
- A unified Scribble manual (`widgetkit.scrbl`), including a "recommended
  companions" section for heavier controls (map, data grid, spreadsheet, plot,
  web view).
- Logic tests in `test/run.rkt`.
