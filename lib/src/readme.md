# Overview - 
- `code_generator` - Generates binding files.
- `config_provider` - Holds configurations to be passed to other modules.
- `header_parser` - Parses header files, utilises clang_bindings.

# Code Details
## Modules
We are using libclang to parse header files.
This project is roughly divided in 3 major modules -
### code_generator
Converts a library(all bindings) to an actual string representation.
- Library (output of the header parser).
- Writer (provides configurations for generating bindings).
- Binding (base class for all bindings - Func, Struc, Global, EnumClass, etc).
### config_provider
This takes care of validating user config files, printing config warnings and errors,
converting config.yaml to a format the header_parser can use.
- Spec (represents a single config, which a user can provide in the config file).
- Config (holds all the config which will be required by header parser).
### header_parser
Uses libclang to convert the header to a Library which is then used by code_generator.
- clang_bindings (bindings to libclang which are used for parsing).
- sub_parsers (each sub-parser parses a particular kind of declaration - struct, function, typedef, enum).
- type_extractor (extracts types from variables, function parameters, return types).
- includer (tells what should/shouldn't be included depending of config).
- parser (Main Entrypoint) (creates translation units for all header files, and sets up parsing them).
- translation_unit_parser (parses header files, splits declarations and feeds them to their respective sub_parsers).