const output = 'output';
const libclang_dylib_folder = 'libclang-dylib-folder';
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
const useSupportedTypedefs = 'use-supported-typedefs';

const libclang_dylib_linux = 'libwrapped_clang.so';
const libclang_dylib_macos = 'libwrapped_clang.dylib';
const libclang_dylib_windows = 'wrapped_clang.dll';
