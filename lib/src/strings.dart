const output = 'output';
const libclang_dylib = 'libclang-dylib';
const headers = 'headers';
const compilerOpts = 'compiler-opts';
const filters = 'filters';

// subfields of filter
const functions = 'functions';
const structs = 'structs';
const enums = 'enums';

// sub-subfields of filter (declared just above)
const include = 'include';
const exclude = 'exclude';

// sub-sub-subfields of filter (declared just above)
const matches = 'matches';
const names = 'names';

/// contains all options and their description
const mapOfAllOptions = <String, String>{
  output: 'Output file name',
  libclang_dylib: 'Path to libclang dynamic library, used to parse C headers',
  headers: 'List of C headers to generate bindings of',
  compilerOpts: 'Raw compiler options to pass to clang compiler',
  filters: 'filters for various bindings'
};
