const output = 'output';
const libclang_dylib = 'libclang-dylib';
const headers = 'headers';
const headerFilter = 'header-filter';
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

const sizemap = 'size-map';

const SChar = 'char';
const UChar = 'unsigned char';
const Short = 'short';
const UShort = 'unsigned short';
const Int = 'int';
const UInt = 'unsigned int';
const Long = 'long';
const ULong = 'unsigned long';
const LongLong = 'long long';
const ULongLong = 'unsigned long long';

const sort = 'sort';

/// contains all options and their description
const mapOfAllOptions = <String, String>{
  output: 'Output file name',
  libclang_dylib: 'Path to libclang dynamic library, used to parse C headers',
  headers: 'List of C headers to generate bindings of',
  headerFilter: 'Include/Exclude inclusion headers',
  compilerOpts: 'Raw compiler options to pass to clang compiler',
  filters: 'filters for various bindings',
  sizemap: 'map of types: byte size in int',
  sort: 'whether or not to sort the bindings alphabetically'
};
