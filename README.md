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
3. cd to tool/wrapped_libclang, then run the `build_dylib_windows.bat` script

## Project Structure -

- `lib` - Contains all source code
- `bin` - Contains generate.dart script which end user will execute
- `tool` - Contains script to generate LibClang bindings using Code_Generator submodule (dev use only).
- `example` - Project to demonstrate generation of bindings for given C header files.

- `lib/src/code_generator` - Generates Binding Files
- `lib/src/config_provider` - Holds configurations to be passed to other modules
- `lib/src/header_parser` - Parses header files, utilises clang_bindings

# Code Details
## Modules
We are using libclang to parse header files.
The project is roughly divided in 3 major modules -
### code_generator
Converts a library(all bindings) to an actual string representation
- Library (output of the header parser)
- Writer (provides configurations for generating bindings)
- Binding (base class for all bindings - Func, Struc, Global, EnumClass, etc)
### config_provider
This takes care of validating user config files, printing config warnings and errors,
converting config.yaml to a format the header_parser can use.
- Spec (represents a single config, which a user can provide in the config file)
- Config (holds all the config which will be required by header parser)
### header_parser
Uses libclang to convert the header to a Library which is then used by code_generator.
- clang_bindings (bindings to libclang which are used for parsing)
- sub_parsers (each sub-parser parses a particular kind of declaration - struct, function, typedef, enum)
- type_extractor (extracts types from variables, function parameters, return types)
- includer (tells what should/shouldn't be included depending of config)
- parser (Main Entrypoint) (creates translation units for all header files, and sets up parsing them)
- translation_unit_parser (parses header files, splits declarations and feeds them to their respective sub_parsers)

## Overview
1. The User provides the location all the header files (as a list of globs or filepaths),
For each header file, we create a translation unit and parse the `declarations` in it
to the bindings.
2. User can provide `header filters` to select which declaration from a particular header file should be added to the generated bindings. The can provide a list of header 'names' to include/exclude.
We compare the header file name (not the exact path) to decide.
The default behaviour is to include everything that's included when parsing a header.
3. Use can provide Compiler options, which are passed to clang compiler as it is.
4. All bindings are generated in a single file.
