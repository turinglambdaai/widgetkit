;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base
         racket/draw)

(provide image-view%)

;; image-view% — a canvas that displays a bitmap, optionally scaled to fit.
;;
;; Why this exists: core racket/gui has `canvas%` but no ready-made widget to
;; just show an image; you have to wire up an `on-paint` and a drawing context
;; every time. `image-view%` takes a `bitmap%` (or loads one from a file) and
;; centers it, fitting to the available space or drawn at a fixed scale.
;;
;;   (new image-view% [parent f] [bitmap some-bitmap%] [scale 'fit])
;;   (define iv (new image-view% [parent f])) (send iv load-file "photo.png")
(define image-view%
  (class canvas%
    (init-field [bitmap #f]
                [scale 'fit])             ; 'fit, or a positive number

    (super-new
     [min-width 100]
     [min-height 100]
     [stretchable-width #t]
     [stretchable-height #t])

    (inherit get-dc get-client-size refresh)

    (define the-bitmap bitmap)

    ;; Replace the displayed bitmap.
    (define/public (set-bitmap b)
      (set! the-bitmap b)
      (refresh))

    ;; Load and display a bitmap from a file path.
    (define/public (load-file path)
      (set! the-bitmap (read-bitmap path))
      (refresh))

    ;; The currently displayed bitmap (or #f).
    (define/public (get-bitmap) the-bitmap)

    (define/override (on-paint)
      (define dc (get-dc))
      (define-values (cw ch) (get-client-size))
      (cond
        [(or (not the-bitmap) (not (send the-bitmap ok?)))
         (send dc draw-text "no image" 8 8)]
        [else
         (define bw (send the-bitmap get-width))
         (define bh (send the-bitmap get-height))
         (define raw-s (if (eq? scale 'fit)
                           (if (and (> bw 0) (> bh 0) (> cw 0) (> ch 0))
                               (min (/ cw bw) (/ ch bh))
                               1.0)
                           scale))
         (define s (if (and (number? raw-s) (positive? raw-s)) raw-s 1.0))
         (define dw (* bw s))
         (define dh (* bh s))
         (define x (/ (- cw dw) 2.0))
         (define y (/ (- ch dh) 2.0))
         ;; Preserve the device context's existing scale (HiDPI) while drawing
         ;; at the computed logical size, then restore it.
         (define-values (osx osy) (send dc get-scale))
         (send dc set-scale (* osx s) (* osy s))
         (send dc draw-bitmap the-bitmap (/ x (* osx s)) (/ y (* osy s)))
         (send dc set-scale osx osy)]))))
