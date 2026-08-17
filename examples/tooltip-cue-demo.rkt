;; tooltip / cue text — minimal demo (gui-widget-mixins)
;; Run: racket examples/tooltip-cue-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f
  (new frame% [label "tooltip / cue demo"] [width 440] [height 150] [alignment '(center center)]))

;; cue-mixin adds placeholder ("cue") text; tooltip-mixin adds hover tooltips.
;; Compose them by nesting: (cue-mixin (tooltip-mixin text-field%)).
(new (cue-mixin "" (tooltip-mixin text-field%))
     [parent f]
     [label "Name:"]
     [cue "Enter your name"]
     [tooltip "Your full name — hover the field for a moment."])

(new (cue-mixin "" (tooltip-mixin text-field%))
     [parent f]
     [label "Email:"]
     [cue "you@example.com"]
     [tooltip "We never share this."])

;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
