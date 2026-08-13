;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide disclosure%)

;; disclosure% — a collapsible section: a header button that toggles the
;; visibility of a content panel.
;;
;; Why this exists: core racket/gui has no expand/collapse ("disclosure")
;; container, which is the standard pattern for settings pages ("Advanced
;; options...", "More filters"). Add the hidden children to the panel returned
;; by `get-content`.
;;
;;   (define d (new disclosure% [parent f] [label "Advanced"] [expanded? #f]))
;;   (new check-box% [parent (send d get-content)] [label "Verbose logging"])
(define disclosure%
  (class vertical-panel%
    (init-field [label "Section"] [expanded? #f] [callback (λ (self) (void))])

    (super-new [alignment '(left top)] [stretchable-height #f] [spacing 4])

    (define (header-label)
      (string-append (if expanded? "[-] " "[+] ") label))

    (define header
      (new button% [parent this] [label (header-label)] [callback (λ (_b _e) (toggle!))]))

    ;; Children added here are shown/hidden together when toggling.
    (define content (new vertical-panel% [parent this] [alignment '(left top)] [spacing 6]))

    (send content show expanded?)

    (define (toggle!)
      (set! expanded? (not expanded?))
      (send header set-label (header-label))
      (send content show expanded?)
      (callback this))

    ;; The panel to add collapsible children to.
    (define/public (get-content) content)

    ;; Whether the section is currently expanded.
    (define/public (is-expanded?) expanded?)

    ;; Expand or collapse the section programmatically.
    (define/public (set-expanded! e)
      (unless (eq? e expanded?)
        (toggle!)))))
