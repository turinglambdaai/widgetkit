;; labeled-field% — minimal demo (cue + tooltip in one consistent class)
;; Run: racket examples/labeled-field-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f
  (new frame% [label "labeled-field% demo"] [width 420] [height 140] [alignment '(center center)]))

;; One class, consistent init fields — no need to remember that cue-mixin
;; takes 2 args and must be composed with tooltip-mixin.
(new labeled-field% [parent f] [label "Name:"] [cue "Enter your name"] [tooltip "Your full name"])
(new labeled-field%
     [parent f]
     [label "Email:"]
     [cue "you@example.com"]
     [tooltip "We never share this"])

;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
