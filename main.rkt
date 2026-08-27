#|
widgetkit

Contributors:
  [turinglambdaai] <jirentianxiang1024@gmail.com>

Copyright (c) 2026 [turinglambdaai]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
|#

#lang racket/base

;; widgetkit -- a curated collection of GUI widgets for Racket.
;;
;; All public widgets are exported with contracts (see `contract-out` below):
;; every method and key initialization argument is runtime-checked, with blame
;; pointing at the caller that misused the API. This is the boundary; code
;; inside private/ is unchecked.

(require racket/contract
         racket/class
         racket/gui/base)

(require "private/status-bar.rkt"
         "private/spinner.rkt"
         "private/stepper.rkt"
         "private/labeled-field.rkt"
         "private/text-list.rkt"
         "private/disclosure.rkt"
         "private/image-view.rkt"
         "private/progress-dialog.rkt"
         "private/log-view.rkt"
         "private/split-view.rkt"
         "private/toolbar.rkt"
         "private/search-field.rkt"
         "private/stack.rkt"
         "private/notification-banner.rkt")

;; A color accepted by racket/gui drawing: a color name/string or a color%.
(define color/c (or/c string? (is-a?/c color%)))
;; A positive real number.
(define positive-real/c (and/c real? positive?))
;; A panel/pane container instance (what get-content / get-first return).
(define container/c (is-a?/c area-container<%>))

;; ---------------------------------------------------------------------------
;; Layer 1 -- gap-filling widgets (this repository), exported with contracts
;; ---------------------------------------------------------------------------

(provide (contract-out
          ;; status-bar%
          [status-bar%
           (class/c (init [initial-message string?]
                          [show-progress any/c])
                    (set-message (->m string? void?))
                    (set-progress (->m (real-in 0 100) void?))
                    (get-message (->m string?))
                    (clear (->m void?)))]
          ;; spinner%
          [spinner%
           (class/c (init-field [diameter positive-real/c]
                                [color color/c]
                                [track-color color/c]
                                [interval positive-real/c])
                    (start (->m void?))
                    (stop (->m void?))
                    (spinning? (->m boolean?)))]
          ;; stepper%
          [stepper%
           (class/c (init-field [min-value number?]
                                [max-value number?]
                                [step number?]
                                [initial number?]
                                [show-value any/c])
                    (get-value (->m number?))
                    (set-value (->m number? void?))
                    (increment (->m void?))
                    (decrement (->m void?)))]
          ;; clamp -- the numeric helper behind stepper%'s clamping
          [clamp (-> real? real? real? real?)]
          ;; disclosure%
          [disclosure%
           (class/c (init-field [label string?] [expanded? any/c])
                    (get-content (->m container/c))
                    (is-expanded? (->m boolean?))
                    (set-expanded! (->m any/c void?)))]
          ;; image-view%
          [image-view%
           (class/c (init-field [bitmap (or/c (is-a?/c bitmap%) #f)]
                                [scale (or/c 'fit positive-real/c)])
                    (set-bitmap (->m (or/c (is-a?/c bitmap%) #f) void?))
                    (load-file (->m (or/c path? string?) void?))
                    (get-bitmap (->m (or/c (is-a?/c bitmap%) #f))))]
          ;; progress-dialog%
          [progress-dialog%
           (class/c (init-field [label string?] [cancellable any/c])
                    (set-progress (->m (real-in 0 100) void?))
                    (set-message (->m string? void?))
                    (cancelled? (->m boolean?)))]
          ;; log-view%
          [log-view%
           (class/c (init-field [max-lines exact-positive-integer?]
                                [monospace? any/c]
                                [wrap? any/c]
                                [read-only? any/c])
                    (append-line (->m any/c void?))
                    (clear (->m void?))
                    (get-text (->m string?))
                    (scroll-to-bottom (->m void?)))]
          ;; split-view%
          [split-view%
           (class/c (init-field [orientation (or/c 'horizontal 'vertical)] [fraction (real-in 0 1)])
                    (set-fraction (->m (real-in 0 1) void?))
                    (get-fraction (->m (real-in 0 1)))
                    (get-first (->m container/c))
                    (get-second (->m container/c)))]
          ;; toolbar%
          [toolbar%
           (class/c (add-button (->m string? (-> any) (is-a?/c button%)))
                    (add-separator (->m (is-a?/c canvas%))))]
          ;; search-field%
          [search-field%
           (class/c (init-field [label (or/c string? #f)] [cue string?] [callback (-> string? any/c)])
                    (get-text (->m string?))
                    (set-text (->m string? void?)))]
          ;; stack%
          [stack%
           (class/c (add-page (->m container/c))
                    (page-count (->m exact-nonnegative-integer?))
                    (show-page (->m exact-nonnegative-integer? void?)))]
          ;; labeled-field% -- a text-field% subclass (cue + tooltip baked in)
          [labeled-field% (class/c (init-field [cue string?] [tooltip (or/c string? #f)]))]
          ;; text-list% -- a canvas-list% subclass
          [text-list% (class/c (init-field [action (-> any/c any/c)]))]
          ;; notification-banner%
          [notification-banner%
           (class/c
            (show-message
             (->m string? (or/c 'info 'success 'warning 'error) (or/c #f positive-real/c) void?))
            (hide (->m void?))
            (current-message (->m (or/c string? #f))))]))

;; ---------------------------------------------------------------------------
;; Layer 2 -- aggregated widgets (re-exported from mature upstream packages,
;; which already carry their own contracts). A single (require widgetkit)
;; brings them in alongside Layer 1.
;; ---------------------------------------------------------------------------

(require gui-widget-mixins ; tooltips, cue text, validation for text-field%
         table-panel ; grid-aligned layout panel
         canvas-list ; fast virtualized, custom-draw list
         text-date) ; date entry text field

(provide (all-from-out gui-widget-mixins)
         (all-from-out table-panel)
         (all-from-out canvas-list)
         (all-from-out text-date))
