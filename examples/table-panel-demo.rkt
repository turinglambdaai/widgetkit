;; table-panel% — minimal demo (aligned grid layout)
;; Run: racket examples/table-panel-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "table-panel% demo"] [width 420] [height 200]))

;; A 4-row x 2-column aligned grid. table-panel% fills cells along its
;; major axis (rows by default), so interleave label + field per row.
(define grid (new table-panel% [parent f] [dimensions '(4 2)]))

(for ([l '("Name:" "Value:" "Unit:" "Note:")])
  (new message% [parent grid] [label l])
  (new text-field% [parent grid] [label #f]))

(send f show #t)
