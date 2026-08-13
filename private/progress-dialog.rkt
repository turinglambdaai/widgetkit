;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide progress-dialog%)

;; progress-dialog% — a modal dialog showing a message and a determinate
;; progress gauge, with an optional Cancel button.
;;
;; Why this exists: core racket/gui ships `gauge%` but no ready-made modal
;; progress dialog for a long-running task with cancellation. This is the
;; standard "Working… / Cancel" window every desktop app needs.
;;
;; Drive it from a worker thread while the dialog's `show` runs its modal
;; event loop; update the UI via `queue-callback`, and close with
;; `(send pd show #f)`. See examples/progress-dialog-demo.rkt for the pattern.
(define progress-dialog%
  (class dialog%
    (init-field [label "Working"] [cancellable #t] [on-cancel (λ () (void))])

    (super-new [label label] [width 380] [height 120] [alignment '(center center)])

    (define status-message
      (new message% [parent this] [label label] [min-width 320] [stretchable-width #t]))
    (define gauge (new gauge% [parent this] [label #f] [range 100] [min-width 320]))
    (define is-cancelled #f)

    (when cancellable
      (new button%
           [parent this]
           [label "Cancel"]
           [callback
            (λ (_b _e)
              (set! is-cancelled #t)
              (on-cancel))]))

    ;; Set progress as a percentage in [0, 100].
    (define/public (set-progress percentage)
      (send gauge set-value (inexact->exact (floor (min 100 (max 0 percentage))))))

    ;; Set the status message text.
    (define/public (set-message text) (send status-message set-label text))

    ;; Whether the user clicked Cancel.
    (define/public (cancelled?) is-cancelled)))
