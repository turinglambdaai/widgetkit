;; image-view% — minimal demo (display a bitmap, scaled to fit)
;; Run: racket examples/image-view-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         racket/draw
         widgetkit)

(define f
  (new frame% [label "image-view% demo"] [width 420] [height 280] [alignment '(center center)]))

;; Build a bitmap in memory so the example is self-contained (no asset file).
(define bmp (make-object bitmap% 240 140))
(define bdc (new bitmap-dc% [bitmap bmp]))
(send bdc set-brush (new brush% [color "midnightblue"] [style 'solid]))
(send bdc draw-rectangle 0 0 240 140)
(send bdc set-text-foreground "white")
(send bdc draw-text "widgetkit" 20 50)
(send bdc draw-text "image-view%" 20 75)
(send bdc set-bitmap #f)

(new image-view% [parent f] [bitmap bmp] [scale 'fit])

;; `racket` runs `main`; `raco test` only instantiates the module (smoke test).
(module+ main
  (send f show #t))
