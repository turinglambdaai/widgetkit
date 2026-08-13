#lang info

(define collection "widgetkit")
(define scribblings '(("widgetkit.scrbl" ())))
(define version "0.6.1")
(define pkg-desc "A curated collection of GUI widgets for Racket")
(define pkg-authors '("jrtxio"))
(define license 'MIT)
(define pkg-homepage "https://github.com/turinglambdaai/widgetkit")

;; Core language + the toolkit this collection builds upon.
;; The four aggregated widgets are pulled in as ordinary dependencies, so a
;; single `raco pkg install widgetkit` brings the whole set.
(define deps '("base" "gui-lib" "gui-widget-mixins" "table-panel" "canvas-list" "text-date"))

(define build-deps '("scribble-lib" "racket-doc" "gui-doc" "rackunit-lib" "fmt"))
