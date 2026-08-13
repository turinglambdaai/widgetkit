;; mini-task-list.rkt — a small but realistic app composed from widgetkit.
;; Run: racket examples/mini-task-list.rkt
;;
;; Shows how to combine several widgets into a real UI: a table-panel% input
;; row, a labeled-field%, a text-list%, a disclosure% of actions, and a
;; status-bar%. Clone this as a starting point for your own application.
#lang racket/base

(require racket/class
         racket/gui/base
         racket/string
         widgetkit)

(define f
  (new frame% [label "widgetkit — mini task list"] [width 500] [height 440] [alignment '(left top)]))

;; --- Input row: a 1x3 grid (label : field : Add button) ------------------
(define input-row (new table-panel% [parent f] [dimensions '(1 3)]))
(new message% [parent input-row] [label "New task:"])
(define field
  (new labeled-field%
       [parent input-row]
       [label #f]
       [cue "Add a task and press Add"]
       [tooltip "Type a task name"]))
(new button% [parent input-row] [label "Add"] [callback (λ (_b _e) (add-task))])

;; --- The task list --------------------------------------------------------
(define tasks '()) ; list of strings
(define lst
  (new text-list%
       [parent f]
       [items #()]
       [item-height 22]
       [min-height 220]
       [action (λ (item) (status (format "Selected: ~a" item)))]))

;; --- Collapsible actions --------------------------------------------------
(define actions (new disclosure% [parent f] [label "Actions"] [expanded? #f]))
(new button%
     [parent (send actions get-content)]
     [label "Remove selected"]
     [callback (λ (_b _e) (remove-selected))])
(new button%
     [parent (send actions get-content)]
     [label "Clear all"]
     [callback (λ (_b _e) (clear-all))])

;; --- Status bar -----------------------------------------------------------
(define bar (new status-bar% [parent f] [initial-message "Ready."]))
(define (status msg)
  (send bar set-message msg))

;; --- Model operations -----------------------------------------------------
(define (refresh)
  (send lst set-items (list->vector tasks))
  (status (format "~a task(s)" (length tasks))))

(define (add-task)
  (define t (string-trim (send field get-value)))
  (cond
    [(string=? t "") (status "Empty task — nothing added.")]
    [else
     (set! tasks (append tasks (list t)))
     (send field set-value "")
     (refresh)]))

(define (remove-selected)
  (define idx (send lst get-selected-index))
  (cond
    [(not idx) (status "Nothing selected.")]
    [else
     (set! tasks
           (for/list ([t tasks]
                      [i (in-naturals)]
                      #:unless (= i idx))
             t))
     (refresh)
     (status "Removed.")]))

(define (clear-all)
  (set! tasks '())
  (refresh)
  (status "Cleared all."))

(refresh)
(send f show #t)
