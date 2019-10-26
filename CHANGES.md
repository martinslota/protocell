:broken_heart: marks a breaking change.

### Features

* Introduced an option to flexibly map 32-bit integer types to `int32` and
  64-bit integer types to `int64` instead of the default `int`.
* :broken_heart: Started *generating* code for well-known types automatically
  whenever they are imported. As a consequence, the library with
  pre-generated code for well-known types has been entirely removed. Also,
  taking advantage of automatic imports of well-known types no longer
  restricts the available Protocell options.
* Exposed `show` functions for error types.
* :broken_heart: Added more information to some error variants.
* Added examples.

### Bug fixes

* Stopped serializing default primitive values.
* Fixed error returned for invalid values of message fields of type `sfixed32`.

### Other

* :broken_heart: Split polymorphic variants for binary and text encoding errors
  so they don't conflict with one another.
* Deprecated the WITH_DERIVERS environment variable. Instead one should use the
  `-with-derivers` option. Support for the environment variable will be
  entirely removed in a subsequenct major release of Protocell.

1.0.0
=====

* Initial release
