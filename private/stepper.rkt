;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 turinglambdaai <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide stepper%
         clamp)

;; Clamp v into the closed interval [lo, hi].
(define (clamp v lo hi)
  (max lo (min hi v)))

;; stepper% — a compact [-] value [+] numeric stepper.
;;
;; Why this exists: core racket/gui has `slider%` for picking a value from a
;; range, but no compact +/- control for small numeric tweaks (think
;; "quantity: 2" or "margin: 8 px"). `stepper%` provides clamped increments
;; with an optional value readout and an on-change callback.
(define stepper%
  (class horizontal-panel%
    (init-field [min-value 0]
                [max-value 100]
                [step 1]
                [initial 0]
                [callback (λ (self) (void))]
                [show-value #t])

    (super-new [alignment '(center center)] [stretchable-height #f] [spacing 4])

    (define current (clamp initial min-value max-value))
    (define value-label #f)

    (define refresh-label
      (λ ()
        (when value-label
          (send value-label set-label (number->string current)))))

    ;; Apply a (possibly out-of-range, possibly inexact) new value, clamping and
    ;; notifying only on actual change.
    (define do-set
      (λ (v)
        (define newv (clamp (inexact->exact (truncate v)) min-value max-value))
        (unless (= newv current)
          (set! current newv)
          (refresh-label)
          (callback this))))

    (define/public (get-value) current)

    (define/public (set-value v) (do-set v))

    (define/public (increment) (do-set (+ current step)))

    (define/public (decrement) (do-set (- current step)))

    ;; Build children in display order: [-] [value] [+].
    (new button%
         [parent this]
         [label "-"]
         [min-width 30]
         [callback (λ (_b _e) (send this decrement))])

    (when show-value
      (set! value-label
            (new message%
                 [parent this]
                 [label (number->string current)]
                 [min-width 40]
                 [stretchable-width #f])))

    (new button%
         [parent this]
         [label "+"]
         [min-width 30]
         [callback (λ (_b _e) (send this increment))])))
