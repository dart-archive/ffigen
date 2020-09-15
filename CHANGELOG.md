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
