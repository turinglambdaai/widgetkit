;; toolbar% — minimal demo
;; Run: racket examples/toolbar-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "toolbar% demo"] [width 500] [height 300] [alignment '(left top)]))

(define tb (new toolbar% [parent f]))
(define log (new log-view% [parent f] [min-height 180]))

(send tb add-button "New" (λ () (send log append-line "New: untitled")))
(send tb add-button "Open" (λ () (send log append-line "Open: file dialog")))
(send tb add-separator)
(send tb add-button "Quit" (λ () (send f show #f)))

(send log append-line "Toolbar ready — try the buttons above.")
;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
