;; spinner% — minimal demo
;; Run: racket examples/spinner-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "spinner% demo"] [width 320] [height 120] [alignment '(center center)]))

(define sp (new spinner% [parent f] [diameter 36]))

(new button%
     [parent f]
     [label "Toggle busy"]
     [callback
      (λ (_b _e)
        (if (send sp spinning?)
            (send sp stop)
            (send sp start)))])

(send f show #t)
