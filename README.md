[![Build Status](https://travis-ci.org/dart-lang/ffigen.svg?branch=master)](https://travis-ci.org/dart-lang/ffigen)

Experimental generator for [FFI](https://dart.dev/guides/libraries/c-interop)
bindings.

## Using this package - 
- clone/download this repository.
- Build it (see [building](#building)).
- Add this package as dev_dependency in your `pubspec.yaml`.
- Configurations must be provided in the pubspec.yaml file under the key `ffigen` (or directly under a seperate yaml file which when u specify it passing `--config filename` when running the tool)
- Run the tool- `pub run ffigen:generate`.

## Building -
A dynamic library for a wrapper to libclang needs to be generated as it is used by the parser submodule.

#### ubuntu/linux-
1. Install libclangdev - `sudo apt-get install libclang-dev`.
2. cd to tool/wrapped_libclang, then run the `build_dylib_linux.sh` script.

#### Windows
1. Install Visual Studio with C++ development support.
2. Install LLVM.
3. cd to tool/wrapped_libclang, then run the `build_dylib_windows.bat` script.

## Trying out examples
1. `cd` to examples/<example_u_want_to_run>, Run `pub get`.
2. Run `pub run ffigen:generate`.

## Running Tests
Dynamic library for some tests need to be built before running the examples.
1. `cd test/native_functions_test`.
2. Run `./build_test_dylib_linux.sh` on linux, or `.\build_test_dylib_windows.bat` for windows.

Run tests from the root of the package with `pub run test`.

## Project Structure -

- `bin` - Contains generate.dart script which end user will execute.
- `tool` - Contains script to generate LibClang bindings using Code_Generator submodule (dev use only).
- `example` - Example projects which demonstrate generation of bindings for given C header files.

## Overview
1. The User provides the location all the header files (as a list of globs or filepaths),
For each header file, we create a translation unit and parse the `declarations` in it
to the bindings.
2. User can provide `header filters` to select which declaration from a particular header file should be added to the generated bindings. The can provide a list of header 'names' to include/exclude.
We compare the header file name (not the exact path) to decide.
The default behaviour is to include everything that's included when parsing a header.
3. Use can provide Compiler options, which are passed to clang compiler as it is.
4. All bindings are generated in a single file.
