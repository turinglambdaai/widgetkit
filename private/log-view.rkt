;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 turinglambdaai <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base
         racket/string)

(provide log-view%)

;; log-view% — a scrolling, read-only, monospace log/console output.
;;
;; Why this exists: building this from core `editor-canvas%` + `text%` is where
;; everyone gets stuck — the canvas won't stretch (parent container trap), it
;; does not auto-scroll to the newest line, making it read-only also blocks
;; programmatic inserts, and long-running logs grow without bound. `log-view%`
;; handles all of it: it stretches to fill its parent by default, appends lines
;; and auto-scrolls to the bottom, stays read-only to the user while still
;; accepting programmatic appends, and trims old lines past `max-lines`.
;;
;;   (define log (new log-view% [parent f]))
;;   (send log append-line "[boot] ready")
(define log-view%
  (class editor-canvas%
    (init-field [max-lines 10000] [monospace? #t] [wrap? #t] [read-only? #t])

    ;; Build the editor first (no `this` needed), then hand it to the canvas.
    (define editor (new text%))
    (send editor auto-wrap wrap?)

    (super-new [editor editor]
               [style
                (if wrap?
                    '(no-hscroll)
                    '())])
    ;; editor-canvas% defaults to stretchable in both dimensions, so log-view%
    ;; fills its parent automatically. Callers can still override min-width,
    ;; min-height, stretchable-*, etc. via the usual init fields.

    (define mono-delta (and monospace? (make-object style-delta% 'change-family 'modern)))

    ;; A read-only lock also blocks programmatic edits, so toggle it around
    ;; each mutation.
    (when read-only?
      (send editor lock #t))
    (define (unlock!)
      (when read-only?
        (send editor lock #f)))
    (define (relock!)
      (when read-only?
        (send editor lock #t)))

    ;; Append a line of text (a trailing newline is ensured) and scroll to it.
    ;; Non-strings are formatted with ~a.
    (define/public (append-line line)
      (define s
        (if (string? line)
            line
            (format "~a" line)))
      (define text
        (if (string-suffix? s "\n")
            s
            (string-append s "\n")))
      (unlock!)
      (define start (send editor last-position))
      (send editor insert text start)
      (when mono-delta
        (send editor change-style mono-delta start (send editor last-position)))
      (trim!)
      (send editor scroll-to-position (send editor last-position))
      (relock!))

    ;; Drop the oldest lines once the buffer exceeds max-lines.
    (define (trim!)
      (define nl (send editor last-line))
      (when (> nl max-lines)
        (send editor delete 0 (send editor line-start-position (- nl max-lines)))))

    ;; Erase the whole log.
    (define/public (clear)
      (unlock!)
      (send editor erase)
      (relock!))

    ;; All log text as a string.
    (define/public (get-text) (send editor get-text))

    ;; Scroll so the most recent line is visible.
    (define/public (scroll-to-bottom) (send editor scroll-to-position (send editor last-position)))))
