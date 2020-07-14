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
- clone/download this repository.
- Build it (see [building](#building)).
- Add this package as dev_dependency in your `pubspec.yaml`.
- Configurations must be provided in `pubspec.yaml` or in a custom `yaml` file (see [configurations](#configurations)).
- Run the tool- `pub run ffigen`.

## Building
A dynamic library for a wrapper to libclang needs to be generated as it is used by the parser submodule.

#### ubuntu/linux
1. Install libclangdev - `sudo apt-get install libclang-dev`.
2. `cd tool/wrapped_libclang`, then run `dart build.dart`.

#### Windows
1. Install Visual Studio with C++ development support.
2. Install LLVM.
3. `cd tool\wrapped_libclang`, then run `dart build.dart`.

#### MacOS
1. Install LLVM.
2. `cd tool/wrapped_libclang`, then run `dart build.dart`.

## Configurations
Configurations can be provided in 2 ways-
1. In your project's `pubspec.yaml` file under the key `ffigen`.
2. Via a custom yaml file. You can then specify this file while running -
`pub run ffigen --config config.yaml`

The following configuration options are available-
<table>
<thead>
  <tr>
    <th>Key</th>
    <th>Required</th>
    <th>Explaination</th>
    <th>Example</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>output</td>
    <td>yes</td>
    <td>Output path of the generated bindings.</td>
    <td><pre lang='yaml'>output: 'generated_bindings.dart'</pre></td>
  </tr>
  <tr>
    <td>headers</td>
    <td>yes</td>
    <td>List of C headers to use. Glob syntax is allowed.</td>
    <td><pre lang="yaml">
headers:
  - 'folder/**.h'
  - 'folder/specific_header.h'</pre></td>
  </tr>
  <tr>
    <td>header-filter</td>
    <td>no</td>
    <td>Name of headers to include/exclude.</td>
    <td><pre lang="yaml">
header-filter:
  include:
    - 'index.h'
    - 'platform.h'</pre></td>
  </tr>
  <tr>
    <td>name</td>
    <td>prefer</td>
    <td>Name of generated class.</td>
    <td><pre lang='yaml'>name: 'SQLite'</pre></td>
  </tr>
  <tr>
    <td>description</td>
    <td>prefer</td>
    <td>Dart Doc for generated class.</td>
    <td><pre lang='yaml'>description: 'Bindings to SQLite'</pre></td>
  </tr>
  <tr>
    <td>compiler-opts</td>
    <td>no</td>
    <td>Pass compiler options to clang.</td>
    <td><pre lang='yaml'>compiler-opts: '-I/usr/lib/llvm-9/include/'</pre></td>
  </tr>
  <tr>
    <td>functions<br>structs<br>enums</td>
    <td>no</td>
    <td>Filters for declarations.<br><b>Default: all are included</b></td>
    <td><pre lang='yaml'>
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
    '_': 'C'</pre></td>
  </tr>
  <tr>
    <td>array-workaround</td>
    <td>no</td>
    <td>Should generate workaround for fixed arrays in Structs.
      <b>Default: false</b>
    </td>
    <td><pre lang='yaml'>array-workaround: true</pre></td>
  </tr>
  <tr>
    <td>comments</td>
    <td>no</td>
    <td>Extract documentation comments for declarations.<br>
      <i>Options: brief / full / none</i><br>
      <b>Default: brief</b><br>
      By default clang only parses documentation comments. If you need
      ordinary comments (starting with // or /*) then add<br>
      <i>-fparse-all-comments</i> to <i>compiler-opts</i>.
    </td>
    <td><pre lang='yaml'>comments: 'full'</pre></td>
  </tr>
  <tr>
    <td>libclang-dylib-folder</td>
    <td>no</td>
    <td>Path to the folder containing dynamic library for libclang wrapper.<br>
      <b>Default: tool/wrapped_libclang</b>
    </td>
    <td><pre lang='yaml'>libclang-dylib-folder: 'tool/wrapped_libclang'</pre></td>
  </tr>
  <tr>
    <td>sort</td>
    <td>no</td>
    <td>Sort the bindings according to name.<br>
      <b>Default: false</b>
    </td>
    <td><pre lang='yaml'>sort: true</pre></td>
  </tr>
  <tr>
    <td>use-supported-typedefs</td>
    <td>no</td>
    <td>Should automatically map typedefs, E.g uint8_t => Uint8, int16_t => Int16 etc.<br>
    <b>Default: true</b>
    </td>
    <td><pre lang='yaml'>use-supported-typedefs: true</pre></td>
  </tr>
   <tr>
    <td>preamble</td>
    <td>no</td>
    <td>Raw header of the file, pasted as-it-is.</td>
    <td><pre lang='yaml'>
preamble: |
  /// AUTO GENERATED FILE, DO NOT EDIT.
  ///
  /// Generated by `package:ffigen`.</pre></td>
  </tr>
  <tr>
    <td>sizemap</td>
    <td>no</td>
    <td>Size of integers to use.<br>
    <b>Do not change these unless you are sure.</b>
    </td>
    <td><pre lang='yaml'>
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

## Trying out examples
1. `cd examples/<example_u_want_to_run>`, Run `pub get`.
2. Run `pub run ffigen`.

## Running Tests
Dynamic library for some tests need to be built before running the examples.
1. `cd test/native_test`.
2. Run `dart build_test_dylib.dart`.

Run tests from the root of the package with `pub run test`.
