## Divergent.rb CHANGELOG


### v0.4.0 ###

- bugfix: `Try#recover` and `Try#recover_with should recover superclass`.

### v0.3.0 - 08-11-2016

change: `Try#recover_with` now can recover specific error cases.
enhancement: implement `Try::transform` use `Try::fmap`

### v0.2.0 - 08-04-2016

change: `recover/recover_with`: error raised in block call should not be rescued.
change: `Try.unit` should receive block call


### v0.1.4 - 07-27-2016

- add feature: recover failures of the given error classes.
