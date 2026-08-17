;; date-text-field% — minimal demo (date entry, dd.mm.yyyy)
;; Run: racket examples/date-input-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

;; The whole demo lives in the `main` submodule: constructing a
;; date-text-field% arms a one-shot timer that fires at the next midnight and
;; keeps the process alive. `racket` runs `main`; `raco test` only instantiates
;; the enclosing module, so it must not construct the field.
(module+ main
  (define f
    (new frame%
         [label "date-text-field% demo"]
         [width 380]
         [height 110]
         [alignment '(center center)]))

  ;; The empty field shows today's date as faded "cue" text and only accepts
  ;; digits and dots.
  (define dtf (new date-text-field% [parent f] [label "Date:"]))

  (new button%
       [parent f]
       [label "Show value"]
       [callback (λ (_b _e) (printf "date = ~a\n" (send dtf get-value)))])

  (send f show #t))
