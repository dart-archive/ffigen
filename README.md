[![pub package](https://img.shields.io/pub/v/ffigen.svg)](https://pub.dev/packages/ffigen)
[![Build Status](https://travis-ci.org/dart-lang/ffigen.svg?branch=master)](https://travis-ci.org/dart-lang/ffigen)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/ffigen/badge.svg?branch=master)](https://coveralls.io/github/dart-lang/ffigen?branch=master)

Experimental binding generator for [FFI](https://dart.dev/guides/libraries/c-interop)
bindings.

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
  final DynamicLibrary _dylib;

  NativeLibrary(DynamicLibrary dynamicLibrary) : _dylib = dynamicLibrary;

  int sum(int a, int b) {
    _sum ??= _dylib.lookupFunction<_c_sum, _dart_sum>('sum');
    return _sum(a, b);
  }
  _dart_sum _sum;;
}
typedef _c_sum = ffi.Int32 Function(Int32 a, Int32 b);
typedef _dart_sum = int Function(int a,int b);
```
## Using this package
- Add this package as dev_dependency in your `pubspec.yaml`.
- Setup for use (see [Setup](#Setup)).
- Configurations must be provided in `pubspec.yaml` or in a custom YAML file (see [configurations](#configurations)).
- Run the tool- `pub run ffigen`.

Jump to [FAQ](#faq).

## Setup
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
`pub run ffigen --config config.yaml`

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
    <td>output<br><i>(Required)</i></td>
    <td>Output path of the generated bindings.</td>
    <td><pre lang="yaml">output: 'generated_bindings.dart'</pre></td>
  </tr>
  <tr>
    <td>headers<br><i>(Required)</i></td>
    <td>The header entry-points and include-directives. Glob syntax is allowed.</td>
    <td><pre lang="yaml">
headers:
  entry-points:
    - 'folder/**.h'
    - 'folder/specific_header.h'
  include-directives:
    - '**index.h'
    - '**/clang-c/**'
    - '/full/path/to/a/header.h'
  </pre></td>
  </tr>
  <tr>
    <td>name<br><i>(Prefer)</i></td>
    <td>Name of generated class.</td>
    <td><pre lang="yaml">name: 'SQLite'</pre></td>
  </tr>
  <tr>
    <td>description<br><i>(Prefer)</i></td>
    <td>Dart Doc for generated class.</td>
    <td><pre lang="yaml">description: 'Bindings to SQLite'</pre></td>
  </tr>
  <tr>
    <td>compiler-opts</td>
    <td>Pass compiler options to clang.</td>
    <td><pre lang="yaml">compiler-opts: '-I/usr/lib/llvm-9/include/'</pre></td>
  </tr>
  <tr>
    <td>functions<br>structs<br>enums<br>unnamed-enums<br>macros</td>
    <td>Filters for declarations.<br><b>Default: all are included</b></td>
    <td><pre lang="yaml">
functions:
  include: # 'exclude' is also available.
    - [a-z][a-zA-Z0-9]* # Matches using regexp.
    - prefix.* # '.' matches any character.
    - someFuncName # Matches with exact name
    - anotherName # Full names have higher priority.
  rename:
    # Regexp groups based replacement.
    'clang_(.*)': '$1'
    # full name matches have higher priority.
    'clang_dispose': 'dispose'
    # Removes '_' from beginning of a name.
    '_(.*)': '$1'
enums:
  member-rename:
    '(.*)': # Matches any enum.
      # Removes '_' from beginning enum member name.
      '_(.*)': '$1'
    'CXTypeKind': # Full names have higher priority.
      # $1 keeps only the 1st group i.e '(.*)'.
      'CXType(.*)': '$1'
    </pre></td>
  </tr>
  <tr>
    <td>array-workaround</td>
    <td>Should generate workaround for fixed arrays in Structs. See <a href="#array-workaround">Array Workaround</a><br>
      <b>Default: false</b>
    </td>
    <td><pre lang="yaml">array-workaround: true</pre></td>
  </tr>
  <tr>
    <td>comments</td>
    <td>Extract documentation comments for declarations.<br>
    The style and length of the comments can be specified with the following options.<br>
    <i>style: doxygen(default) | any </i><br>
    <i>length: brief | full(default) </i><br>
    If you want to disable all comments you can also pass<br>
    comments: false.
    </td>
    <td><pre lang="yaml">
comments:
  style: doxygen
  length: full
    </pre></td>
  </tr>
  <tr>
    <td>sort</td>
    <td>Sort the bindings according to name.<br>
      <b>Default: false</b>, i.e keep the order as in the source files.
    </td>
    <td><pre lang="yaml">sort: true</pre></td>
  </tr>
  <tr>
    <td>use-supported-typedefs</td>
    <td>Should automatically map typedefs, E.g uint8_t => Uint8, int16_t => Int16 etc.<br>
    <b>Default: true</b>
    </td>
    <td><pre lang="yaml">use-supported-typedefs: true</pre></td>
  </tr>
  <tr>
    <td>dart-bool</td>
    <td>Should generate dart `bool` for c99 bool in functions.<br>
    <b>Default: true</b>
    </td>
    <td><pre lang="yaml">dart-bool: true</pre></td>
  </tr>
   <tr>
    <td>preamble</td>
    <td>Raw header of the file, pasted as-it-is.</td>
    <td><pre lang="yaml">
preamble: |
  /// AUTO GENERATED FILE, DO NOT EDIT.
  ///
  /// Generated by `package:ffigen`.</pre></td>
  </tr>
  <tr>
    <td>size-map</td>
    <td>Size of integers to use (in bytes).<br>
    <b>The defaults (see example) <i>may</i> not be portable on all OS.
    Do not change these unless absolutely sure.</b>
    </td>
    <td><pre lang="yaml">
# These are optional and also default,
# Omitting any and the default will be used.
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
  enum: 4</pre></td>
  </tr>
</tbody>
</table>

## Array-Workaround
Fixed size array's in structs aren't currently supported by Dart. However we provide
a workaround, using which array items can now be accessed using `[]` operator.

Here's a C structure from libclang-
```c
typedef struct {
  unsigned long long data[3];
} CXFileUniqueID;
```
The generated code is -
```dart
class CXFileUniqueID extends ffi.Struct {
  @ffi.Uint64()
  int _unique_data_item_0;
  @ffi.Uint64()
  int _unique_data_item_1;
  @ffi.Uint64()
  int _unique_data_item_2;

  /// Helper for array `data`.
  ArrayHelper_CXFileUniqueID_data_level0 get data =>
      ArrayHelper_CXFileUniqueID_data_level0(this, [3], 0, 0);
}

/// Helper for array `data` in struct `CXFileUniqueID`.
class ArrayHelper_CXFileUniqueID_data_level0 {
  final CXFileUniqueID _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_CXFileUniqueID_data_level0(
      this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError(
          'Dimension $level: index not in range 0..${length} exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_data_item_0;
      case 1:
        return _struct._unique_data_item_1;
      case 2:
        return _struct._unique_data_item_2;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_data_item_0 = value;
        break;
      case 1:
        _struct._unique_data_item_1 = value;
        break;
      case 2:
        _struct._unique_data_item_2 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}
```

## Limitations
1. Multi OS support for types such as long. [Issue #7](https://github.com/dart-lang/ffigen/issues/7)
2. Function's passing/returning structs by value are skipped. [Issue #3](https://github.com/dart-lang/ffigen/issues/3)
3. Structs containing structs will have all their members removed. [Issue #4](https://github.com/dart-lang/ffigen/issues/4)

## Trying out examples
1. `cd examples/<example_u_want_to_run>`, Run `pub get`.
2. Run `pub run ffigen`.

## Running Tests
1. Run setup to build the LLVM wrapper - `pub run ffigen:setup`.
2. Dynamic library for some tests also need to be built before running the examples.
  1. `cd test/native_test`.
  2. Run `dart build_test_dylib.dart`.

Run tests from the root of the package with `pub run test`.

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
To convert these to/from `String`, you can use [package:ffi](https://pub.dev/packages/ffi) and use `Utf8.fromUtf8(ptr.cast())` to convert `char*` to dart `string`.
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

### Why are some struct declarations generated even after excluded them in config?

This happens when an excluded struct is a dependency to some included declaration.
(A dependency means a struct is being passed/returned by a function or is member of another struct in some way)
