# Protocell

[![Build Status](https://travis-ci.org/martinslota/protocell.svg?branch=master)](https://travis-ci.org/martinslota/protocell)

Conjures up convenient OCaml types and serialization functions based on
[Protocol Buffer (protobuf)](https://developers.google.com/protocol-buffers)
definition files.

## Feature highlights

:camel: Full support for all `proto3` primitive and user-defined types.

:camel: Supports imports and generates one `.ml` file per `.proto` file.

:camel: Automagically supplies code for imports of Google's "well-known
types" when needed.

:camel: Concise yet comprehensive test framework that cross-checks
serializations with those of `protoc` itself.

:camel: Fully bootstrapped: Protocell uses Protocell-generated code to
interact with `protoc`.

:camel: Lean on dependencies, especially when it comes to the runtime
library.

:camel: Supports OCaml compiler versions 4.04.1 and above.

:camel: Decent `proto2` support.

:camel: Supports `protoc`'s text format (mostly for testing and debugging
purposes).

## How does it work?

Protocell is a [`protoc` compiler
plugin](https://developers.google.com/protocol-buffers/docs/reference/other).
It relies on `protoc` for parsing of `.proto` files. Based on the resulting
[descriptors](https://github.com/protocolbuffers/protobuf/blob/master/src/google/protobuf/compiler/plugin.proto)
it generates a flat set of composable `.ml` files with the corresponding
OCaml code.

## Show me the codez!

Consider the following Prototocol Buffer definition file:

<details>
  <summary>
    <a href="example/type_zoo/type_zoo.proto">type_zoo.proto</a>
  </summary>
  
```protobuf
syntax = "proto3";

enum Platypus {
  SITTING = 0;
  STANDING = 1;
  LYING = 2;
  OTHER = 3;
}

message Exposition {
  int32 alpaca = 1;
  int64 bear = 2;
  sint32 cuckoo = 3;
  sint64 dolphin = 4;
  uint32 elephant = 5;
  uint64 fox = 6;
  fixed32 giraffe = 7;
  repeated fixed64 hest = 8;
  sfixed32 indri = 9;
  sfixed64 jellyfish = 10;
  float kingfisher = 11;
  double llama = 12;
  bool meerkat = 13;
  string nightingale = 14;
  bytes octopus = 15;
  Platypus platypus = 16;
  oneof cute {
    string quetzal = 17;
    string redPanda = 18;
  }
  repeated Exposition subPavilions = 19;
}
```
</details>

Here are the OCaml signatures that get generated from it:

<details>
  <summary>
    Generated OCaml signatures (see <a
    href="example/type_zoo/type_zoo.ml">type_zoo.ml</a> for how these can be
    used)
  </summary>
  
```ocaml
module Platypus : sig
  type t =
    | Sitting
    | Standing
    | Lying
    | Other
  [@@deriving eq, show]

  val default : unit -> t

  val to_int : t -> int

  val of_int : int -> t option

  val to_string : t -> string

  val of_string : string -> t option
end

module rec Exposition : sig
  module Cute : sig
    type t =
      | Quetzal of string
      | Red_panda of string
    [@@deriving eq, show]

    val quetzal : string -> t
    val red_panda : string -> t
  end

  type t = {
    alpaca : int;
    bear : int;
    cuckoo : int;
    dolphin : int;
    elephant : int;
    fox : int;
    giraffe : int;
    hest : int list;
    indri : int;
    jellyfish : int;
    kingfisher : float;
    llama : float;
    meerkat : bool;
    nightingale : string;
    octopus : string;
    platypus : Platypus.t;
    cute : Cute.t option;
    sub_pavilions : Exposition.t list;
  }
  [@@deriving eq, show]

  val to_binary : t -> (string, [> Bin'.serialization_error]) result

  val of_binary : string -> (t, [> Bin'.deserialization_error]) result

  val to_text : t -> (string, [> Text'.serialization_error]) result

  val of_text : string -> (t, [> Text'.deserialization_error]) result
end
```
</details>

More generally speaking, primitive and user-defined Protocol Buffer types are
mapped to OCaml types as follows:

| Protobuf type(s) | OCaml type |
| --- | --- |
| `bool` | `bool` |
| All integer types | `int` |
| `float` and `double` | `float` |
| `string` and `bytes` | `string` |
| Message | Unit or record type `t` in a separate recursive module |
| Enum | ADT `t` in a separate module |
| Oneof message field | ADT `t` in a separate module |

Each module surrounding a generated message type also contains
serialization/deserialization functions of the following form:

```ocaml
val to_binary : t -> (string, [> Bin'.serialization_error]) result

val of_binary : string -> (t, [> Bin'.deserialization_error]) result

val to_text : t -> (string, [> Text'.serialization_error]) result

val of_text : string -> (t, [> Text'.deserialization_error]) result
```

Here, `Bin'` and `Text'` point to the runtime modules responsible for
producing the Protocol Buffer binary encoding and the JSON-like text encoding
of `protoc`, respectively.

## Usage

Protocell is available on OPAM, so you just need to

```sh
opam install protocell
```

The [example](example) folder shows how Protocell can be used in a number
of scenarios. Thanks to `dune`'s composability, it is straightforward to copy
any of these and adapt it to a real use-case.

1. [simple](example/simple): How to serialize and deserialize a simplistic
message consisting of a single `string` field.

1. [type_zoo](example/type_zoo): Similar to the above but for a recursively
defined message that uses a variety of Protocol Buffer types including an
enum and a oneof. The `WITH_DERIVERS` environment variable is used here to
add a custom list of derivers to the generated types.

1. [import](example/import): Exemplifies how imports are handled by Protocell.

1. [auto_import](example/auto_import): Similar to the above but takes
advantage of Protocell's ability to auto-supply Google's "well-known types"
(i.e. all the `.proto` files [under this
folder](https://github.com/protocolbuffers/protobuf/tree/master/src/google/protobuf)).
Currently, there's one caveat here: The resulting code won't compile if the
`WITH_DERIVERS` environment variable contains a deriver that is neither `eq`
nor `show`.

## Alternatives

* [ocaml-protoc-plugin](https://github.com/issuu/ocaml-protoc-plugin)
  * Shares space-time coordinates of origin as well as a number of ideas with
    Protocell.
  * A more detailed comparison may come later.
* [ocaml-protoc](https://github.com/mransan/ocaml-protoc)
  * A battle-tested Protobuf compiler written in pure OCaml.
  * The generated types for each `.proto` file end up in a single module which
    may make their usage more cumbersome.
  * Pulls in a heavier set of dependencies, occasionally causing headaches when
    upgrading to a newer compiler.
  * Does not generate code for empty messages.
  * The last released version cannot process `.proto` files with `service` blocks.
* [ocaml-pb-plugin](https://github.com/yallop/ocaml-pb-plugin)
  * Appears to not have full support for `proto3` types, specifically for
    `oneof` fields.
  * A deeper comparison may come later.

## Contributing

Contributions of a wide variety of shapes and sizes are very welcome.

For larger issues, please open an issue in the [issue
tracker](https://github.com/martinslota/protocell/issues) so we can discuss
it before writing code. In case of minor issues and annoyances, feel free to
make the change you want to see and send a pull request.

## Acknowledgement

This project stands on the shoulders of many giants. Thank you, all!
