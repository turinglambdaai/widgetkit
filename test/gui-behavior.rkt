;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 turinglambdaai <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

;; Behavioral tests: instantiate the widgets (in a hidden frame) and exercise
;; their real logic -- clamping, append/trim, show/hide, fraction, etc.
;;
;; These need a display, so they live apart from test/run.rkt (which is pure
;; and runs anywhere). On headless Linux run under Xvfb -- see
;; test/run-gui-behavior.sh and the CI workflow.

(require rackunit
         racket/class
         racket/gui/base
         racket/draw
         racket/string
         widgetkit)

;; A single hidden frame hosts every widget under test.
(define f (new frame% [label "widgetkit behavioral tests"]))

;; ---------------------------------------------------------------------------
;; stepper% -- increment / decrement / clamping
;; ---------------------------------------------------------------------------
(let ([st (new stepper%
               [parent f]
               [min-value 0]
               [max-value 10]
               [initial 5]
               [callback (lambda (_self) (void))])])
  (check-equal? (send st get-value) 5 "stepper initial value")
  (send st increment)
  (check-equal? (send st get-value) 6 "stepper increments")
  (send st set-value 100)
  (check-equal? (send st get-value) 10 "stepper clamps to max")
  (send st set-value -5)
  (check-equal? (send st get-value) 0 "stepper clamps to min")
  (send st decrement)
  (check-equal? (send st get-value) 0 "stepper at min stays at min"))

;; ---------------------------------------------------------------------------
;; log-view% -- append accumulates, max-lines trims oldest, clear empties
;; ---------------------------------------------------------------------------
(let ([lv (new log-view% [parent f] [max-lines 3] [read-only? #t])])
  (send lv append-line "a")
  (send lv append-line "b")
  (send lv append-line "c")
  (send lv append-line "d") ; "a" should be evicted (keep last 3)
  (define t (send lv get-text))
  (check-true (string-contains? t "d") "log keeps newest line")
  (check-false (string-contains? t "a") "log evicts oldest past max-lines")
  (send lv clear)
  (check-equal? (send lv get-text) "" "log clears to empty"))

;; ---------------------------------------------------------------------------
;; status-bar% -- message round-trip
;; ---------------------------------------------------------------------------
(let ([bar (new status-bar% [parent f] [initial-message "ready"])])
  (check-equal? (send bar get-message) "ready" "status-bar initial message")
  (send bar set-message "working")
  (check-equal? (send bar get-message) "working" "status-bar set-message"))

;; ---------------------------------------------------------------------------
;; spinner% -- start/stop flip the spinning? flag
;; ---------------------------------------------------------------------------
(let ([sp (new spinner% [parent f])])
  (check-false (send sp spinning?) "spinner starts stopped")
  (send sp start)
  (check-true (send sp spinning?) "spinner running after start")
  (send sp stop)
  (check-false (send sp spinning?) "spinner stopped after stop"))

;; ---------------------------------------------------------------------------
;; disclosure% -- expand/collapse + content container
;; ---------------------------------------------------------------------------
(let ([d (new disclosure% [parent f] [label "x"] [expanded? #f])])
  (check-false (send d is-expanded?) "disclosure starts collapsed")
  (send d set-expanded! #t)
  (check-true (send d is-expanded?) "disclosure expands")
  (check-true (is-a? (send d get-content) area-container<%>) "disclosure content is a container"))

;; ---------------------------------------------------------------------------
;; image-view% -- bitmap round-trip
;; ---------------------------------------------------------------------------
(let ([iv (new image-view% [parent f])]
      [bmp (make-object bitmap% 4 4)])
  (send iv set-bitmap bmp)
  (check-eq? (send iv get-bitmap) bmp "image-view stores the bitmap"))

;; ---------------------------------------------------------------------------
;; split-view% -- fraction clamps to [0,1]; sides are containers
;; ---------------------------------------------------------------------------
(let ([sv (new split-view% [parent f] [fraction 0.5])])
  (send sv set-fraction 0.25)
  (check-true (< 0.24 (send sv get-fraction) 0.26) "split-view sets an in-range fraction")
  ;; Out-of-range fractions are rejected at the contract boundary (fail-fast);
  ;; internal clamping only protects the drag path.
  (check-exn exn:fail:contract?
             (lambda () (send sv set-fraction 2.0))
             "split-view rejects an out-of-range fraction")
  (check-true (is-a? (send sv get-first) area-container<%>) "split-view first is a container")
  (check-true (is-a? (send sv get-second) area-container<%>) "split-view second is a container"))

;; ---------------------------------------------------------------------------
;; stack% -- page count tracks add-page
;; ---------------------------------------------------------------------------
(let ([s (new stack% [parent f])])
  (check-equal? (send s page-count) 0 "stack starts empty")
  (send s add-page)
  (send s add-page)
  (check-equal? (send s page-count) 2 "stack counts added pages"))

;; ---------------------------------------------------------------------------
;; notification-banner% -- show/hide cycle
;; ---------------------------------------------------------------------------
(let ([nb (new notification-banner% [parent f])])
  (check-equal? (send nb current-message) #f "banner starts hidden")
  (send nb show-message "hi" 'info #f)
  (check-equal? (send nb current-message) "hi" "banner shows the message")
  (send nb hide)
  (check-equal? (send nb current-message) #f "banner hides"))

;; ---------------------------------------------------------------------------
;; notification-banner% -- click closes only inside the close zone. The frame
;; must be shown once so the canvas reports a real client size (a hidden frame
;; gives 1x1, where every x lands in the last 24 pixels).
;; ---------------------------------------------------------------------------
(let ([nb (new notification-banner% [parent f])])
  (send f show #t)
  (send nb show-message "hi" 'info #f)
  (define w
    (let-values ([(w h) (send nb get-client-size)])
      w))
  (check-true (> w 24) "banner has a real client width")
  (define (click x)
    (send nb on-event (new mouse-event% [event-type 'left-down] [x x] [y 5])))
  (click 10)
  (check-equal? (send nb current-message) "hi" "click on the body does not dismiss")
  (click (- w 10))
  (check-equal? (send nb current-message) #f "click in the close zone dismisses")
  (send f show #f))

;; ---------------------------------------------------------------------------
;; search-field% -- text round-trip
;; ---------------------------------------------------------------------------
(let ([sf (new search-field% [parent f] [callback (lambda (_q) (void))])])
  (send sf set-text "query")
  (check-equal? (send sf get-text) "query" "search-field stores text"))

;; ---------------------------------------------------------------------------
;; toolbar% -- add-button / add-separator return the created widgets
;; ---------------------------------------------------------------------------
(let ([tb (new toolbar% [parent f])])
  (check-pred (is-a?/c button%) (send tb add-button "x" void) "toolbar add-button returns the button")
  (check-pred (is-a?/c canvas%)
              (send tb add-separator)
              "toolbar add-separator returns the separator canvas"))

;; ---------------------------------------------------------------------------
;; disclosure% -- a user callback returning non-void must not leak out of
;; set-expanded! (whose contract promises void?)
;; ---------------------------------------------------------------------------
(let ([d (new disclosure% [parent f] [label "x"] [callback (lambda (_self) 'leaked)])])
  (check-false (send d is-expanded?) "disclosure starts collapsed")
  (send d set-expanded! #t)
  (check-true (send d is-expanded?) "disclosure expands despite non-void callback"))

;; ---------------------------------------------------------------------------
;; status-bar% -- set-progress / clear
;; ---------------------------------------------------------------------------
(let ([bar (new status-bar% [parent f] [show-progress #t])])
  (send bar set-progress 100)
  (send bar clear)
  (check-equal? (send bar get-message) "" "status-bar clear empties the message"))

;; ---------------------------------------------------------------------------
;; progress-dialog% -- set-progress / set-message / cancelled?
;; ---------------------------------------------------------------------------
(let ([pd (new progress-dialog% [parent f] [label "t"] [cancellable #t])])
  (send pd set-progress 50)
  (send pd set-message "halfway")
  (check-false (send pd cancelled?) "progress-dialog starts not cancelled"))

;; ---------------------------------------------------------------------------
;; log-view% -- scroll-to-bottom is callable
;; ---------------------------------------------------------------------------
(let ([lv (new log-view% [parent f])])
  (send lv append-line "x")
  (send lv scroll-to-bottom))

;; ---------------------------------------------------------------------------
;; stack% -- show-page switches without error
;; ---------------------------------------------------------------------------
(let ([s (new stack% [parent f])])
  (send s add-page)
  (send s add-page)
  (send s show-page 1)
  (check-equal? (send s page-count) 2 "stack still counts pages"))
