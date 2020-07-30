[![Build Status](https://travis-ci.org/dart-lang/ffigen.svg?branch=master)](https://travis-ci.org/dart-lang/ffigen)

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

## Setup
`package:ffigen` uses LLVM. Install LLVM in the following way.

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
</thead>
<tbody>
  <tr>
    <td>output<br><i>(Required)</i></td>
    <td>Output path of the generated bindings.</td>
    <td><pre lang="yaml"><code>output: 'generated_bindings.dart'</code></pre></td>
  </tr>
  <tr>
    <td>headers<br><i>(Required)</i></td>
    <td>The header entry-points and include-directives. Glob syntax is allowed.</td>
    <td><pre lang="yaml"><code>
headers:
  entry-points:
    - 'folder/**.h'
    - 'folder/specific_header.h'
  include-directives:
    - '**index.h'
    - '**/clang-c/**'
    - '/full/path/to/a/header.h'
  </code></pre></td>
  </tr>
  <tr>
    <td>name<br><i>(Prefer)</i></td>
    <td>Name of generated class.</td>
    <td><pre lang="yaml"><code>name: 'SQLite'</code></pre></td>
  </tr>
  <tr>
    <td>description<br><i>(Prefer)</i></td>
    <td>Dart Doc for generated class.</td>
    <td><pre lang="yaml"><code>description: 'Bindings to SQLite'</code></pre></td>
  </tr>
  <tr>
    <td>compiler-opts</td>
    <td>Pass compiler options to clang.</td>
    <td><pre lang="yaml"><code>compiler-opts: '-I/usr/lib/llvm-9/include/'</code></pre></td>
  </tr>
  <tr>
    <td>functions<br>structs<br>enums<br>macros</td>
    <td>Filters for declarations.<br><b>Default: all are included</b></td>
    <td><pre lang="yaml"><code>
functions:
  include: # Exclude is also available.
    names: # Matches with exact name.
      - someFuncName
      - anotherName
    matches: # Matches using regexp.
      - prefix.*
      - [a-z][a-zA-Z0-9]*
  prefix: 'cx_' # Prefix added to all functions.
  prefix-replacement: # Replaces a functions's prefix.
    'clang_': ''
    '_': 'C'</code></pre></td>
  </tr>
  <tr>
    <td>array-workaround</td>
    <td>Should generate workaround for fixed arrays in Structs. See <a href="#array-workaround">Array Workaround</a><br>
      <b>Default: false</b>
    </td>
    <td><pre lang="yaml"><code>array-workaround: true</code></pre></td>
  </tr>
  <tr>
    <td>comments</td>
    <td>Extract documentation comments for declarations.<br>
    The style and length of the comments can be specified with the following options.<br>
    <i>style: doxygen(default) | any </i><br>
    <i>length: brief | full(default) </i><br>
    If you want to disable all comments you can also pass<br>
    <code>comments: false</code>.
    </td>
    <td><pre lang="yaml"><code>
comments:
  style: doxygen
  length: full
    </code></pre></td>
  </tr>
  <tr>
    <td>sort</td>
    <td>Sort the bindings according to name.<br>
      <b>Default: false</b>, i.e keep the order as in the source files.
    </td>
    <td><pre lang="yaml"><code>sort: true</code></pre></td>
  </tr>
  <tr>
    <td>use-supported-typedefs</td>
    <td>Should automatically map typedefs, E.g uint8_t => Uint8, int16_t => Int16 etc.<br>
    <b>Default: true</b>
    </td>
    <td><pre lang="yaml"><code>use-supported-typedefs: true</code></pre></td>
  </tr>
  <tr>
    <td>unnamed-enums</td>
    <td>Should generate constants for anonymous unnamed enums.<br>
    <b>Default: true</b>
    </td>
    <td><pre lang="yaml"><code>unnamed-enums: true</code></pre></td>
  </tr>
   <tr>
    <td>preamble</td>
    <td>Raw header of the file, pasted as-it-is.</td>
    <td><pre lang="yaml"><code>
preamble: |
  /// AUTO GENERATED FILE, DO NOT EDIT.
  ///
  /// Generated by `package:ffigen`.</code></pre></td>
  </tr>
  <tr>
    <td>size-map</td>
    <td>Size of integers to use (in bytes).<br>
    <b>The defaults (see example) <i>may</i> not be portable on all OS.
    Do not change these unless absolutely sure.</b>
    </td>
    <td><pre lang="yaml"><code>
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
  enum: 4</code></pre></td>
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
