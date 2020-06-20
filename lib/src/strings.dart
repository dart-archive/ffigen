// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const output = 'output';
const libclang_dylib_folder = 'libclang-dylib-folder';
const headers = 'headers';
const headerFilter = 'header-filter';
const compilerOpts = 'compiler-opts';
const filters = 'filters';

// Declarations.
const functions = 'functions';
const structs = 'structs';
const enums = 'enums';

// include/exclude: sub-fields of Declarations.
const include = 'include';
const exclude = 'exclude';

// matches: and names :sub-fields of include/exclude.
const matches = 'matches'; // regex
const names = 'names'; // hashset

const sizemap = 'size-map';

// sizemap values.
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
const Enum = 'enum';

// Used for validation of sizemap.
const sizemap_expected_values = <String>{
  SChar,
  UChar,
  Short,
  UShort,
  Int,
  UInt,
  Long,
  ULong,
  LongLong,
  ULongLong,
  Enum
};

// boolean flags.
const sort = 'sort';
const useSupportedTypedefs = 'use-supported-typedefs';
const warnWhenRemoving = 'warn-when-removing';
const extractComments = 'extract-comments';

// dynamic library names.
const libclang_dylib_linux = 'libwrapped_clang.so';
const libclang_dylib_macos = 'libwrapped_clang.dylib';
const libclang_dylib_windows = 'wrapped_clang.dll';
