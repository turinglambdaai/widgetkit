;; disclosure% — minimal demo (collapsible section)
;; Run: racket examples/disclosure-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "disclosure% demo"] [width 380] [height 240]
               [alignment '(left top)]))

;; A collapsible "Advanced options" section, collapsed by default.
(define d (new disclosure% [parent f] [label "Advanced options"] [expanded? #f]
               [callback (λ (self) (printf "expanded? ~a\n" (send self is-expanded?)))]))

;; Add the hidden children to the content panel.
(new check-box% [parent (send d get-content)] [label "Verbose logging"])
(new check-box% [parent (send d get-content)] [label "Auto-save on change"])
(new text-field% [parent (send d get-content)] [label "Config path:"])

;; A second, expanded disclosure, plus a plain widget outside any disclosure.
(new disclosure% [parent f] [label "Defaults"] [expanded? #t])
(new button% [parent f] [label "Reset everything"]
     [callback (λ (_b _e) (printf "reset\n"))])

(send f show #t)
