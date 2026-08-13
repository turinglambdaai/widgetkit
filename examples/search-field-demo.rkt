;; search-field% — minimal demo (live filtering of a list)
;; Run: racket examples/search-field-demo.rkt
#lang racket/base
(require racket/class
         racket/gui/base
         racket/string
         widgetkit)

(define all-items (for/list ([i (in-range 1 41)]) (format "item ~a" i)))

(define f (new frame% [label "search-field% demo"] [width 320] [height 380]
               [alignment '(left top)]))

(define lst
  (new text-list% [parent f] [items (list->vector all-items)] [item-height 22] [min-height 280]))

;; The callback fires on every keystroke with the current query.
(new search-field% [parent f]
     [callback (λ (q) (refresh q))])

(define (refresh q)
  (define needle (string-downcase (string-trim q)))
  (define matches
    (if (string=? needle "")
        all-items
        (filter (λ (s) (string-contains? (string-downcase s) needle)) all-items)))
  (send lst set-items (list->vector matches)))

(send f show #t)
