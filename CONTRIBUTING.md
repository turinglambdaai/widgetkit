# Contributing to widgetkit

widgetkit aims to be a focused, high-quality collection — not a dumping ground
for every possible widget. Contributions are welcome, especially new widgets
that fill real gaps. Please read the rules below before opening a PR.

## The two rules

1. **It must fill a gap core `racket/gui` leaves open.** If the toolkit already
   does the job well, the widget does not belong here. Each widget's docs and
   README entry state the gap explicitly. When in doubt, open an issue first.
2. **Reuse over rewrite.** If a mature, license-compatible package already does
   the job, prefer declaring it a dependency and re-exporting it over writing
   new code. Write new code only where no good solution exists.

## Adding a widget — checklist

A new widget PR should include:

- [ ] The widget implementation, under `private/` if it is new code (a clean
      MIT file header), or declared as a `deps` entry in `info.rkt` if it is an
      aggregated package.
- [ ] A re-export from `main.rkt` (grouped by category, with a comment).
- [ ] **A standalone, runnable example** in `examples/` (this is required — a
      GUI library is only useful if people can see and copy a working example).
      Keep launch code (`(send f show #t)`, worker threads) in
      `(module+ main ...)`: `raco test` instantiates examples without running
      `main`, which is what the package catalog build does — top-level launch
      code times it out.
- [ ] A section in `widgetkit.scrbl` (signature + example) and a row in both
      README tables (English and Chinese), stating the gap it fills.
- [ ] Logic tests in `test/run.rkt` for any pure helpers.
- [ ] `raco make main.rkt examples/*.rkt` passes and `raco test` is green
      (including `bash test/run-examples.sh`).

## Licensing

- New code in this repository is **MIT**.
- Aggregated dependencies may be Apache-2.0/MIT, LGPL, or similar permissive /
  weak-copyleft licenses. Strongly copyleft code (GPL) must not be copied in;
  depend on it instead, and list it under "recommended companions".
- Every new source file carries an SPDX-License-Identifier line; aggregated
  packages keep their own notices.

## Development

```bash
raco pkg install --link .        # link the local checkout as a package
raco test test/run.rkt
bash test/run-examples.sh        # instantiate examples under raco test (catalog-build simulation)
raco make main.rkt examples/*.rkt
raco scribble --dest doc widgetkit.scrbl    # builds doc/widgetkit.html
```

Examples open GUI windows, so run them on a machine with a display:

```bash
racket examples/showcase.rkt
```

## Style

- `#lang racket/base` by default; require only what each file uses.
- Class-based widgets following the `racket/gui` idiom (subclass an existing
  `%` class, keep the public surface small).
- Comments in English; keep them brief and explain *why*, not *what*.
