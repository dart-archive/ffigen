// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart' show SupportedNativeType;
import 'package:ffigen/src/code_generator/imports.dart';

var cxTypeKindToImportedTypes = <String, ImportedType>{
  'void': voidType,
  'unsigned char': unsignedCharType,
  'signed char': signedCharType,
  'char': charType,
  'unsigned short': unsignedShortType,
  'short': shortType,
  'unsigned int': unsignedIntType,
  'int': intType,
  'unsigned long': unsignedLongType,
  'long': longType,
  'unsigned long long': unsignedLongLongType,
  'long long': longLongType,
  'float': floatType,
  'double': doubleType,
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

var supportedTypedefToImportedType = <String, ImportedType>{
  'size_t': sizeType,
  'wchar_t': wCharType,
};
