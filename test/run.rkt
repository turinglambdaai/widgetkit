;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 jrtxio <jirentianxiang1024@gmail.com>
;; See LICENSE at the repository root for full terms.

#lang racket/base

;; Logic tests for widgetkit. These intentionally avoid instantiating GUI
;; widgets (which need a display), so the suite runs anywhere — including
;; headless CI. The widgets themselves are exercised by the runnable examples
;; under examples/.

(require rackunit
         racket/class
         widgetkit)

;; ---------------------------------------------------------------------------
;; clamp — the numeric helper behind stepper%'s clamping
;; ---------------------------------------------------------------------------

(check-equal? (clamp 5 0 10) 5   "value inside range is unchanged")
(check-equal? (clamp -1 0 10) 0  "below min clamps to min")
(check-equal? (clamp 99 0 10) 10 "above max clamps to max")
(check-equal? (clamp 7.5 0 10) 7.5 "clamp preserves inexact values")
(check-equal? (clamp 0 0 10) 0   "lower boundary")
(check-equal? (clamp 10 0 10) 10 "upper boundary")

;; ---------------------------------------------------------------------------
;; Structural — widgetkit must provide every documented widget
;; ---------------------------------------------------------------------------

(check-true (class? status-bar%)   "status-bar% exported")
(check-true (class? spinner%)      "spinner% exported")
(check-true (class? stepper%)      "stepper% exported")
(check-true (class? disclosure%)   "disclosure% exported")
(check-true (class? image-view%)   "image-view% exported")
(check-true (class? progress-dialog%) "progress-dialog% exported")
(check-true (class? log-view%)        "log-view% exported")
(check-true (class? table-panel%)  "table-panel% re-exported")
(check-true (class? canvas-list%)  "canvas-list% re-exported")
(check-true (class? date-text-field%) "date-text-field% re-exported")

(check-true (class? labeled-field%) "labeled-field% exported")
(check-true (class? text-list%)      "text-list% exported")

(check-true (procedure? cue-mixin)      "cue-mixin re-exported")
(check-true (procedure? tooltip-mixin)  "tooltip-mixin re-exported")
(check-true (procedure? validate-mixin) "validate-mixin re-exported")

(displayln "all widgetkit tests passed")
