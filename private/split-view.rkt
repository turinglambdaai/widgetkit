;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base)

(provide split-view%)

;; split-view% — two panes separated by a draggable divider (Qt's QSplitter /
;; GTK's GtkPaned).
;;
;; Why this exists: core racket/gui has no draggable split. Doing it by hand
;; means overriding panel layout geometry, capturing mouse drags in screen
;; coordinates (the sash's own origin moves while dragging), and forcing a
;; relayout on each move — all easy to get wrong. split-view% packages it.
;;
;; Add children to the two sides via get-first / get-second. The divider is
;; mouse-draggable; fraction (0..1, the first pane's share) can also be set
;; programmatically with set-fraction.
;;
;;   (define sv (new split-view% [parent f] [orientation 'horizontal] [fraction 0.4]))
;;   (new text-list% [parent (send sv get-first)] ...)
;;   (new log-view%  [parent (send sv get-second)] ...)

;; Paint the sash as a subtle bar so it reads as a grab handle.
(define (draw-sash canvas dc)
  (define-values (w h) (send canvas get-client-size))
  (send dc set-pen (new pen% [color "gainsboro"] [width 1] [style 'transparent]))
  (send dc set-brush (new brush% [color "gainsboro"] [style 'solid]))
  (send dc draw-rectangle 0 0 w h))

;; A draggable divider. It forwards drag deltas to its owner split-view using
;; screen coordinates (via client->screen), which stay stable as the sash moves.
(define sash%
  (class canvas%
    (init-field owner thickness draw)
    (super-new [min-width thickness] [min-height thickness])
    (define/override (on-paint) (draw this (send this get-dc)))
    (define/override (on-event e)
      (define-values (sx sy) (send this client->screen (send e get-x) (send e get-y)))
      (define t (send e get-event-type))
      (cond
        [(eq? t 'left-down) (send owner begin-drag sx sy)]
        [(eq? t 'motion) (send owner update-drag sx sy)]
        [(eq? t 'left-up) (send owner end-drag)]))))

(define split-view%
  (class panel%
    (init-field [orientation 'horizontal] [fraction 0.5])

    (super-new [border 0] [spacing 0] [alignment '(center center)])

    (define sash-thickness 6)
    (define area1 (new panel% [parent this]))
    (define area2 (new panel% [parent this]))
    (define sash (new sash% [parent this] [owner this] [thickness sash-thickness] [draw draw-sash]))

    ;; --- drag state (screen-space) ---
    (define drag-start-screen #f)
    (define drag-start-frac #f)

    (define/public (begin-drag sx sy)
      (set! drag-start-screen (cons sx sy))
      (set! drag-start-frac fraction))

    (define/public (update-drag sx sy)
      (when drag-start-screen
        (define-values (cw ch) (send this get-client-size))
        (define horizontal? (eq? orientation 'horizontal))
        (define avail (max 1 (- (if horizontal? cw ch) sash-thickness)))
        (define start
          (if horizontal?
              (car drag-start-screen)
              (cdr drag-start-screen)))
        (define now (if horizontal? sx sy))
        (set-fraction (+ drag-start-frac (/ (- now start) avail)))))

    (define/public (end-drag) (set! drag-start-screen #f))

    ;; Set the first pane's share (clamped to [0,1]) and trigger a relayout.
    (define/public (set-fraction f)
      (set! fraction (max 0.0 (min 1.0 f)))
      (send this change-children (λ (l) l)))

    (define/public (get-fraction) fraction)
    (define/public (get-first) area1)
    (define/public (get-second) area2)

    ;; --- custom layout ---
    ;; Children are created in order [area1, area2, sash], so `info` follows
    ;; that order. place-children returns geometry in the same order.
    ;; Each info entry is (min-width min-height stretchable-width stretchable-height).
    (define (min-w i)
      (list-ref i 0))
    (define (min-h i)
      (list-ref i 1))

    (define/override (container-size info)
      (define a1 (list-ref info 0))
      (define a2 (list-ref info 1))
      (if (eq? orientation 'horizontal)
          (values (+ (min-w a1) sash-thickness (min-w a2)) (max (min-h a1) (min-h a2)))
          (values (max (min-w a1) (min-w a2)) (+ (min-h a1) sash-thickness (min-h a2)))))

    (define/override (place-children info w h)
      (define horizontal? (eq? orientation 'horizontal))
      (define avail (max 0 (- (if horizontal? w h) sash-thickness)))
      (define a1-size (inexact->exact (round (* fraction avail))))
      (if horizontal?
          (let ([a1w a1-size]
                [a2w (max 0 (- avail a1-size))])
            (list (list 0 0 a1w h)
                  (list (+ a1w sash-thickness) 0 a2w h)
                  (list a1w 0 sash-thickness h)))
          (let ([a1h a1-size]
                [a2h (max 0 (- avail a1-size))])
            (list (list 0 0 w a1h)
                  (list 0 (+ a1h sash-thickness) w a2h)
                  (list 0 a1h w sash-thickness)))))))
