# **_package:ffigen_**: Internal Working
## Table of Contents -
1. [Overview](#overview)
2. [LibClang](#LibClang)
    1. [The Wrapper library](#The-Wrapper-library)
    2. [Generation and Usage](#Generation-and-Usage)
    3. [Bindings](#Bindings)
3. [Scripts](#scripts)
    1. [ffigen.dart](#ffigen.dart)
    2. [setup.dart](#setup.dart)
4. [Components](#components)
    1. [Config Provider](#Config-Provider)
    2. [Header Parser](#Header-Parser)
    3. [Code Generator](#Code-Generator)
# Overview
`package:ffigen` simplifies the process of generating `dart:ffi` bindings from C header files. It is simple to use, with the input being a small YAML config file. It requires LLVM (9+) to work. This document tries to give a complete overview of every component without going into too many details about every single class/file.
# LibClang
`package:ffigen` binds to LibClang using `dart:ffi` for parsing C header files. A wrapper library must be generated to use it, as `dart:ffi` currently [doesn't support structs by value](https://github.com/dart-lang/ffigen/issues/3).
## The Wrapper library
> Note: The wrapper is only needed because `dart:ffi` currently doesn't support Structs by value.

The `wrapper.c` file consists of functions that wrap LibClang functions. Most of them simply convert structs by value to pointers. Except -
- `clang_visitChildren_wrap` - The bindings for this function internally uses a **list** of **stack** for maintaining the supplied visitor functions. This is required because this function takes a function pointer which itself passes a struct by value. All this effort makes `clang_visitChildren_wrap` behave exactly like `clang_visitChildren`.
## Generation and Usage
The files needed for generating the wrapper are in `lib/src/clang_library`.
> The `wrapper.def` file is only needed on windows because the symbols are otherwise hidden.

The libclang wrapper can be _manually_ generated using `pub run ffigen:setup`. See [setup.dart](#setup.dart) for details.

The generated file is placed in the project's `.dart_tool/ffigen` folder, the file name also specifies the ffigen version (E.g - `_v0_2_4_libclang_wrapper.dylib`), this helps ensure the correct wrapper is being used for its corresponding version.

This dynamic library is then used by [Header Parser](#header-parser) for parsing C files.
## Bindings
The config file for generating bindings is `tool/libclang_config.yaml`. The bindings are generated to `lib/src/header_parser/clang_bindings/clang_bindings.dart`. These are used by [Header Parser](#header-parser) for calling libclang functions.
# Scripts
## ffigen.dart
This is the main entry point for the user-  `pub run ffigen`.
- Command-line options:
    - `--verbose`: Sets log level.
    - `--config`: Specifies a config file.
- `ffigen.dart` will first check if a dynamic library already exists and is up to date. If not, it tries to auto-create it. If that fails, user must excplicitly call [setup.dart](#setup.dart).
- The internal modules are called by `ffigen.dart` in the following way:
    - It first creates a `Config` object from an input Yaml file. This is used by other modules.
    - The `parse` method is then invoked to generate a `Library` object.
    - Finally, the code is generated from the `Library` object to the specified file.
## setup.dart
Used to generate the wrapper dynamic library. Users will need to explicitly call this if `pub run ffigen` is unable to auto-create the dynamic library.
> `clang` must be on user's path for `setup.dart` to work.

- Command-line options:
    - `-I`: Specifies header includes.
    - `-L`: Specifies library includes.
- `setup.dart` generates the dynamic library to the project's `.dart_tool/ffigen` folder using `clang`.
# Components
## Config Provider
The Config Provider holds all the configurations required by other modules.
- Config Provider handles validation and extraction of configurations from YAML files.
- Config Provider converts configurations to the format required by other modules. This object is passed around to every other module.
## Header Parser
The Header Parser parses C header files and converts them into a `Library` object.
- Header Parser handles including/excluding/renaming of declarations.
- Header Parser also filters out any _unimplemented_ or _unsupported_ declarations before generating a `Library` object.
## Code Generator
The Code Generator generates the actual string bindings.
- Code generator handles all external name collisions, while internal name conflicts are handled by each specific `Binding`.
- Code Generator also handles how workarounds for arrays and bools are generated.
