;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 turinglambdaai <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide toolbar%)

;; Draw a thin vertical separator line (used by add-separator).
(define (draw-separator canvas dc)
  (define-values (w h) (send canvas get-client-size))
  (send dc set-pen (new pen% [color "gray"] [width 1] [style 'solid]))
  (send dc draw-line 1 4 1 (max 5 (- h 4))))

;; toolbar% — a horizontal row of action buttons with optional separators,
;; pinned to a fixed height. A thin convenience over `horizontal-panel%` that
;; standardizes the pattern every desktop app uses, with thunk-based callbacks
;; (no need to remember `button%`'s two-argument signature) and a real drawn
;; separator.
;;
;;   (define tb (new toolbar% [parent f]))
;;   (send tb add-button "Open" (λ () ...))
;;   (send tb add-separator)
;;   (send tb add-button "Quit" (λ () ...))
;; Since it is a `horizontal-panel%`, any other widget can be added directly
;; with `[parent tb]`.
(define toolbar%
  (class horizontal-panel%
    (init [alignment '(left center)])

    (super-new [alignment alignment] [stretchable-height #f] [spacing 4] [border 2])

    ;; Add a button whose callback is a no-argument thunk; returns the button%
    ;; (e.g. to enable/disable it later).
    (define/public (add-button label cb)
      (new button% [parent this] [label label] [callback (λ (_b _e) (cb))]))

    ;; Add a thin vertical separator between groups of actions; returns the
    ;; separator canvas%.
    (define/public (add-separator)
      (new canvas%
           [parent this]
           [min-width 2]
           [stretchable-width #f]
           [stretchable-height #t]
           [paint-callback draw-separator]))))
