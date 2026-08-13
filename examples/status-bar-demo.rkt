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

;; A short task that updates the bar from a timer, so the eventspace (and the
;; rest of the UI) stays responsive. NEVER call sleep in a GUI callback: it
;; freezes the window until it returns.
(define tick-n 0)
(define tick-timer #f)

(define (tick)
  (set! tick-n (+ tick-n 10))
  (cond
    [(> tick-n 100)
     (send bar set-progress 100)
     (send bar set-message "Done.")
     (send tick-timer stop)]
    [else
     (send bar set-progress tick-n)
     (send bar set-message (format "Working... ~a%" tick-n))]))

(define (run-task)
  (set! tick-n 0)
  (send bar set-message "Working...")
  (send bar set-progress 0)
  (set! tick-timer (new timer% [notify-callback tick] [interval 80])))

(new button% [parent content] [label "Run a short task"]
     [callback (λ (_b _e) (run-task))])

(send f show #t)
