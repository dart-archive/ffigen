// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/clang_bindings/clang_bindings.dart'
    as clang;

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
  return name;
}

const llvmPath = 'llvm-path';

/// Name of the parent folder of dynamic library `lib` or `bin` (on windows).
String get dynamicLibParentName => Platform.isWindows ? 'bin' : 'lib';

const output = 'output';

const language = 'language';

// String mappings for the Language enum.
const langC = 'c';
const langObjC = 'objc';

// Clang command line args for Objective C.
const clangLangObjC = ['-x', 'objective-c'];
const clangInclude = '-include';
const clangDefaultObjCSystemHeaderPath =
    '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include';
const clangDefaultObjCSystemHeaders = ['objc/NSObject.h'];

const headers = 'headers';

// Sub-fields of headers
const entryPoints = 'entry-points';
const includeDirectives = 'include-directives';

const compilerOpts = 'compiler-opts';

const compilerOptsAuto = 'compiler-opts-automatic';
// Sub-fields of compilerOptsAuto.
const macos = 'macos';
// Sub-fields of macos.
const includeCStdLib = 'include-c-standard-library';

// Declarations.
const functions = 'functions';
const structs = 'structs';
const unions = 'unions';
const enums = 'enums';
const unnamedEnums = 'unnamed-enums';
const globals = 'globals';
const macros = 'macros';
const typedefs = 'typedefs';

// Sub-fields of Declarations.
const include = 'include';
const exclude = 'exclude';
const rename = 'rename';
const memberRename = 'member-rename';
const symbolAddress = 'symbol-address';

// Nested under `functions`
const exposeFunctionTypedefs = 'expose-typedefs';
const leafFunctions = 'leaf';

const dependencyOnly = 'dependency-only';
// Values for `compoundDependencies`.
const fullCompoundDependencies = 'full';
const opaqueCompoundDependencies = 'opaque';

const structPack = 'pack';
const Map<Object, int?> packingValuesMap = {
  'none': null,
  1: 1,
  2: 2,
  4: 4,
  8: 8,
  16: 16,
};

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

// Library imports.
const libraryImports = 'library-imports';

final predefinedLibraryImports = {
  ffiImport.name: ffiImport,
  ffiPkgImport.name: ffiPkgImport
};

const typeMap = 'type-map';

// Sub-fields for type-map.
const typeMapTypedefs = 'typedefs';
const typeMapStructs = 'structs';
const typeMapUnions = 'unions';
const typeMapNativeTypes = 'native-types';

// Sub-sub-keys for fields under typeMap.
const lib = 'lib';
const cType = 'c-type';
const dartType = 'dart-type';

const supportedNativeType_mappings = <String, SupportedNativeType>{
  'Void': SupportedNativeType.Void,
  'Uint8': SupportedNativeType.Uint8,
  'Uint16': SupportedNativeType.Uint16,
  'Uint32': SupportedNativeType.Uint32,
  'Uint64': SupportedNativeType.Uint64,
  'Int8': SupportedNativeType.Int8,
  'Int16': SupportedNativeType.Int16,
  'Int32': SupportedNativeType.Int32,
  'Int64': SupportedNativeType.Int64,
  'IntPtr': SupportedNativeType.IntPtr,
  'Float': SupportedNativeType.Float,
  'Double': SupportedNativeType.Double,
};

// Boolean flags.
const sort = 'sort';
const useSupportedTypedefs = 'use-supported-typedefs';
const dartBool = 'dart-bool';
const useDartHandle = 'use-dart-handle';

const comments = 'comments';
// Sub-fields of comments.
const style = 'style';
const length = 'length';

// Sub-fields of style.
const doxygen = 'doxygen';
const any = 'any';
// Sub-fields of length.
const brief = 'brief';
const full = 'full';
// Cmd line comment option.
const fparseAllComments = '-fparse-all-comments';

// Library input.
const name = 'name';
const description = 'description';
const preamble = 'preamble';

// Dynamic library names.
const libclang_dylib_linux = 'libclang.so';
const libclang_dylib_macos = 'libclang.dylib';
const libclang_dylib_windows = 'libclang.dll';

// Dynamic library default locations.
const linuxDylibLocations = {
  '/usr/lib/llvm-9/lib/',
  '/usr/lib/llvm-10/lib/',
  '/usr/lib/llvm-11/lib/',
  '/usr/lib/llvm-12/lib/',
  '/usr/lib/llvm-13/lib/',
  '/usr/lib/',
  '/usr/lib64/',
};
const windowsDylibLocations = {
  r'C:\Program Files\LLVM\bin\',
};
const macOsDylibLocations = {
  '/usr/local/opt/llvm/lib/',
  '/opt/homebrew/opt/llvm/lib/',
};

// Writen doubles.
const doubleInfinity = 'double.infinity';
const doubleNegativeInfinity = 'double.negativeInfinity';
const doubleNaN = 'double.nan';

/// USR for struct `_Dart_Handle`.
const dartHandleUsr = 'c:@S@_Dart_Handle';
