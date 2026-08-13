;; widgetkit showcase — every included widget in one window.
;; Run: racket examples/showcase.rkt
#lang racket/base

(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "widgetkit — showcase"] [width 560] [height 480]
               [alignment '(left top)]))

;; `pages` is filled in once the panels exist. show-only reads it at call time
;; (when the user clicks a tab), so a forward reference here is safe.
(define pages #f)
(define (show-only i)
  (for ([p (vector->list pages)] [j (in-naturals)])
    (send p show (= i j))))

;; A dropdown picks which page is visible. (tab-panel% has no per-instance
;; selection callback, so the switching is driven from a choice% instead.)
(define selector
  (new choice% [parent f] [label "View:"] [choices '("Inputs" "Lists" "Layout" "Feedback")]
       [callback (λ (c e) (show-only (send c get-selection)))]))

(define (section parent text)
  (new message% [parent parent] [label text]))

;; --- Inputs ---------------------------------------------------------------
(define p-inputs (new vertical-panel% [parent f] [alignment '(left top)] [spacing 10]))
(section p-inputs "Cue text + tooltip  (gui-widget-mixins)")
(new (cue-mixin "" (tooltip-mixin text-field%))
     [parent p-inputs] [label "Name:"] [cue "Enter your name"] [tooltip "Your full name"])
(new (cue-mixin "" (tooltip-mixin text-field%))
     [parent p-inputs] [label "Email:"] [cue "you@example.com"] [tooltip "We never share this"])
(section p-inputs "stepper%")
(new stepper% [parent p-inputs] [min-value 0] [max-value 20] [initial 5]
     [callback (λ (self) (printf "stepper -> ~a\n" (send self get-value)))])
(section p-inputs "date-text-field%  (dd.mm.yyyy)")
(new date-text-field% [parent p-inputs] [label "Date:"])

;; --- Lists ----------------------------------------------------------------
(define p-lists (new vertical-panel% [parent f] [alignment '(left top)]))
(section p-lists "canvas-list% — 1999 virtual items, only visible rows rendered")
(new canvas-list%
     [parent p-lists]
     [items (for/vector ([i (in-range 1 2000)]) (format "Item ~a" i))]
     [item-height 22]
     [min-height 320]
     [action-callback (λ (cl item event) (printf "activated: ~a\n" item))])

;; --- Layout ---------------------------------------------------------------
(define p-layout (new vertical-panel% [parent f] [alignment '(left top)] [spacing 8]))
(section p-layout "table-panel% — aligned 4x2 grid")
(define grid (new table-panel% [parent p-layout] [dimensions '(4 2)]))
(for ([l '("Name:" "Value:" "Unit:" "Note:")])
  (new message% [parent grid] [label l])
  (new text-field% [parent grid] [label #f]))

;; --- Feedback -------------------------------------------------------------
(define p-feedback (new vertical-panel% [parent f] [alignment '(left top)] [spacing 14]))
(section p-feedback "spinner% — indeterminate activity indicator")
(define sp (new spinner% [parent p-feedback] [diameter 36]))
(new button% [parent p-feedback] [label "start / stop spinner"]
     [callback (λ (_b _e) (if (send sp spinning?) (send sp stop) (send sp start)))])
(section p-feedback "status-bar% — see the bottom of this window (with progress gauge)")

;; --- Status bar (bottom) --------------------------------------------------
(define bar (new status-bar% [parent f] [show-progress #t]
                 [initial-message "Hover the input fields to see tooltips."]))

;; --- Activate the first page ----------------------------------------------
(set! pages (vector p-inputs p-lists p-layout p-feedback))
(show-only 0)

(send f show #t)
