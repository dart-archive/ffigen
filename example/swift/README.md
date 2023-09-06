# Swift example

This example shows how to use ffigen to interact with Swift libraries.

Swift APIs can be made compatible with Objective-C, using the `@objc`
annotation. Then you can use the `swiftc` tool to build a dylib for the library
using `-emit-library`, and generate an Objective-C wrapper header using
`-emit-objc-header-path filename.h`:

```shell
swiftc -c swift_api.swift                           \
    -module-name swift_module                       \
    -emit-objc-header-path third_party/swift_api.h  \
    -emit-library -o libswiftapi.dylib
```

This should generate libswiftapi.dylib and swift_api.h.
For more information about Objective-C / Swift interoperability, see the
[Apple documentation](https://developer.apple.com/documentation/swift/importing-swift-into-objective-c).

Once you have an Objective-C wrapper header, ffigen can parse it like
any other header:

```shell
dart run ffigen --config config.yaml
```

This will generate [swift_api_bindings.dart](./swift_api_bindings.dart),
using the config in the ffigen section of the pubspec.yaml.

Finally, you can run the example using this command:

```shell
dart run example.dart
```

## Config notes

Ffigen only sees the Objective-C wrapper header, swift_api.h. So you
need to set the language to objc, and set the entry-point to the header:

```yaml
language: objc
headers:
  entry-points:
    - 'third_party/swift_api.h'
```

Swift classes become Objective-C interfaces, so include them like this:

```yaml
objc-interfaces:
  include:
    - 'SwiftClass'
```

There is one extra option you need to set when wrapping a Swift library.
When `swiftc` compiles the library, it gives the Objective-C interface
a module prefix. Internally, our `SwiftClass` is actually registered
as `swift_module.SwiftClass`. So you need to tell ffigen about this prefix,
so it loads the correct class from the dylib:

```yaml
objc-interfaces:
  include:
    - 'SwiftClass'
  module:
    'SwiftClass': 'swift_module'
```

The module prefix is whatever you passed to `swiftc` in the
`-module-name` flag.
