;; log-view% — minimal demo (scrolling log, flashing-tool style)
;; Run: racket examples/log-view-demo.rkt
#lang racket/base

(require racket/class
         racket/gui/base
         widgetkit)

;; The frame stacks a fixed-height button row on top of a log-view% that
;; stretches to fill the remaining vertical space — resizing the window grows
;; the log, which is exactly what was painful to get right by hand.
(define f (new frame% [label "log-view% demo"] [width 620] [height 400] [alignment '(left top)]))

(define buttons
  (new horizontal-panel% [parent f] [alignment '(left center)] [stretchable-height #f] [spacing 8]))

(define log (new log-view% [parent f] [min-height 200]))

(new button%
     [parent buttons]
     [label "Append log line"]
     [callback
      (λ (_b _e)
        (send log append-line
              (format "[~a ms] erasing sector 0x~x ... ok"
                      (current-inexact-milliseconds)
                      (random 4096))))])
(new button%
     [parent buttons]
     [label "Append 500 lines (stress)"]
     [callback
      (λ (_b _e)
        (for ([i (in-range 500)])
          (send log append-line (format "progress ~a / 500" i))))])
(new button% [parent buttons] [label "Clear"] [callback (λ (_b _e) (send log clear))])

(send log append-line "Bootloader v2.3 — ready.")
(send log append-line "Press 'Append log line' to stream output; the view auto-scrolls.")

;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
