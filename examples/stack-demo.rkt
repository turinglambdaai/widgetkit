;; stack% — minimal demo (switch pages via a choice%)
;; Run: racket examples/stack-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "stack% demo"] [width 420] [height 260] [alignment '(left top)]))

;; A dropdown drives which stack page is visible.
(new choice%
     [parent f]
     [label "Page:"]
     [choices '("One" "Two" "Three")]
     [callback (λ (c _e) (send pages show-page (send c get-selection)))])

(define pages (new stack% [parent f]))

(define p0 (send pages add-page))
(new message% [parent p0] [label "This is page one."])

(define p1 (send pages add-page))
(new check-box% [parent p1] [label "An option that only exists on page two"])
(new check-box% [parent p1] [label "Another option"])

(define p2 (send pages add-page))
(new message% [parent p2] [label "Page three has its own content."])

(send pages show-page 0)
;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
