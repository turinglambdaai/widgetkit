#lang racket/base

;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 turinglambdaai <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

(require racket/class
         racket/gui/base)

(provide notification-banner%)

;; notification-banner% -- a transient, dismissible message strip pinned to the
;; top of a window, with a severity (info/success/warning/error). It collapses
;; (hides itself) when dismissed or after an optional auto-dismiss timeout.
;;
;; Why this exists: this is the "flash a result, then it goes away" pattern
;; (SwiftUI banner, GTK in-app notification, web toast). core racket/gui has
;; `message-box` (modal, blocking) but no lightweight inline banner; our
;; `status-bar%` is for persistent text. notification-banner% fills the gap.
;;
;;   (define nb (new notification-banner% [parent f]))
;;   (send nb show-message "Saved." 'success 3000)       ; auto-dismiss after 3s
;;   (send nb show-message "Check input." 'warning #f)   ; stays until dismissed
(define (tint s)
  (case s
    [(success) (make-object color% #xe8 #xf6 #xee)]
    [(warning) (make-object color% #xfd #xf1 #xe0)]
    [(error) (make-object color% #xfd #xea #xeb)]
    [(info) (make-object color% #xe7 #xf3 #xfe)]
    [else (make-object color% #xf0 #xf0 #xf0)]))

(define (accent s)
  (case s
    [(success) "seagreen"]
    [(warning) "darkorange"]
    [(error) "crimson"]
    [(info) "dodgerblue"]
    [else "gray"]))

;; Truncate s to fit within avail pixels on dc's current font, appending an
;; ellipsis when cut. Without this a long message runs off the canvas and
;; under the close "x".
(define (fit-text dc s avail)
  (if (<= (send dc get-text-width s) avail)
      s
      (let loop ([len (sub1 (string-length s))])
        (cond
          [(<= len 1) "…"]
          [else
           (define candidate (string-append (substring s 0 len) "…"))
           (if (<= (send dc get-text-width candidate) avail)
               candidate
               (loop (sub1 len)))]))))

(define notification-banner%
  (class canvas%
    (init-field [min-height 32])

    (super-new [stretchable-height #f] [stretchable-width #t] [min-height min-height] [min-width 120])

    (inherit get-dc
             get-client-size
             refresh)

    (define text #f)
    (define severity 'info)
    (define timer #f)
    (define close-hover? #f)

    (define hand-cursor (make-object cursor% 'hand))
    (define arrow-cursor (make-object cursor% 'arrow))

    ;; Start hidden; the banner only appears on show-message.
    (send this show #f)

    ;; Is x inside the close zone (the last 24 pixels on the right)?
    (define (in-close-zone? x w)
      (> x (- w 24)))

    ;; Drop the hover highlight and restore the cursor.
    (define (reset-hover!)
      (when close-hover?
        (set! close-hover? #f)
        (send this set-cursor arrow-cursor)))

    ;; Show a message. severity is one of info/success/warning/error; pass #f
    ;; for auto-dismiss-ms to keep the banner up, or a number of milliseconds
    ;; after which it hides itself.
    (define/public (show-message msg sev auto-dismiss-ms)
      (set! text
            (if (string? msg)
                msg
                (format "~a" msg)))
      (set! severity sev)
      (reset-hover!)
      (send this show #t)
      (refresh)
      (when timer
        (send timer stop)
        (set! timer #f))
      (when auto-dismiss-ms
        (set! timer
              (new timer%
                   [notify-callback (lambda () (hide))]
                   [interval auto-dismiss-ms]
                   [just-once? #t]))))

    ;; Hide (collapse) the banner.
    (define/public (hide)
      (when timer
        (send timer stop)
        (set! timer #f))
      (reset-hover!)
      (set! text #f)
      (send this show #f))

    ;; The current message text, or #f when hidden.
    (define/public (current-message) text)

    (define/override (on-paint)
      (when text
        (define dc (get-dc))
        (define-values (w h) (get-client-size))
        (send dc set-pen (new pen% [style 'transparent]))
        (send dc set-brush (new brush% [color (tint severity)] [style 'solid]))
        (send dc draw-rectangle 0 0 w h)
        (send dc set-pen (new pen% [color (accent severity)] [width 4] [style 'solid] [cap 'butt]))
        (send dc draw-line 2 6 2 (- h 6))
        (when close-hover?
          (define shade (make-object color% 0 0 0))
          (send shade set-alpha 0.08)
          (send dc set-pen (new pen% [style 'transparent]))
          (send dc set-brush (new brush% [color shade] [style 'solid]))
          (send dc draw-rectangle (- w 24) 2 22 (- h 4))
          (send dc set-pen (new pen% [color (accent severity)] [width 1] [style 'solid])))
        (define msg (fit-text dc text (- w 36)))
        (send dc draw-text msg 14 7)
        (send dc draw-text "x" (- w 16) 7)))

    (define/override (on-event e)
      (define type (send e get-event-type))
      (cond
        ;; Click in the close zone dismisses the banner.
        [(and (eq? type 'left-down) text)
         (define-values (w h) (get-client-size))
         (when (in-close-zone? (send e get-x) w)
           (hide))]
        ;; Track the pointer over the close zone: hand cursor + highlight.
        [(or (eq? type 'motion) (eq? type 'enter))
         (define-values (w h) (get-client-size))
         (define hover? (and text (in-close-zone? (send e get-x) w)))
         (unless (eq? hover? close-hover?)
           (set! close-hover? hover?)
           (send this set-cursor (if hover? hand-cursor arrow-cursor))
           (refresh))]
        [(eq? type 'leave)
         (reset-hover!)
         (refresh)]))))
