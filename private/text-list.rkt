;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base
         canvas-list)                  ; canvas-list%

(provide text-list%)

;; A `canvas-list%` variant for the common case: items rendered as their own
;; text, with a simple one-argument action callback `(λ (item) ...)`.
;;
;; Why this exists: `canvas-list%`'s action-callback is a three-argument
;; procedure `(λ (canvas item event) ...)`, which is easy to get wrong.
;; `text-list%` accepts a one-argument `action` and forwards the selected item.
;; Everything else (virtualization, selection, sorting, filtering) is inherited
;; from `canvas-list%`.
;;
;;   (new text-list% [parent f]
;;        [items (vector "a" "b" "c")]
;;        [action (λ (item) (printf "picked ~a\n" item))])
(define text-list%
  (class canvas-list%
    (init-field [action (λ (item) (void))])
    (super-new
     [action-callback (λ (_canvas item _event) (action item))])))
