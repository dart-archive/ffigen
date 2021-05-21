[![pub package](https://img.shields.io/pub/v/ffigen.svg)](https://pub.dev/packages/ffigen)
[![Build Status](https://github.com/dart-lang/ffigen/workflows/Dart%20CI/badge.svg)](https://github.com/dart-lang/ffigen/actions?query=workflow%3A"Dart+CI")
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/ffigen/badge.svg?branch=master)](https://coveralls.io/github/dart-lang/ffigen?branch=master)

Binding generator for [FFI](https://dart.dev/guides/libraries/c-interop) bindings.

> Note: ffigen only supports parsing `C` headers.

## Example

For some header file _example.h_:
```C
int sum(int a, int b);
```
Add configurations to Pubspec File:
```yaml
ffigen:
  output: 'generated_bindings.dart'
  headers:
    entry-points:
      - 'example.h'
```
Output (_generated_bindings.dart_).
```dart
class NativeLibrary {
  final Pointer<T> Function<T extends NativeType>(String symbolName)
      _lookup;
  NativeLibrary(DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;
  NativeLibrary.fromLookup(
      Pointer<T> Function<T extends NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int sum(int a, int b) {
    return _sum(a, b);
  }

  late final _sum_ptr = _lookup<NativeFunction<_c_sum>>('sum');
  late final _dart_sum _sum = _sum_ptr.asFunction<_dart_sum>();
}
typedef _c_sum = Int32 Function(Int32 a, Int32 b);
typedef _dart_sum = int Function(int a, int b);
```
## Using this package
- Add `ffigen` under `dev_dependencies` in your `pubspec.yaml`.
- Install LLVM (see [Installing LLVM](#installing-llvm)).
- Configurations must be provided in `pubspec.yaml` or in a custom YAML file (see [configurations](#configurations)).
- Run the tool- `dart run ffigen`.

Jump to [FAQ](#faq).

## Installing LLVM
`package:ffigen` uses LLVM. Install LLVM (9+) in the following way.

#### ubuntu/linux
1. Install libclangdev - `sudo apt-get install libclang-dev`.

#### Windows
1. Install Visual Studio with C++ development support.
2. Install [LLVM](https://releases.llvm.org/download.html) or `winget install -e --id LLVM.LLVM`.

#### MacOS
1. Install Xcode.
2. Install LLVM - `brew install llvm`.

## Configurations
Configurations can be provided in 2 ways-
1. In the project's `pubspec.yaml` file under the key `ffigen`.
2. Via a custom YAML file, then specify this file while running -
`dart run ffigen --config config.yaml`

The following configuration options are available-
<table>
<thead>
  <tr>
    <th>Key</th>
    <th>Explaination</th>
    <th>Example</th>
  </tr>
  <colgroup>
      <col>
      <col style="width: 100px;">
  </colgroup>
</thead>
<tbody>
  <tr>
    <td>output<br><i><b>(Required)</b></i></td>
    <td>Output path of the generated bindings.</td>
    <td>

```yaml
output: 'generated_bindings.dart'
```
  </td>
  </tr>
  <tr>
    <td>llvm-path</td>
    <td>Path to <i>llvm</i> folder.<br> ffigen will sequentially search
    for `lib/libclang.so` on linux, `lib/libclang.dylib` on macOs and
    `bin\libclang.dll` on windows, in the specified paths.<br><br>
    Complete path to the dynamic library can also be supplied.<br>
    <i>Required</i> if ffigen is unable to find this at default locations.</td>
    <td>

```yaml
llvm-path:
  - '/usr/local/opt/llvm'
  - 'C:\Program Files\llvm`
  - '/usr/lib/llvm-11'
  # Specify exact path to dylib
  - '/usr/lib64/libclang.so'
```
  </td>
  </tr>
  <tr>
    <td>headers<br><i><b>(Required)</b></i></td>
    <td>The header entry-points and include-directives. Glob syntax is allowed.<br>
    If include-directives are not specified ffigen will generate everything directly/transitively under the entry-points.</td>
    <td>

```yaml
headers:
  entry-points:
    - 'folder/**.h'
    - 'folder/specific_header.h'
  include-directives:
    - '**index.h'
    - '**/clang-c/**'
    - '/full/path/to/a/header.h'
```
  </td>
  </tr>
  <tr>
    <td>name<br><i>(Prefer)</i></td>
    <td>Name of generated class.</td>
    <td>

```yaml
name: 'SQLite'
```
  </td>
  </tr>
  <tr>
    <td>description<br><i>(Prefer)</i></td>
    <td>Dart Doc for generated class.</td>
    <td>

```yaml
description: 'Bindings to SQLite'
```
  </td>
  </tr>
  <tr>
    <td>compiler-opts</td>
    <td>Pass compiler options to clang. You can also pass
    these via the command line tool.</td>
    <td>

```yaml
compiler-opts:
  - '-I/usr/lib/llvm-9/include/'
```
and/or via the command line -
```bash
dart run ffigen --compiler-opts "-I/headers
-L 'path/to/folder name/file'"
```
  </td>
  </tr>
    <tr>
    <td>compiler-opts-automatic -> macos -> include-c-standard-library</td>
    <td>Tries to automatically find and add C standard library path to
    compiler-opts on macos.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
compiler-opts-automatic:
  macos:
    include-c-standard-library: false
```
  </td>
  </tr>
  <tr>
    <td>functions<br><br>structs<br><br>unions<br><br>enums<br><br>unnamed-enums<br><br>macros<br><br>globals</td>
    <td>Filters for declarations.<br><b>Default: all are included.</b><br><br>
    Options -<br>
    - Include/Exclude declarations.<br>
    - Rename declarations.<br>
    - Rename enum and struct members.<br>
    - Expose symbol-address and typedef for functions and globals.<br>
    </td>
    <td>

```yaml
functions:
  include: # 'exclude' is also available.
    # Matches using regexp.
    - [a-z][a-zA-Z0-9]*
    # '.' matches any character.
    - prefix.*
    # Matches with exact name
    - someFuncName
    # Full names have higher priority.
    - anotherName
  rename:
    # Regexp groups based replacement.
    'clang_(.*)': '$1'
    'clang_dispose': 'dispose'
    # Removes '_' from beginning.
    '_(.*)': '$1'
  symbol-address:
    # Used to expose symbol and typedef.
    include:
      - myFunc
enums:
  member-rename:
    '(.*)': # Matches any enum.
      # Removes '_' from beginning
      # enum member name.
      '_(.*)': '$1'
    # Full names have higher priority.
    'CXTypeKind':
      # $1 keeps only the 1st
      # group i.e only '(.*)'.
      'CXType(.*)': '$1'
globals:
  exclude:
    - aGlobal
  rename:
    # Removes '_' from
    # beginning of a name.
    '_(.*)': '$1'
```
  </td>
  </tr>
  <tr>
    <td>structs -> pack</td>
    <td>Override the @Packed(X) annotation for generated structs.<br><br>
    <i>Options - none, 1, 2, 4, 8, 16</i><br>
    You can use RegExp to match with the <b>generated</b> names.<br><br>
    Note: Ffigen can only reliably identify packing specified using
    __attribute__((__packed__)). However, structs packed using
    `#pragma pack(...)` or any other way could <i>potentially</i> be incorrect
    in which case you can override the generated annotations.
    </td>
    <td>

```yaml
structs:
  pack:
    # Matches with the generated name.
    'NoPackStruct': none # No packing
    '.*': 1 # Pack all structs with value 1
```
  </td>
  </tr>
  <tr>
    <td>comments</td>
    <td>Extract documentation comments for declarations.<br>
    The style and length of the comments recognized can be specified with the following options- <br>
    <i>style: doxygen(default) | any </i><br>
    <i>length: brief | full(default) </i><br>
    If you want to disable all comments you can also pass<br>
    comments: false.
    </td>
    <td>

```yaml
comments:
  style: any
  length: full
```
  </td>
  </tr>
  <tr>
    <td>structs -> dependency-only<br><br>
        unions -> dependency-only
    </td>
    <td>If `opaque`, generates empty `Opaque` structs/unions if they
were not included in config (but were added since they are a dependency) and
only passed by reference(pointer).<br>
    <i>Options - full(default) | opaque</i><br>
    </td>
    <td>

```yaml
structs:
  dependency-only: opaque
unions:
  dependency-only: opaque
```
  </td>
  </tr>
  <tr>
    <td>sort</td>
    <td>Sort the bindings according to name.<br>
      <b>Default: false</b>, i.e keep the order as in the source files.
    </td>
    <td>

```yaml
sort: true
```
  </td>
  </tr>
  <tr>
    <td>use-supported-typedefs</td>
    <td>Should automatically map typedefs, E.g uint8_t => Uint8, int16_t => Int16 etc.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
use-supported-typedefs: true
```
  </td>
  </tr>
  <tr>
    <td>dart-bool</td>
    <td>Should generate dart `bool` instead of Uint8 for c99 bool in functions.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
dart-bool: true
```
  </td>
  </tr>
  <tr>
    <td>use-dart-handle</td>
    <td>Should map `Dart_Handle` to `Handle`.<br>
    <b>Default: true</b>
    </td>
    <td>

```yaml
use-dart-handle: true
```
  </td>
  </tr>
  <tr>
    <td>preamble</td>
    <td>Raw header of the file, pasted as-it-is.</td>
    <td>

```yaml
preamble: |
  /// AUTO GENERATED FILE, DO NOT EDIT.
  ///
  /// Generated by `package:ffigen`.
```
</td>
  </tr>
  <tr>
    <td>typedef-map</td>
    <td>Map typedefs to Native Types.<br> Values can only be
    <i>Void, Uint8, Int8, Uint16, Int16, Uint32, Int32, Uint64, Int64, IntPtr, Float and Double.</i>
    </td>
    <td>

```yaml
typedef-map:
  'my_custom_type': 'IntPtr'
  'size_t': 'Int64'
```
  </td>
  </tr>
  <tr>
    <td>size-map</td>
    <td>Size of integers to use (in bytes).<br>
    <b>The defaults (see example) <i>may</i> not be portable on all OS.
    Do not change these unless absolutely sure.</b>
    </td>
    <td>

```yaml
# These are optional and also default,
# Omitting any and the default
# will be used.
size-map:
  char: 1
  unsigned char: 1
  short: 2
  unsigned short: 2
  int: 4
  unsigned int: 4
  long: 8
  unsigned long: 8
  long long: 8
  unsigned long long: 8
  enum: 4
```
  </td>
  </tr>
</tbody>
</table>

## Limitations
1. Multi OS support for types such as long. [Issue #7](https://github.com/dart-lang/ffigen/issues/7)

## Trying out examples
1. `cd examples/<example_u_want_to_run>`, Run `dart pub get`.
2. Run `dart run ffigen`.

## Running Tests
1. Dynamic library for some tests need to be built before running the examples.
  1. `cd test/native_test`.
  2. Run `dart build_test_dylib.dart`.

Run tests from the root of the package with `dart run test`.
> Note: If llvm is not installed in one of the default locations, tests may fail.
## FAQ
### Can ffigen be used for removing underscores or renaming declarations?
Ffigen supports **regexp based renaming**, the regexp must be a
full match, for renaming you can use regexp groups (`$1` means group 1).

E.g - For renaming `clang_dispose_string` to `string_dispose`.
We can can match it using `clang_(.*)_(.*)` and rename with `$2_$1`.

Here's an example of how to remove prefix underscores from any struct and its members.
```yaml
structs:
  ...
  rename:
    '_(.*)': '$1' # Removes prefix underscores from all structures.
  member-rename:
    '.*': # Matches any struct.
      '_(.*)': '$1' # Removes prefix underscores from members.
```
### How to generate declarations only from particular headers?
The default behaviour is to include everything directly/transitively under
each of the `entry-points` specified.

If you only want to have declarations directly particular header you can do so
using `include-directives`. You can use **glob matching** to match header paths.
```yaml
headers:
  entry-points:
    - 'path/to/my_header.h'
  include-directives:
    - '**my_header.h' # This glob pattern matches the header path.
```
### Can ffigen filter declarations by name?
Ffigen supports including/excluding declarations using full regexp matching.

Here's an example to filter functions using names
```yaml
functions:
  include:
    - 'clang.*' # Include all functions starting with clang.
  exclude:
    - '.*dispose': # Exclude all functions ending with dispose.
```
This will include `clang_help`. But will exclude `clang_dispose`.

Note: exclude overrides include.
### How does ffigen handle C Strings?

Ffigen treats `char*` just as any other pointer,(`Pointer<Int8>`).
To convert these to/from `String`, you can use [package:ffi](https://pub.dev/packages/ffi). Use `ptr.cast<Utf8>().toDartString()` to convert `char*` to dart `string` and `"str".toNativeUtf8()` to convert `string` to `char*`.
### How does ffigen handle C99 bool data type?

Although `dart:ffi` doesn't have a NativeType for `bool`, they can be implemented as `Uint8`.
Ffigen generates dart `bool` for function parameters and return type by default.
To disable this, and use `int` instead, set `dart-bool: false` in configurations.

### How are unnamed enums handled?

Unnamed enums are handled separately, under the key `unnamed-enums`, and are generated as top level constants.

Here's an example that shows how to include/exclude/rename unnamed enums
```yaml
unnamed-enums:
  include:
    - 'CX_.*'
  exclude:
    - '.*Flag'
  rename:
    'CXType_(.*)': '$1'
```

### Why are some struct/union declarations generated even after excluded them in config?

This happens when an excluded struct/union is a dependency to some included declaration.
(A dependency means a struct is being passed/returned by a function or is member of another struct in some way)

Note: If you supply `structs` -> `dependency-only` as `opaque` ffigen will generate
these struct dependencies as `Opaque` if they were only passed by reference(pointer).
```yaml
structs:
  dependency-only: opaque
unions:
  dependency-only: opaque
```

### How to expose the native pointers and typedefs?

By default all native pointers and typedefs are hidden, but you can use the
`symbol-address` subkey for functions/globals and make them public by matching with its name. The pointers are then accesible via `nativeLibrary.addresses` and the native
typedef are prefixed with `Native_`.

Example -
```yaml
functions:
  symbol-address:
    include:
      - 'myFunc'
      - '.*' # Do this to expose all pointers.
```
