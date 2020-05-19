const libclang_dylib = 'libclang-dylib';
const headers = 'headers';
const compilerOpts = 'compiler-opts';

/// contains all options and their description
const mapOfAllOptions = <String, String>{
  libclang_dylib: 'Path to libclang dynamic library, used to parse C headers',
  headers: 'List of C headers to generate bindings of',
  compilerOpts: 'Raw compiler options to pass to clang compiler'
};
