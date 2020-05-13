[![Build Status](https://travis-ci.org/dart-lang/ffigen.svg?branch=master)](https://travis-ci.org/dart-lang/ffigen)

Experimental generator for [FFI](https://dart.dev/guides/libraries/c-interop)
bindings.

> Work in progress..

## Using this package - 
- Add as dependency (can be a dev_dependency)
- Configurations must be provided in the pubspec.yaml file under the key `ffigen`
- Run from root of project - `pub run ffigen:generate`

## Project Structure -

- `bin` - Contains generate.dart script which end user will execute
- `lib` - Contains code that will parse the C header files (LibClang bindings and AST interface)
- `tool` - Contains script to generate LibClang bindings using FFI tool (dev use only).
- `example` - Project to demostrate generatiion of bindings for given C header files.

- `lib/src/code_generator` - Generates Binding Files
- `lib/src/config_provider` - Holds configurations to be passed to other modules
- `lib/src/code_generator` - Clang Bindings, created using code_generator
- `lib/src/header_parser` - Parses header files, utilises clang_bindings

## Building -
A dynamic library for must be generated for this to work,
cd to inside this package, then use `build.sh` to generate dynamic library (libclang must be installed
and its header files should be in the include path)
