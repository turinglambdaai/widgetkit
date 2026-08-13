;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 turinglambdaai <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide status-bar%)

;; status-bar% — a compact bar for the bottom of a window: a status message
;; plus an optional determinate progress gauge.
;;
;; Why this exists: core racket/gui ships `message%` (text) and `gauge%`
;; (progress), but no ready-made status bar, so every app rewrites this layout
;; by hand. `status-bar%` packages the common case behind a small API
;; (`set-message`, `set-progress`, `clear`). It subclasses `horizontal-panel%`,
;; so extra trailing children (e.g. a Cancel button) can be appended directly.
(define status-bar%
  (class horizontal-panel%
    (init [initial-message ""]
          [show-progress #f])

    (super-new [alignment '(left center)] [stretchable-height #f] [spacing 8] [border 0])

    ;; The status text. Fixed min-width + stretchable-width means long messages
    ;; are clipped by the panel rather than forcing the window to grow.
    (define status-message
      (new message% [parent this] [label initial-message] [min-width 240] [stretchable-width #t]))

    ;; Optional determinate gauge (0..100). Only created on demand so a
    ;; plain-text status bar pays no progress cost.
    (define progress-gauge
      (and show-progress
           (new gauge% [parent this] [label #f] [range 100] [min-width 140] [stretchable-width #f])))

    ;; Set the status text.
    (define/public (set-message text)
      (unless (string? text)
        (raise-argument-error 'status-bar.set-message "string?" text))
      (send status-message set-label text))

    ;; Set progress as a percentage in [0, 100]. No-op when the bar was created
    ;; without #:show-progress.
    (define/public (set-progress percentage)
      (unless (and (real? percentage) (<= 0 percentage 100))
        (raise-argument-error 'status-bar.set-progress "real? in [0, 100]" percentage))
      (when progress-gauge
        (send progress-gauge set-value (inexact->exact (floor (min 100 (max 0 percentage)))))))

    ;; Current status text.
    (define/public (get-message) (send status-message get-label))

    ;; Reset to an empty message and zero progress.
    (define/public (clear)
      (send status-message set-label "")
      (when progress-gauge
        (send progress-gauge set-value 0)))))
