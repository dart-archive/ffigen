[![Build Status](https://travis-ci.org/dart-lang/ffigen.svg?branch=master)](https://travis-ci.org/dart-lang/ffigen)

Experimental generator for [FFI](https://dart.dev/guides/libraries/c-interop)
bindings.

> Work in progress...

## Using this package - 
- clone/download this repository
- Build it (see [building](#building))
- Add this package as dev_dependency in your pubspec.yaml
- Configurations must be provided in the pubspec.yaml file under the key `ffigen` (or directly under a seperate yaml file which when u specify it passing `--config filename` when running the tool)
- Run the tool- `pub run ffigen:generate`

## Building -
A dynamic library for a wrapper to libclang needs to be generated as it is used by the parser submodule.

#### ubuntu/linux-
1. Install libclangdev - `sudo apt-get install libclang-dev`
2. cd to tool/wrapped_libclang, then run the `build_dylib_linux.sh` script

#### Windows
1. Install Visual Studio with C++ development support
2. Install LLVM
3. cd to tool/wrapped_libclang, then run the `build_dylib_windows.sh` script

## Project Structure -

- `lib` - Contains all source code
- `bin` - Contains generate.dart script which end user will execute
- `tool` - Contains script to generate LibClang bindings using Code_Generator submodule (dev use only).
- `example` - Project to demonstrate generation of bindings for given C header files.

- `lib/src/code_generator` - Generates Binding Files
- `lib/src/config_provider` - Holds configurations to be passed to other modules
- `lib/src/header_parser` - Parses header files, utilises clang_bindings

