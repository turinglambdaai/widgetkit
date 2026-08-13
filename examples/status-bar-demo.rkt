;; status-bar% — minimal demo
;; Run: racket examples/status-bar-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "status-bar% demo"] [width 460] [height 150]))

;; A panel above holds the button; the status bar is the last child of the
;; frame, so it sits at the bottom.
(define content (new vertical-panel% [parent f] [alignment '(center center)] [spacing 16]))
(define bar (new status-bar% [parent f] [show-progress #t] [initial-message "Ready."]))

(define (run-task)
  (send bar set-message "Working...")
  (for ([i (in-range 0 101 10)])
    (send bar set-progress i)
    (sleep 0.05))
  (send bar set-progress 100)
  (send bar set-message "Done."))

(new button% [parent content] [label "Run a short task"]
     [callback (λ (_b _e) (run-task))])

(send f show #t)
