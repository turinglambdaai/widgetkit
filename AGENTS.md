# AGENTS.md — building Racket GUIs with widgetkit

> This file is the quick reference for AI agents (and humans) building GUIs with
> **widgetkit** + core `racket/gui`. Read this first. It is intent-first: given
> what the user wants, it tells you which widget to use and gives a verified
> snippet, or points you at core `racket/gui`.

## What widgetkit is

A curated collection of GUI widgets for Racket. Two rules:

1. **Fill a gap core `racket/gui` leaves open.** If the toolkit already does it
   well, it is not here.
2. **Reuse over rewrite.** When a mature package already does the job,
   widgetkit depends on it and re-exports it. New code is written only where no
   good solution exists.

`#lang racket/base`, `(require widgetkit)` plus `(require racket/gui/base)`.

## Decision flow

1. Does **core `racket/gui`** already do it well? → use core (table below).
2. Else, is it a **widgetkit** widget? → use it (intent table below).
3. Else, is it a **recommended companion**? → `raco pkg install` it.
4. Else, hand-roll on `canvas%` / `panel%`, and consider contributing it.

## Core `racket/gui` already provides — DO NOT reinvent

| Need | Use |
|------|-----|
| Push button | `button%` |
| Checkbox | `check-box%` |
| Radio group | `radio-box%` |
| Slider / range | `slider%` |
| Dropdown (pick one) | `choice%` |
| Combo (type + pick) | `combo-field%` |
| Single-line text | `text-field%` |
| Multi-line / rich text | `editor-canvas%` + `text%` |
| Static label | `message%` |
| Determinate progress (known %) | `gauge%` |
| Visual tab strip | `tab-panel%` (see footgun) |
| Border/group box | `group-panel%` |
| Scroll host | `canvas%` (with scrollbars) |
| Menus | `menu-bar%`, `popup-menu%` |
| Open/save file | `get-file`, `put-file` |
| Message / yes-no dialog | `message-box`, `message-box/custom` |
| Ask for a color | `get-color-from-user` |
| Tree / outline | `mrlib/hierlist` (ships with Racket) |

## widgetkit widgets (intent-first)

```racket
(require racket/gui/base widgetkit)
```

| User intent | Widget | Minimal snippet (verified) |
|-------------|--------|----------------------------|
| Placeholder + tooltip on a field | `cue-mixin`, `tooltip-mixin` | `(new (cue-mixin "" (tooltip-mixin text-field%)) [parent f] [label "Name:"] [cue "Enter your name"] [tooltip "Full name"])` |
| Placeholder + tooltip (simpler) | `labeled-field%` | `(new labeled-field% [parent f] [label "Name:"] [cue "Enter your name"] [tooltip "Full name"])` |
| Aligned grid / form layout | `table-panel%` | `(new table-panel% [parent f] [dimensions '(4 2)])` |
| Date input (dd.mm.yyyy) | `date-text-field%` | `(new date-text-field% [parent f] [label "Date:"])` |
| Very large list / custom-drawn rows | `canvas-list%` | `(new canvas-list% [parent f] [items (vector "a" "b")] [item-height 22] [action-callback (λ (c item e) (void))])` |
| Big list of strings, simple pick action | `text-list%` | `(new text-list% [parent f] [items (vector "a" "b")] [action (λ (item) (void))])` |
| Display an image (fit or fixed scale) | `image-view%` | `(new image-view% [parent f] [bitmap bmp] [scale 'fit])` or `(send iv load-file "x.png")` |
| Bottom status bar (+ optional progress) | `status-bar%` | `(new status-bar% [parent f] [show-progress #t] [initial-message "Ready."])` |
| Modal "Working… / Cancel" dialog | `progress-dialog%` | `(new progress-dialog% [parent f] [label "..."])`; drive from a thread + `queue-callback`, see `examples/progress-dialog-demo.rkt` |
| Transient dismissible banner (toast) | `notification-banner%` | `(new notification-banner% [parent f])`; `(send nb show-message "Saved." 'success 3000)` auto-dismisses; `#f` ms keeps it up |
| Scrolling log / console output | `log-view%` | `(new log-view% [parent f] [max-lines 5000])`; `(send log append-line "...")` auto-scrolls |
| Draggable split panes | `split-view%` | `(new split-view% [parent f] [orientation 'horizontal] [fraction 0.4])`; add children to `(send sv get-first)` / `get-second` |
| App toolbar (buttons + separators) | `toolbar%` | `(new toolbar% [parent f])`; `(send tb add-button "Open" (λ () ...))`; `(send tb add-separator)` |
| Search box (live filter) | `search-field%` | `(new search-field% [parent f] [callback (λ (q) ...)])` |
| Switchable pages | `stack%` | `(new stack% [parent f])`; `(send st add-page)`; `(send st show-page i)` — pair with `choice%` for tabs |
| "Busy", unknown duration | `spinner%` | `(new spinner% [parent f] [diameter 28])` then `(send sp start)` / `(send sp stop)` |
| Compact `[-] value [+]` numeric | `stepper%` | `(new stepper% [parent f] [min-value 0] [max-value 20] [initial 5])` |
| Collapsible ("Advanced…") section | `disclosure%` | `(new disclosure% [parent f] [label "Advanced"] [expanded? #f])` — add children to `(send d get-content)` |

Each has a standalone demo in `examples/` — copy it as a starting point.

## Recommended companions (install on demand)

Heavier controls are **not** hard dependencies, to keep `widgetkit` light:

| Need | Install |
|------|---------|
| Interactive OSM map | `raco pkg install map-widget` |
| Sortable multi-column data grid | `raco pkg install qresults-list` |
| Spreadsheet editor | `raco pkg install spreadsheet-editor` |
| Embed `plot` snips | `raco pkg install plot-container` |
| Web view (Chromium/native) | `raco pkg install racket-webview` |

## Footguns — real API traps (all verified the hard way)

Read these before writing widget code; they are the mistakes an agent will
otherwise copy:

- **`button%` callback takes 2 arguments**, `(λ (button event) ...)`, not 1.
  The arity is checked at construction, so `(new button% [callback (λ (_) ...)])`
  throws immediately.
- **`gauge%` has no `width` init field.** Use `min-width` to fix its size.
- **`bitmap%` has no `width`/`height` init field.** Create one positionally with
  `(make-object bitmap% w h)`, not `(new bitmap% [width w] [height h])`.
- **`message%` grows to fit its label.** For a status bar use `min-width` +
  `stretchable-width #t` so long text is clipped instead of stretching the
  window.
- **A widget only resizes with the window if it is stretchable AND its parent
  stretches children.** `editor-canvas%`, `canvas%` and `panel%` default to
  stretchable, but `pane%` and `group-panel%` do NOT stretch their children
  (they use natural size) — a resizing area placed in one will not grow. Put it
  in a `horizontal-panel%`/`vertical-panel%`, or set
  `(send w stretchable-width/height #t)`. `log-view%` and `image-view%`
  stretch by default.
- **Custom panel layout (overriding `place-children` / `container-size`):**
  each child-info entry passed to these methods is a 4-element list
  `(min-width min-height stretchable-width stretchable-height)` — there are no
  margin slots. `container-size` takes `info` and returns `(values w h)`;
  `place-children` takes `info width height` and returns a list of
  `(list x y w h)` in the same child order. To force a relayout after changing
  layout state, call `(send panel change-children (λ (l) l))`. Screen
  coordinates are `client->screen` (not `client-to-screen`).
- **`tab-panel%` tabs are visual only.** There is **no per-instance selection
  callback**, and `on-new-tab` is **not augmentable**. To switch pages, drive it
  from a `choice%`, or augment `on-new-request`. The tabs do not hide/show
  children for you.
- **`cue-mixin` takes 2 arguments**: `(cue-mixin default-cue-string
  base-class)` — it is not a plain `class -> class` mixin. `tooltip-mixin`
  is `(tooltip-mixin base-class)` (1 arg). Prefer `labeled-field%`, which
  bakes in the correct composition.
- **`canvas-list%` callbacks are 3-argument**: `(λ (canvas item event) ...)`
  for `action-callback` / `selection-callback`. Prefer `text-list%` for a list
  of strings with a one-argument `(λ (item) ...)` action.
- **`on-superwindow-show` is not augmentable** on `canvas%`. Do not
  `define/augment` it.
- **`date-text-field%` starts a one-shot timer** scheduled to fire at the next
  midnight. A script that constructs one will not exit on its own; call
  `(exit 0)` in non-GUI scripts. It is harmless inside a real app.
- **Modal dialogs block in `show #t`.** Work that updates a modal dialog (e.g.
  `progress-dialog%`) must run in a separate thread and touch the UI via
  `queue-callback`; running it inline in the callback freezes the dialog. See
  `examples/progress-dialog-demo.rkt`.
- **Class errors surface at load/instantiate, not at compile.** "no such
  method", "not augmentable", and "unused initialization arguments" are all
  runtime errors — `raco make` will not catch them. Always **instantiate** to
  test, never just compile.
- **GUI instantiation needs a display.** On headless Linux, run under
  `xvfb-run -a`.

## How to verify GUI code you write

1. **Compile:** `raco make <file>`
2. **Instantiate** every widget in a hidden frame (catches init-arg and
   class-creation errors that compile misses):
   ```racket
   (require racket/class racket/gui/base widgetkit)
   (define f (new frame% [label "t"]))   ; never shown
   (new status-bar% [parent f] [show-progress #t])
   ;; ...every widget you use...
   (exit 0)
   ```
3. **Run the example:** `racket examples/<widget>-demo.rkt` (needs a display).
4. **Logic tests:** `raco test test/run.rkt`
5. **Launch all examples:** `bash test/smoke-examples.sh`

The smoke script (step 5) is the guard that catches runtime errors like a bad
callback arity or a missing method — run it before considering GUI code done.

## Minimal app skeleton

```racket
#lang racket/base
(require racket/gui/base widgetkit)

(define f (new frame% [label "my app"] [width 600] [height 400]
               [alignment '(left top)]))

;; A form laid out in a grid, with a status bar pinned to the bottom.
(define form (new table-panel% [parent f] [dimensions '(3 2)]))
(new message% [parent form] [label "Name:"])
(new (cue-mixin "" (tooltip-mixin text-field%)) [parent form] [label #f]
     [cue "Enter your name"] [tooltip "Full name"])
(new message% [parent form] [label "Quantity:"])
(new stepper% [parent form] [min-value 0] [max-value 99] [initial 1])
(new message% [parent form] [label "Date:"])
(new date-text-field% [parent form] [label #f])

(define bar (new status-bar% [parent f] [show-progress #t] [initial-message "Ready."]))

(send f show #t)
```

For a fuller, realistic example combining several widgets (`table-panel%`,
`labeled-field%`, `text-list%`, `disclosure%`, `status-bar%`), see
`examples/mini-task-list.rkt` — clone it as the starting point for a real app.

## Extending widgetkit

See `CONTRIBUTING.md`. The bar: it must fill a real gap core `racket/gui` leaves
open, ship with a **verified runnable example**, be documented (a row in this
file's intent table + a section in `widgetkit.scrbl`), and its traps must be
added to the Footguns list above.
