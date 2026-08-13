#|
widgetkit

Contributors:
  [jrtxio] <jirentianxiang1024@gmail.com>

Copyright (c) 2026 [jrtxio]

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

;; widgetkit — a curated collection of GUI widgets for Racket.
;;
;; The collection has two layers:
;;
;;   1. Gap-filling widgets (new, MIT) — small controls core racket/gui lacks:
;;      status-bar%, spinner%, stepper%.
;;   2. Aggregated widgets — re-exported from mature, standalone packages so a
;;      single (require widgetkit) brings in the most commonly needed controls
;;      (tooltips / cue text, grid layout, date entry, virtualized list).
;;
;; See widgetkit.scrbl for the full manual and examples/ for runnable demos.

;; ---------------------------------------------------------------------------
;; Layer 1 — gap-filling widgets (this repository)
;; ---------------------------------------------------------------------------

(require "private/status-bar.rkt"
         "private/spinner.rkt"
         "private/stepper.rkt"
         "private/labeled-field.rkt"
         "private/text-list.rkt"
         "private/disclosure.rkt"
         "private/image-view.rkt"
         "private/progress-dialog.rkt"
         "private/log-view.rkt")

(provide (all-from-out "private/status-bar.rkt")
         (all-from-out "private/spinner.rkt")
         (all-from-out "private/stepper.rkt")
         (all-from-out "private/labeled-field.rkt")
         (all-from-out "private/text-list.rkt")
         (all-from-out "private/disclosure.rkt")
         (all-from-out "private/image-view.rkt")
         (all-from-out "private/progress-dialog.rkt")
         (all-from-out "private/log-view.rkt"))

;; ---------------------------------------------------------------------------
;; Layer 2 — aggregated widgets (maintained upstream, re-exported here)
;; ---------------------------------------------------------------------------

(require gui-widget-mixins     ; tooltips, cue text, validation for text-field%
         table-panel           ; grid-aligned layout panel
         canvas-list           ; fast virtualized, custom-draw list
         text-date)            ; date entry text field

(provide (all-from-out gui-widget-mixins)
         (all-from-out table-panel)
         (all-from-out canvas-list)
         (all-from-out text-date))
