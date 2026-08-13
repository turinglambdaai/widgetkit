<!-- Thanks for contributing to widgetkit! See CONTRIBUTING.md for the full guide. -->

## What does this change add or fix?

<!-- One or two sentences. If it is a new widget, which core racket/gui gap does it fill? -->

## Checklist

- [ ] It fills a real gap core `racket/gui` leaves open (not a duplicate of an existing widget)
- [ ] There is a runnable example in `examples/`
- [ ] It is documented: a row in `AGENTS.md`'s intent table, a section in `widgetkit.scrbl`, and a row in both `README.md` and `README.zh-CN.md`
- [ ] Any new API trap is added to the `AGENTS.md` Footguns list
- [ ] `bash test/check-fmt.sh` passes
- [ ] `raco test test/run.rkt` and `bash test/run-gui-behavior.sh` pass
- [ ] `bash test/smoke-examples.sh` passes (the new example launches without error)
