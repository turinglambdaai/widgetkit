;; progress-dialog% — minimal demo (modal progress + cancel)
;; Run: racket examples/progress-dialog-demo.rkt
#lang racket/base

(require racket/class
         racket/gui/base
         widgetkit)

(define f (new frame% [label "progress-dialog% demo"] [width 360] [height 110]
               [alignment '(center center)]))

(new message% [parent f] [label "A modal progress dialog runs on launch; click Run to repeat."])
(new button% [parent f] [label "Run"]
     [callback (λ (_b _e) (run))])

;; Open a modal progress dialog and drive it from a worker thread. The dialog's
;; `show #t` runs a modal event loop; the worker (a separate thread in the same
;; eventspace) updates the UI via `queue-callback` and closes the dialog when
;; done (or when the user cancels).
(define (run)
  (define pd (new progress-dialog% [parent f] [label "Counting to 100%"]
                  [on-cancel (λ () (printf "cancelled\n"))]))
  (void
   (thread
    (λ ()
      (for ([i (in-range 0 101 5)])
        #:break (send pd cancelled?)
        (queue-callback (λ () (send pd set-progress i)
                                (send pd set-message (format "~a%" i))))
        (sleep 0.08))
      (unless (send pd cancelled?)
        (queue-callback (λ () (send pd set-progress 100) (send pd set-message "Done."))))
      (sleep 0.3)
      (queue-callback (λ () (send pd show #f))))))
  (send pd show #t))

;; Auto-run once shortly after the window appears, so launching the example
;; exercises the whole modal/worker flow without a manual click.
(void (thread (λ () (sleep 0.3) (queue-callback (λ () (run))))))
(send f show #t)
