# 3.0.0-beta.0
- Added support for inline arrays in `Struct`s.
- Remove config key `array-workaround`.
- Remove deprecated key `llvm-lib` from config, Use `llvm-path` instead.

# 2.5.0-beta.1
- Added support for `Packed` structs. Packed annotations are generated
automatically but can be overriden using `structs -> pack` config.
- Updated sdk constraints to `>=2.13.0-211.6.beta`.

# 2.4.2
- Fix issues due to declarations having duplicate names.
- Fix name conflict of declaration with ffi library prefix.
- Fix `char` not being recognized on platforms where it's unsigned by default.

# 2.4.1
- Added `/usr/lib` to default dynamic library location for linux.

# 2.4.0
- Added new config key `llvm-path` that accepts a list of `path/to/llvm`.
- Deprecated config key `llvm-lib`.

# 2.3.0
- Added config key `compiler-opts-automatic -> macos -> include-c-standard-library`
(default: true) to automatically find and add C standard library on macOS.
- Allow passing list of string to config key `compiler-opts`.

# 2.2.5
- Added new command line flag `--compiler-opts` to the command line tool.

# 2.2.4
- Fix `sort: true` not working.
- Fix extra `//` or `///` in comments when using `comments -> style`: `full`.

# 2.2.3
- Added new subkey `dependency-only` (options - `full (default) | opaque`) under `structs`.
When set to `opaque`, ffigen will generate empty `Opaque` structs if structs
were excluded in config (i.e added because they were a dependency) and
only passed by reference(pointer).

# 2.2.2
- Fixed generation of empty opaque structs due to forward declarations in header files.

# 2.2.1
- Fixed generation of duplicate constants suffixed with `_<int>` when using multiple entry points.

# 2.2.0
- Added subkey `symbol-address` to expose native symbol pointers for `functions` and `globals`.

# 2.1.0
- Added a new named constructor `NativeLibrary.fromLookup()` to support dynamic linking.
- Updated dart SDK constraints to latest stable version `2.12.0`.

# 2.0.3
- Ignore typedef to struct pointer when possible.
- Recursively create directories for output file.

# 2.0.2
- Fixed illegal use of `const` in name, crash due to unnamed inline structs and
structs having `Opaque` members.

# 2.0.1
- Switch to preview release of `package:quiver`.

# 2.0.0
- Upgraded all dependencies. `package:ffigen` now runs with sound null safety.

# 2.0.0-dev.6
- Functions marked `inline` are now skipped.

# 2.0.0-dev.5
- Use `Opaque` for representing empty `Struct`s.

# 2.0.0-dev.4
- Add support for parsing and generating globals.

# 2.0.0-dev.3
- Removed the usage of `--no-sound-null-safety` flag.

# 2.0.0-dev.2
- Removed setup phase for ffigen. Added new optional config key `llvm-lib`
to specify path to `llvm/lib` folder.

# 2.0.0-dev.1
- Added support for passing and returning struct by value in functions.

# 2.0.0-dev.0
- Added support for Nested structs.

# 2.0.0-nullsafety.1
- Removed the need for `--no-sound-null-safety` flag.

# 2.0.0-nullsafety.0
- Migrated to (unsound) null safety.

# 1.2.0
- Added support for `Dart_Handle` from `dart_api.h`.

# 1.1.0
- `typedef-map` can now be used to map a typedef name to a native type directly.

# 1.0.6
- Fixed missing typedefs nested in another typedef's return types.

# 1.0.5
- Fixed issues with generating macros of type `double.Infinity` and `double.NaN`.

# 1.0.4
- Updated code to use `dart format` instead of `dartfmt` for sdk version `>= 2.10.0`.

# 1.0.3
- Fixed errors due to extended ASCII and control characters in macro strings.

# 1.0.2
- Fix indentation for pub's readme.

# 1.0.1
- Fixed generation of `NativeFunction` parameters instead of `Pointer<NativeFunction>` in type signatures.

# 1.0.0
- Bump version to 1.0.0.
- Handle unimplememnted function pointers causing errors.
- Log lexical/semantic issues in headers as SEVERE.

# 0.3.0
- Added support for including/excluding/renaming _un-named enums_ using key `unnamed_enums`.

# 0.2.4+1
- Minor changes to dylib creation error log.

# 0.2.4
- Added support for C booleans as Uint8.
- Added config `dart-bool` (default: true) to use dart bool instead of int in function parameters and return type.

# 0.2.3+3
- Wrapper dynamic library version now uses ffigen version from its pubspec.yaml file.

# 0.2.3+2
- Handle code formatting using dartfmt by finding dart-sdk.

# 0.2.3+1
- Fixed missing typedefs of nested function pointers.

# 0.2.3
- Fixed parsing structs with bitfields, all members of structs with bit field members will now be removed. See [#84](https://github.com/dart-lang/ffigen/issues/84)

# 0.2.2+1
- Updated `package:meta` version to `^1.1.8` for compatibility with flutter sdk.

# 0.2.2
- Fixed multiple generation/skipping of typedef enclosed declarations.
- Typedef names are now given higher preference over inner names, See [#83](https://github.com/dart-lang/ffigen/pull/83).

# 0.2.1+1
- Added FAQ to readme.

# 0.2.1
- Fixed missing/duplicate typedef generation.

# 0.2.0
- Updated header config. Header `entry-points` and `include-directives` are now specified under `headers` key. Glob syntax is allowed.
- Updated declaration `include`/`exclude` config. These are now specified as a list.
- Added Regexp based declaration renaming using `rename` subkey.
- Added Regexp based member renaming for structs, enums and functions using `member-rename` subkey. `prefix` and `prefix-replacement` subkeys have been removed.

# 0.1.5
- Added support for parsing macros and anonymous unnamed enums. These are generated as top level constants.

# 0.1.4
- Comments config now has a style and length sub keys - `style: doxygen(default) | any`, `length: brief | full(default)`, and can be disabled by passing `comments: false`.

# 0.1.3
- Handled function arguments - dart keyword name collision
- Fix travis tests: the dynamic library is created using `pub run ffigen:setup` before running the tests.

# 0.1.2
- Fixed wrapper not found error when running `pub run ffigen`.

# 0.1.1
- Address pub score: follow dart File conventions, provide documentation, and pass static analysis.

# 0.1.0
- Support for Functions, Structs and Enums.
- Glob support for specifying headers.
- HeaderFilter - Include/Exclude declarations from specific header files using name matching.
- Filters - Include/Exclude function, structs and enum declarations using Regexp or Name matching.
- Prefixing - function, structs and enums can have a global prefix. Individual prefix Replacement support using Regexp.
- Comment extraction: full/brief/none
- Support for fixed size arrays in struct. `array-workaround` (if enabled) will generate helpers for accessing fixed size arrays in structs.
- Size for ints can be specified using `size-map` in config.
- Options to disable using supported typedefs (e.g `uint8_t => Uint8`), sort bindings.
- Option to add a raw `preamble` which is included as is in the generated file.
