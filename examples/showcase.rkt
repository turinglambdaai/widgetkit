;; widgetkit showcase — every included widget in one window.
;; Run: racket examples/showcase.rkt
#lang racket/base

(require racket/class
         racket/gui/base
         racket/draw
         widgetkit)

;; The whole demo lives in the `main` submodule: constructing a
;; date-text-field% arms a one-shot timer that fires at the next midnight and
;; keeps the process alive. `racket` runs `main`; `raco test` only instantiates
;; the enclosing module, so it must not construct the field.
(module+ main
  (define f
    (new frame% [label "widgetkit — showcase"] [width 600] [height 520] [alignment '(left top)]))

  ;; A dropdown picks which page is visible.
  (define pages #f)
  (define (show-only i)
    (for ([p (vector->list pages)]
          [j (in-naturals)])
      (send p show (= i j))))
  (define selector
    (new choice%
         [parent f]
         [label "View:"]
         [choices '("Inputs" "Lists" "Layout" "Feedback")]
         [callback (λ (c e) (show-only (send c get-selection)))]))

  (define (section parent text)
    (new message% [parent parent] [label text]))

  ;; --- Inputs ---------------------------------------------------------------
  (define p-inputs (new vertical-panel% [parent f] [alignment '(left top)] [spacing 8]))
  (section p-inputs "cue-mixin + tooltip-mixin (raw composition)")
  (new (cue-mixin "" (tooltip-mixin text-field%))
       [parent p-inputs]
       [label "Name:"]
       [cue "Enter your name"]
       [tooltip "Your full name"])
  (section p-inputs "labeled-field% (same thing, one consistent class)")
  (new labeled-field%
       [parent p-inputs]
       [label "Email:"]
       [cue "you@example.com"]
       [tooltip "We never share this"])
  (section p-inputs "stepper%")
  (new stepper%
       [parent p-inputs]
       [min-value 0]
       [max-value 20]
       [initial 5]
       [callback (λ (self) (printf "stepper -> ~a\n" (send self get-value)))])
  (section p-inputs "date-text-field%  (dd.mm.yyyy)")
  (new date-text-field% [parent p-inputs] [label "Date:"])

  ;; --- Lists ----------------------------------------------------------------
  (define p-lists (new vertical-panel% [parent f] [alignment '(left top)] [spacing 6]))
  (section p-lists "canvas-list% — 1999 virtual items, only visible rows rendered")
  (new canvas-list%
       [parent p-lists]
       [items
        (for/vector ([i (in-range 1 2000)])
          (format "Item ~a" i))]
       [item-height 20]
       [min-height 180]
       [action-callback (λ (cl item event) (printf "canvas-list picked: ~a\n" item))])
  (section p-lists "text-list% — same idea, simple (lambda (item) ...) action")
  (new text-list%
       [parent p-lists]
       [items (vector "Apple" "Banana" "Cherry" "Date" "Eggplant" "Fig" "Grape")]
       [item-height 22]
       [min-height 120]
       [action (λ (item) (printf "text-list picked: ~a\n" item))])

  ;; --- Layout ---------------------------------------------------------------
  (define p-layout (new vertical-panel% [parent f] [alignment '(left top)] [spacing 8]))
  (section p-layout "table-panel% — aligned 4x2 grid")
  (define grid (new table-panel% [parent p-layout] [dimensions '(4 2)]))
  (for ([l '("Name:" "Value:" "Unit:" "Note:")])
    (new message% [parent grid] [label l])
    (new text-field% [parent grid] [label #f]))
  (section p-layout "disclosure% — collapsible section (click [-]/[+])")
  (define adv (new disclosure% [parent p-layout] [label "Advanced options"] [expanded? #f]))
  (new check-box% [parent (send adv get-content)] [label "Verbose logging"])
  (new check-box% [parent (send adv get-content)] [label "Auto-save on change"])

  ;; --- Feedback -------------------------------------------------------------
  (define p-feedback (new vertical-panel% [parent f] [alignment '(left top)] [spacing 10]))
  (section p-feedback "spinner% — indeterminate activity indicator")
  (define sp (new spinner% [parent p-feedback] [diameter 36]))
  (new button%
       [parent p-feedback]
       [label "start / stop spinner"]
       [callback
        (λ (_b _e)
          (if (send sp spinning?)
              (send sp stop)
              (send sp start)))])
  (section p-feedback "image-view% — display a bitmap, fit to view")
  (define bmp (make-object bitmap% 200 110))
  (define bdc (new bitmap-dc% [bitmap bmp]))
  (send bdc set-brush (new brush% [color "midnightblue"] [style 'solid]))
  (send bdc draw-rectangle 0 0 200 110)
  (send bdc set-text-foreground "white")
  (send bdc draw-text "widgetkit" 16 40)
  (send bdc set-bitmap #f)
  (new image-view% [parent p-feedback] [bitmap bmp] [scale 'fit] [min-height 120])
  (section p-feedback "log-view% — scrolling log (auto-scrolls on append)")
  (define showcase-log (new log-view% [parent p-feedback] [min-height 100]))
  (new button%
       [parent p-feedback]
       [label "Append a log line"]
       [callback
        (λ (_b _e)
          (send showcase-log append-line (format "event @ ~a ms" (current-inexact-milliseconds))))])
  (section p-feedback "status-bar% — see the bottom of this window (with progress gauge)")

  ;; --- Status bar (bottom) --------------------------------------------------
  (define bar
    (new status-bar%
         [parent f]
         [show-progress #t]
         [initial-message "Every widgetkit widget is shown here."]))

  (set! pages (vector p-inputs p-lists p-layout p-feedback))
  (show-only 0)

  (send f show #t))
