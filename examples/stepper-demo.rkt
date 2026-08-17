;; stepper% — minimal demo
;; Run: racket examples/stepper-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "stepper% demo"] [width 360] [height 100] [alignment '(center center)]))

(new stepper%
     [parent f]
     [min-value 0]
     [max-value 12]
     [step 1]
     [initial 1]
     [callback (λ (self) (printf "stepper value: ~a\n" (send self get-value)))])

;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
