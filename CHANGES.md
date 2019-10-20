* Introduced an option to flexibly map 32-bit integer types to `int32` and
  64-bit integer types to `int64` instead of the default `int`.
* Switched from environment variable to a parameter supplied through `protoc`
  for defining derivers for generated type.
* Made `show` functions available for error types.
* Added information to error variants.
* Split polymorphic variants for binary and text encoding errors so they don't
  conflict with one another.
* Fixed errors generated for message fields of type `sfixed32`
* Added examples.

1.0.0
=====

* Initial release
