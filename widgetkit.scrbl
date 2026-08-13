#lang scribble/manual
@(require (for-label racket/base
                     racket/class
                     racket/gui/base
                     widgetkit))

@title{widgetkit}
@author{jrtxio}

@defmodule[widgetkit]

widgetkit is a curated collection of GUI widgets for Racket. It gathers the
controls that almost every @racketmodname[racket/gui] application wants but
that the core toolkit leaves you to build yourself — tooltips and placeholder
text, grid layout, date entry, virtualized lists, status bars, spinners and
steppers — behind a single @racket[(require widgetkit)], with one manual and a
runnable example per widget.

The design follows two rules:

@itemize[
  @item{@bold{Curated, not redundant.} Every widget fills a gap that core
    @racketmodname[racket/gui] leaves open. If the toolkit already does the
    job well, the widget is not here.}
  @item{@bold{Reuse over rewrite.} When a mature upstream package already does
    the job, widgetkit depends on it and re-exports it; it does not fork. New
    code is written only where no good solution exists.}
]

The collection has two layers:

@itemize[
  @item{@defterm{Gap-filling widgets} (new, MIT, in this repo):
    @racket[status-bar%], @racket[spinner%], @racket[stepper%] (plus the
    @racket[clamp] helper).}
  @item{@defterm{Aggregated widgets} (re-exported from mature upstream
    packages): the @racket[cue-mixin], @racket[tooltip-mixin] and
    @racket[validate-mixin] text-field enhancers, @racket[table-panel%],
    @racket[canvas-list%] and @racket[date-text-field%].}
]

Larger, heavier-dependency controls (maps, sortable data grids, plots, a web
view, a tree) are listed in @secref["companions"] — install them separately on
demand.

@section[#:tag "install"]{Installation}

From a clone of this repository:

@racketblock[
(raco pkg install)
]

Then, in any module:

@racketblock[
(require widgetkit)
]

@section{A quick tour}

Open @filepath{examples/showcase.rkt} for a single window that demonstrates
every widget, or run it directly:

@commandline{racket examples/showcase.rkt}

@section{Gap-filling widgets}

@subsection[#:tag "status-bar"]{status-bar%}

A compact bottom-of-window bar: a status message plus an optional determinate
progress gauge. Core @racket[gui] ships @racket[message%] and @racket[gauge%]
but no combined status bar, so this is boilerplate every app rewrites. It
subclasses @racket[horizontal-panel%], so extra children (e.g. a Cancel
button) can be appended.

Constructor:

@racketblock[
(new status-bar% [parent parent]
     [initial-message ""]
     [show-progress #f])
]

Methods: @racket[(send bar set-message text)],
@racket[(send bar set-progress percentage)] (0--100, ignored if the bar has no
gauge), @racket[(send bar get-message)], @racket[(send bar clear)].

@racketblock[
(define bar (new status-bar% [parent f] [show-progress #t]
                 [initial-message "Ready."]))
(send bar set-message "Working...")
(send bar set-progress 75)
]

@subsection[#:tag "spinner"]{spinner%}

An indeterminate circular activity indicator. Core @racket[gui] only ships the
determinate @racket[gauge%]; there is no ``busy, unknown duration'' control.
@racket[spinner%] draws a rotating arc on a canvas driven by a timer.

Constructor:

@racketblock[
(new spinner% [parent parent]
     [diameter 24] [color "dodgerblue"]
     [track-color "lightgray"] [interval 60])
]

Methods: @racket[(send sp start)], @racket[(send sp stop)],
@racket[(send sp spinning?)].

@racketblock[
(define sp (new spinner% [parent f] [diameter 36]))
(send sp start)   ; while work is in progress
;; ...later...
(send sp stop)
]

@subsection[#:tag "stepper"]{stepper%}

A compact @litchar{[-] value [+] } numeric stepper. Core @racket[gui] has
@racket[slider%] for picking from a range but no small +/- control for numeric
tweaks.

Constructor:

@racketblock[
(new stepper% [parent parent]
     [min-value 0] [max-value 100] [step 1] [initial 0]
     [callback (λ (self) (void))] [show-value #t])
]

Methods: @racket[(send st get-value)], @racket[(send st set-value v)],
@racket[(send st increment)], @racket[(send st decrement)]. Values are clamped
to @racket[[min-value, max-value]] using the exported @racket[clamp] helper.

@racketblock[
(new stepper% [parent f] [min-value 0] [max-value 12] [initial 1]
     [callback (λ (self) (printf "qty: ~a\n" (send self get-value)))])
]

@subsection[#:tag "disclosure"]{disclosure%}

A collapsible section: a header button toggles the visibility of a content
panel. Add the collapsible children to the panel returned by @racket[get-content].

@racketblock[
(define d (new disclosure% [parent f] [label "Advanced options"] [expanded? #f]))
(new check-box% [parent (send d get-content)] [label "Verbose logging"])
]

Methods: @racket[(send d get-content)], @racket[(send d is-expanded?)],
@racket[(send d set-expanded! bool)].

@subsection[#:tag "image-view"]{image-view%}

A canvas that displays a @racket[bitmap%], centered and scaled to fit (or at a
fixed numeric scale). core @racket[gui] has @racket[canvas%] but no ready-made
widget to just show an image.

@racketblock[
(new image-view% [parent f] [bitmap some-bitmap%] [scale 'fit])
(define iv (new image-view% [parent f]))
(send iv load-file "photo.png")
]

Methods: @racket[(send iv set-bitmap b)], @racket[(send iv load-file path)],
@racket[(send iv get-bitmap)].

@section{Aggregated widgets}

These are re-exported from their upstream packages; see each package's own
documentation for the full API.

@subsection{Tooltips & cue text}

From the @hyperlink["https://github.com/alex-hhh/gui-widget-mixins"]{gui-widget-mixins}
package (Apache-2.0 OR MIT). Core @racket[gui] has no tooltips and no
placeholder text for @racket[text-field%].

@racketblock[
(new (cue-mixin "" (tooltip-mixin text-field%))
     [parent f] [label "Name:"]
     [cue "Enter your name"]
     [tooltip "Your full name"])
]

@racket[cue-mixin] takes a default cue string and a base class;
@racket[tooltip-mixin] takes a base class. @racket[validate-mixin] adds a
validation callback. @racket[decorate-mixin] / @racket[decorate-with] compose
several enhancements.

@subsection{table-panel%}

From the @hyperlink["https://github.com/spdegabrielle/table-panel"]{table-panel}
package (LGPL-2.1). A panel that aligns its children to a grid — core
@racket[gui] has only horizontal/vertical panels.

@racketblock[
(define g (new table-panel% [parent f] [dimensions '(4 2)]))
(for ([l '("Name:" "Value:" "Unit:" "Note:")])
  (new message% [parent g] [label l])
  (new text-field% [parent g] [label #f]))
]

@subsection{canvas-list%}

From the @hyperlink["https://github.com/massung/racket-canvas-list"]{canvas-list}
package (MIT). A fast, single-selection, virtualized list that renders only the
visible rows and supports custom per-item drawing. Core @racket[list-box%]
cannot virtualize very large lists or custom-draw items.

@racketblock[
(new canvas-list%
     [parent f]
     [items (for/vector ([i (in-range 1 2000)]) (format "Item ~a" i))]
     [item-height 22]
     [action-callback (λ (canvas item event) (printf "picked ~a\n" item))])
]

@subsection{date-text-field%}

From the @hyperlink["https://github.com/Kalimehtar/text-date"]{text-date}
package (MIT). A @racket[text-field%] for entering dates (@litchar{dd.mm.yyyy}):
shows today's date as faded cue text when empty and filters input to digits and
dots. Core @racket[gui] has no date entry widget.

@racketblock[
(new date-text-field% [parent f] [label "Date:"])
]

@section{Consistency wrappers}

These wrap the aggregated widgets to hide their API footguns behind a single,
consistent class.

@subsection{labeled-field%}

A @racket[text-field%] with cue (placeholder) and tooltip already mixed in, so
you do not have to remember that @racket[cue-mixin] takes two arguments and
must be composed with @racket[tooltip-mixin].

@racketblock[
(new labeled-field% [parent f] [label "Name:"]
     [cue "Enter your name"] [tooltip "Your full name"])
]

@subsection{text-list%}

A @racket[canvas-list%] for a list of items rendered as text, with a
one-argument action callback instead of the underlying three-argument one.

@racketblock[
(new text-list% [parent f]
     [items (vector "a" "b" "c")]
     [action (λ (item) (printf "picked ~a\n" item))])
]

@section[#:tag "companions"]{Recommended companions (install separately)}

These heavier controls are deliberately @italic{not} hard dependencies, to
keep @racket[(require widgetkit)] light. Install the ones you need:

@tabular[#:style 'boxed
         #:column-properties '(left left)
         #:row-properties '(bottom-border)
         (list (list @bold{Control} @bold{Install})
               (list @elem{Interactive OSM map}
                     @racketblock[(raco pkg install map-widget)])
               (list @elem{Sortable multi-column data grid}
                     @racketblock[(raco pkg install qresults-list)])
               (list @elem{Spreadsheet editor}
                     @racketblock[(raco pkg install spreadsheet-editor)])
               (list @elem{Embed @racket[plot] snips in a window}
                     @racketblock[(raco pkg install plot-container)])
               (list @elem{Web view (Chromium / native)}
                     @racketblock[(raco pkg install racket-webview)]))]

A tree / outline view already ships with Racket as
@racketlink[mrlib/hierlist]{mrlib/hierlist} — no install needed.

@section{Roadmap}

Planned future additions (only where no mature solution exists): a collapsible
``disclosure'' section, a draggable split view, a calendar, a dedicated color
picker, a segmented control, and a small toolbar helper.

@index["gui widgets"]{}
