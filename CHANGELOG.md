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
