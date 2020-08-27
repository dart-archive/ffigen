// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:ffigen/src/find_resource.dart';
import 'package:ffigen/src/header_parser/clang_bindings/clang_bindings.dart'
    as clang;

String get dylibVersion => ffigenVersion;

/// Name of the dynamic library file according to current platform.
String get dylibFileName {
  String name;
  if (Platform.isLinux) {
    name = libclang_dylib_linux;
  } else if (Platform.isMacOS) {
    name = libclang_dylib_macos;
  } else if (Platform.isWindows) {
    name = libclang_dylib_windows;
  } else {
    throw Exception('Unsupported Platform.');
  }
  return '_${dylibVersion}_$name';
}

const ffigenFolderName = 'ffigen';

const output = 'output';

const headers = 'headers';

// Sub-fields of headers
const entryPoints = 'entry-points';
const includeDirectives = 'include-directives';

const compilerOpts = 'compiler-opts';

// Declarations.
const functions = 'functions';
const structs = 'structs';
const enums = 'enums';
const unnamedEnums = 'unnamed-enums';
const macros = 'macros';

// Sub-fields of Declarations.
const include = 'include';
const exclude = 'exclude';
const rename = 'rename';
const memberRename = 'member-rename';
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
const arrayWorkaround = 'array-workaround';
const dartBool = 'dart-bool';

const comments = 'comments';
// Sub-fields of comments
const style = 'style';
const length = 'length';

// Sub-fields of style
const doxygen = 'doxygen';
const any = 'any';
// Sub-fields of length
const brief = 'brief';
const full = 'full';
// Cmd line comment option
const fparseAllComments = '-fparse-all-comments';

// Library input.
const name = 'name';
const description = 'description';
const preamble = 'preamble';

// Dynamic library names.
const libclang_dylib_linux = 'libwrapped_clang.so';
const libclang_dylib_macos = 'libwrapped_clang.dylib';
const libclang_dylib_windows = 'wrapped_clang.dll';
