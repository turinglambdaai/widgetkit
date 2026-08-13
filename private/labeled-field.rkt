;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

(require racket/class
         racket/gui/base
         gui-widget-mixins)            ; cue-mixin, tooltip-mixin

(provide labeled-field%)

;; A text-field% that already has cue (placeholder) and tooltip support mixed
;; in, exposed through the consistent init fields `[cue ...]` and
;; `[tooltip ...]`.
;;
;; Why this exists: directly composing the upstream mixins has a footgun —
;; `cue-mixin` is `(cue-mixin default-cue-string base-class)` (two arguments),
;; not a plain `class -> class` mixin, so `(cue-mixin (tooltip-mixin
;; text-field%))` looks right but fails. `labeled-field%` bakes in the correct
;; composition and lets callers ignore the quirk.
;;
;;   (new labeled-field% [parent f] [label "Name:"]
;;        [cue "Enter your name"] [tooltip "Your full name"])
(define labeled-field%
  (cue-mixin "" (tooltip-mixin text-field%)))
