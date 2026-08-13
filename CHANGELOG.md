# Changelog

All notable changes to widgetkit are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
