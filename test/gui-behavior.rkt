;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
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
;; search-field% -- text round-trip
;; ---------------------------------------------------------------------------
(let ([sf (new search-field% [parent f] [callback (lambda (_q) (void))])])
  (send sf set-text "query")
  (check-equal? (send sf get-text) "query" "search-field stores text"))
