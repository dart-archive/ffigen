// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart' show SupportedNativeType;
import 'package:ffigen/src/header_parser/clang_bindings/clang_bindings.dart'
    as clang;

/// Utility to convert CXType to [code_generator.Type].
///
/// Key: CXTypekindEnum, Value: TypeString for code_generator
var cxTypeKindToSupportedNativeTypes = <int, SupportedNativeType>{
  clang.CXTypeKind.CXType_Void: SupportedNativeType.Void,
  clang.CXTypeKind.CXType_UChar: SupportedNativeType.Uint8,
  clang.CXTypeKind.CXType_UShort: SupportedNativeType.Uint16,
  clang.CXTypeKind.CXType_UInt: SupportedNativeType.Uint32,
  clang.CXTypeKind.CXType_ULong: SupportedNativeType.Uint64,
  clang.CXTypeKind.CXType_ULongLong: SupportedNativeType.Uint64,
  clang.CXTypeKind.CXType_SChar: SupportedNativeType.Int8,
  clang.CXTypeKind.CXType_Short: SupportedNativeType.Int16,
  clang.CXTypeKind.CXType_Int: SupportedNativeType.Int32,
  clang.CXTypeKind.CXType_Long: SupportedNativeType.Int64,
  clang.CXTypeKind.CXType_LongLong: SupportedNativeType.Int64,
  clang.CXTypeKind.CXType_Float: SupportedNativeType.Float,
  clang.CXTypeKind.CXType_Double: SupportedNativeType.Double,
  clang.CXTypeKind.CXType_Char_S: SupportedNativeType.Int8,
  clang.CXTypeKind.CXType_Char_U: SupportedNativeType.Uint8,
};

var suportedTypedefToSuportedNativeType = <String, SupportedNativeType>{
  'uint8_t': SupportedNativeType.Uint8,
  'uint16_t': SupportedNativeType.Uint16,
  'uint32_t': SupportedNativeType.Uint32,
  'uint64_t': SupportedNativeType.Uint64,
  'int8_t': SupportedNativeType.Int8,
  'int16_t': SupportedNativeType.Int16,
  'int32_t': SupportedNativeType.Int32,
  'int64_t': SupportedNativeType.Int64,
  'intptr_t': SupportedNativeType.IntPtr,
};
