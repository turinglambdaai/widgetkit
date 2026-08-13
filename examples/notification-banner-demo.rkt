;; notification-banner% -- minimal demo
;; Run: racket examples/notification-banner-demo.rkt
#lang racket/base

(require racket/class
         racket/gui/base
         widgetkit)

(define f
  (new frame% [label "notification-banner% demo"] [width 460] [height 220] [alignment '(left top)]))

;; The banner sits at the top; it is hidden until show-message is called.
(define nb (new notification-banner% [parent f]))

(define actions
  (new horizontal-panel% [parent f] [alignment '(left center)] [stretchable-height #f] [spacing 6]))

(define (btn label sev [ms #f])
  (new button%
       [parent actions]
       [label label]
       [callback (λ (_b _e) (send nb show-message (format "~a: something happened." label) sev ms))]))

(btn "Info" 'info 2500) ; auto-dismiss after 2.5s
(btn "Success" 'success 3000)
(btn "Warning" 'warning)
(btn "Error" 'error)

(new message% [parent f] [label "Click an action above. Click the 'x' on a banner to dismiss it."])

(send f show #t)
