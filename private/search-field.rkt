;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base
         "labeled-field.rkt")

(provide search-field%)

;; search-field% — a "Search…" box that fires a live callback on every change,
;; with a clear button.
;;
;; Why this exists: a filter/search entry is one of the most common controls
;; (SwiftUI `.searchable`, GtkSearchEntry), and wiring it from `text-field%`
;; means remembering the callback fires with a `(text-field%, event)` signature
;; and adding your own clear affordance. `search-field%` takes a one-argument
;; `(lambda (query) ...)` callback fired on each keystroke and on clear.
;;
;;   (new search-field% [parent f] [callback (lambda (q) (filter-items q))])
(define search-field%
  (class horizontal-panel%
    (init-field [label #f] [cue "Search…"] [callback (λ (text) (void))])

    (super-new [alignment '(left center)] [stretchable-height #f] [spacing 2])

    (define field
      (new labeled-field%
           [parent this]
           [label label]
           [cue cue]
           [callback (λ (f _event) (callback (send f get-value)))]))

    (new button%
         [parent this]
         [label "×"]
         [callback
          (λ (_b _e)
            (send field set-value "")
            (callback ""))])

    ;; The current query text.
    (define/public (get-text) (send field get-value))

    ;; Set the query text (does not fire the callback).
    (define/public (set-text t) (send field set-value t))))
