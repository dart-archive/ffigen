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
DynamicLibrary _dylib;

/// Initialises dynamic library
void init(DynamicLibrary dylib) {
  _dylib = dylib;
}

int sum(int a,int b) {
  return _sum(a,b);
}

final _dart_sum _sum = _dylib.lookupFunction<_c_sum, _dart_sum>('sum');

typedef _c_sum = Int32 Function(Int32 a,Int32 b);

typedef _dart_sum = int Function(int a,int b);
```
## Using this package
- clone/download this repository.
- Build it (see [building](#building)).
- Add this package as dev_dependency in your `pubspec.yaml`.
- Configurations must be provided in the pubspec.yaml file under the key `ffigen` (or directly under a seperate yaml file which when u specify it passing `--config filename` when running the tool)
- Run the tool- `pub run ffigen:generate`.

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

## Trying out examples
1. `cd examples/<example_u_want_to_run>`, Run `pub get`.
2. Run `pub run ffigen:generate`.

## Running Tests
Dynamic library for some tests need to be built before running the examples.
1. `cd test/native_functions_test`.
2. Run `dart build_test_dylib.dart`.

Run tests from the root of the package with `pub run test`.
