;; canvas-list% — minimal demo (fast virtualized list)
;; Run: racket examples/canvas-list-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "canvas-list% demo"] [width 320] [height 380]))

;; 1999 items, yet only the visible rows are rendered. Without a
;; paint-item-callback, each item is drawn as its (format "~a" item) text.
(new canvas-list%
     [parent f]
     [items (for/vector ([i (in-range 1 2000)]) (format "Item ~a" i))]
     [item-height 22]
     [action-callback (λ (cl item event) (printf "activated: ~a\n" item))])

(send f show #t)
