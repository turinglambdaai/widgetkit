;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/math
         racket/gui/base)

(provide spinner%)

;; spinner% — an indeterminate circular activity indicator.
;;
;; Why this exists: core racket/gui only ships `gauge%`, which is determinate
;; (you must know the percentage). There is no "busy, unknown duration"
;; indicator. `spinner%` fills that gap with a lightweight rotating-arc canvas
;; driven by a timer. Use `start` while work is in progress and `stop` when it
;; finishes.
(define spinner%
  (class canvas%
    (init-field [diameter 24]
                [color "dodgerblue"]
                [track-color "lightgray"]
                [interval 60]) ; milliseconds per frame

    (super-new [min-width diameter]
               [min-height diameter]
               [stretchable-width #f]
               [stretchable-height #f])

    (inherit get-dc
             get-client-size
             refresh)

    ;; Pens are built once from the fixed diameter (the spinner is non-resizable).
    (define line-width (max 2.0 (/ diameter 5.0)))
    (define arc-pen (new pen% [color color] [width line-width] [style 'solid] [cap 'round]))
    (define track-pen (new pen% [color track-color] [width line-width] [style 'solid] [cap 'round]))
    (define clear-brush (new brush% [style 'transparent]))

    (define angle 0.0)
    (define running? #f)
    (define timer #f)

    ;; One animation step: advance the angle and repaint.
    (define tick
      (λ ()
        (set! angle (+ angle 0.35))
        (refresh)))

    ;; Begin spinning. Idempotent.
    (define/public (start)
      (unless running?
        (set! running? #t)
        (unless timer
          (set! timer (new timer% [notify-callback tick] [interval interval] [just-once? #f])))
        (send timer start interval #f)
        (refresh)))

    ;; Stop spinning. Idempotent.
    (define/public (stop)
      (when timer
        (send timer stop))
      (set! running? #f)
      (refresh))

    ;; Whether the spinner is currently animating.
    (define/public (spinning?) running?)

    ;; Draw a faint full ring plus, while spinning, a brighter sweeping arc.
    (define/override (on-paint)
      (define dc (get-dc))
      (define-values (w h) (get-client-size))
      (define size (min w h))
      (define cx (/ w 2))
      (define cy (/ h 2))
      (define r (max 1.0 (/ (- size line-width) 2.0)))
      (define old-pen (send dc get-pen))
      (define old-brush (send dc get-brush))
      (send dc set-brush clear-brush)
      (send dc set-pen track-pen)
      (send dc draw-ellipse (- cx r) (- cy r) (* 2 r) (* 2 r))
      (when running?
        (send dc set-pen arc-pen)
        ;; draw-arc sweeps counter-clockwise from start angle to end angle.
        (send dc draw-arc (- cx r) (- cy r) (* 2 r) (* 2 r) angle (+ angle (* 2.0 pi 0.83))))
      (send dc set-pen old-pen)
      (send dc set-brush old-brush))))
