;; text-list% — minimal demo (virtualized list with a one-argument action)
;; Run: racket examples/text-list-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "text-list% demo"] [width 300] [height 360]))

;; `action` is a simple (lambda (item) ...) — not the three-argument callback
;; that canvas-list% itself requires.
(new text-list%
     [parent f]
     [items
      (for/vector ([i (in-range 1 1000)])
        (format "Item ~a" i))]
     [item-height 22]
     [action (λ (item) (printf "picked: ~a\n" item))])

;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
