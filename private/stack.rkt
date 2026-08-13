;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide stack%)

;; stack% — a container that shows one of several "pages" at a time, stretching
;; the visible page to fill the area.
;;
;; Why this exists: this is QStackedWidget / SwiftUI's selection-driven content.
;; It also cleans up the `tab-panel%` footgun: pair a `choice%` (or
;; `tab-panel%`) with a `stack%` to get working tabbed/switched content without
;; the manual show/hide dance and the "tab-panel% has no callback" trap.
;;
;;   (define pages (new stack% [parent f]))
;;   (define p0 (send pages add-page)) (new message% [parent p0] [label "A"])
;;   (define p1 (send pages add-page)) (new message% [parent p1] [label "B"])
;;   (send pages show-page 0)
(define stack%
  (class vertical-panel%
    (init [alignment '(left top)])
    (super-new [alignment alignment])

    (define the-pages '())

    ;; Add a new (initially hidden) page and return the panel to fill with
    ;; children.
    (define/public (add-page)
      (define p (new vertical-panel% [parent this] [alignment '(left top)]))
      (set! the-pages (append the-pages (list p)))
      (send p show #f)
      p)

    ;; Number of pages added.
    (define/public (page-count) (length the-pages))

    ;; Show only page i (0-based), hiding the rest.
    (define/public (show-page i)
      (unless (and (exact-nonnegative-integer? i) (< i (length the-pages)))
        (error 'stack.show-page "index out of range: ~a" i))
      (for ([p the-pages]
            [j (in-naturals)])
        (send p show (= j i))))))
