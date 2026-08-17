# Changelog

All notable changes to widgetkit are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.7.3] — 2026-08-17

### Fixed — packaging
- Examples no longer time out the package catalog build (DrDr /
  `raco test --package`, which instantiates every file without running its
  `main` submodule). Launch code (`(send f show #t)`, the progress dialog's
  auto-run thread) now lives in `(module+ main ...)`, so instantiation is a
  construction smoke test that exits cleanly. `date-input-demo.rkt` and
  `showcase.rkt` keep their whole body in `main`, because constructing a
  `date-text-field%` arms a midnight timer that keeps the process alive.
- CI now runs `bash test/run-examples.sh` (`raco test examples/`) to mirror
  the catalog build and guard the `module+ main` convention.

## [0.7.2] — 2026-08-13

### Fixed
- `toolbar%` `add-button` / `add-separator` return the created `button%` /
  separator canvas (the `void?` contracts were wrong and rejected the widgets
  they created); contracts and docs updated accordingly.
- `log-view%` `scroll-to-bottom` no longer leaks `scroll-to-position`'s return
  value out of its `void?` contract.
- `disclosure%` `set-expanded!` no longer leaks the user callback's return
  value out of its `void?` contract.

### Added — testing
- Behavioral tests now exercise every public method's return contract,
  catching the whole class above (34 behavioral checks).

## [0.7.1] — 2026-08-13

### Added — testing
- `test/gui-behavior.rkt` — a behavioral test suite that instantiates the
  widgets and exercises real logic (stepper clamping, log-view append/trim,
  status-bar messages, spinner start/stop, disclosure expand, image-view
  round-trip, split-view fraction + contract rejection, stack page count,
  notification-banner show/hide, search-field text). It needs a display, so it
  runs under Xvfb on headless Linux via `test/run-gui-behavior.sh` (wired into
  CI). `test/run.rkt` stays pure and runs anywhere.

## [0.7.0] — 2026-08-13

### Added — gap-filling widgets
- `notification-banner%` — a transient, dismissible, severity-colored banner
  (the "toast"/in-app-notification pattern): non-blocking, auto-dismissable,
  and distinct from the persistent `status-bar%` and the modal
  `progress-dialog%`.

## [0.6.1] — 2026-08-13

### Changed — craft
- All Racket source is now `raco fmt` clean (width 102), matching the official
  formatter. CI enforces it via `test/check-fmt.sh`.

## [0.6.0] — 2026-08-13

### Changed — API quality
- **Every public widget is now exported with contracts** (`provide/contract` +
  `class/c`). All methods and key initialization arguments are runtime-checked;
  misuse fails fast with blame pointing at the caller, and the contracts give
  AI agents a machine-readable API surface. The internal `private/` modules
  remain unchecked; contracts live at the `widgetkit` collection boundary.

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
