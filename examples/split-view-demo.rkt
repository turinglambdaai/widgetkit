;; split-view% — minimal demo (draggable divider between two panes)
;; Run: racket examples/split-view-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "split-view% demo"] [width 620] [height 400]))

;; Horizontal split: a list on the left, a scrolling log on the right. Drag the
;; divider between them to resize either side.
(define sv (new split-view% [parent f] [orientation 'horizontal] [fraction 0.4]))

(new text-list%
     [parent (send sv get-first)]
     [items
      (for/vector ([i (in-range 1 50)])
        (format "item ~a" i))]
     [item-height 22]
     [action (λ (item) (send log append-line (format "selected: ~a" item)))])

(define log (new log-view% [parent (send sv get-second)]))
(send log append-line "Drag the divider to resize the two panes.")
(send log append-line "Left = get-first (a list), right = get-second (this log).")

(send f show #t)
