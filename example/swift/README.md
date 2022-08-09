# Swift example

This example shows how to use ffigen to interact with Swift libraries.

Swift APIs can be made compatible with Objective-C, using the `@objc`
annotation. Then you can use the `swiftc` tool to build a dylib for the library
using `-emit-library`, and generate an Objective-C wrapper header using
`-emit-objc-header-path filename.h`:

```shell
swiftc -c swift_api.swift -emit-library -emit-objc-header-path swift_api.h -module-name swift_module -o libswiftapi.dylib
```

This should generate libswiftapi.dylib and swift_api.h.
For more information about Objective-C / Swift interoperability, see the
[Apple documentation](https://developer.apple.com/documentation/swift/importing-swift-into-objective-c).
Once you have an Objective-C wrapper header, ffigen can parse it like
any other header:

```shell
dart run ffigen
```

This will generate [swift_api.dart](./swift_api.dart), using the config
in the ffigen section of the pubspec.yaml. Finally, you can run the
example using this command:

```shell
dart run example.dart
```

## Config notes

Ffigen only sees the Objective-C wrapper header, swift_api.h. So you still
need to set the language to objc:

```yaml
language: objc
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

The module prefix is whatever you passed to the `-module-name` flag. If
you don't set that flag, it defaults to the file name. If you aren't sure
what the module name is, you can also check the generated Objective-C header,
which will have an annotation like this above each `@interface`:

```objc
SWIFT_CLASS("_TtC12swift_module10SwiftClass")
@interface SwiftClass : NSObject
```

The string inside the `SWIFT_CLASS` macro is a bit cryptic, but you can
see it contains the module name and the class name:
"_TtC12**swift_module**10**SwiftClass**".
