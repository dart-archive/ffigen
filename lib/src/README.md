# **_package:ffigen_**: Internal Working
## Table of Contents -
1. [Overview](#overview)
2. [LibClang](#LibClang)
    1. [Bindings](#Bindings)
3. [Scripts](#scripts)
    1. [ffigen.dart](#ffigen.dart)
4. [Components](#components)
    1. [Config Provider](#Config-Provider)
    2. [Header Parser](#Header-Parser)
    3. [Code Generator](#Code-Generator)
# Overview
`package:ffigen` simplifies the process of generating `dart:ffi` bindings from C header files. It is simple to use, with the input being a small YAML config file. It requires LLVM (9+) to work. This document tries to give a complete overview of every component without going into too many details about every single class/file.
# LibClang
`package:ffigen` binds to LibClang using `dart:ffi` for parsing C header files. 
## Bindings
The config file for generating bindings is `tool/libclang_config.yaml`. The bindings are generated to `lib/src/header_parser/clang_bindings/clang_bindings.dart`. These are used by [Header Parser](#header-parser) for calling libclang functions.
# Scripts
## ffigen.dart
This is the main entry point for the user-  `dart run ffigen`.
- Command-line options:
    - `--verbose`: Sets log level.
    - `--config`: Specifies a config file.
- The internal modules are called by `ffigen.dart` in the following way:
- `ffigen.dart` will try to find dynamic library in default locations. If that fails, the user must excplicitly specify location in ffigen's config under the key `llvm-lib`.
    - It first creates a `Config` object from an input Yaml file. This is used by other modules.
    - The `parse` method is then invoked to generate a `Library` object.
    - Finally, the code is generated from the `Library` object to the specified file.
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
