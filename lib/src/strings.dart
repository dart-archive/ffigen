// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:ffigen/src/header_parser/clang_bindings/clang_bindings.dart'
    as clang;

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

// Sub-fields of Declarations.
const include = 'include';
const exclude = 'exclude';

// Sub-fields of include/exclude.
const matches = 'matches'; // regex
const names = 'names'; // hashset

const sizemap = 'size-map';

// Sizemap values.
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

// Used for validation and extraction of sizemap.
const sizemap_native_mapping = <String, int>{
  SChar: clang.CXTypeKind.CXType_SChar,
  UChar: clang.CXTypeKind.CXType_UChar,
  Short: clang.CXTypeKind.CXType_Short,
  UShort: clang.CXTypeKind.CXType_UShort,
  Int: clang.CXTypeKind.CXType_Int,
  UInt: clang.CXTypeKind.CXType_UInt,
  Long: clang.CXTypeKind.CXType_Long,
  ULong: clang.CXTypeKind.CXType_ULong,
  LongLong: clang.CXTypeKind.CXType_LongLong,
  ULongLong: clang.CXTypeKind.CXType_ULongLong,
  Enum: clang.CXTypeKind.CXType_Enum
};

// Boolean flags.
const sort = 'sort';
const useSupportedTypedefs = 'use-supported-typedefs';
const warnWhenRemoving = 'warn-when-removing';
const extractComments = 'extract-comments';

// Dynamic library names.
const libclang_dylib_linux = 'libwrapped_clang.so';
const libclang_dylib_macos = 'libwrapped_clang.dylib';
const libclang_dylib_windows = 'wrapped_clang.dll';
