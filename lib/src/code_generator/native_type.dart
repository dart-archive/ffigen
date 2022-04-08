// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

enum SupportedNativeType {
  Void,
  Char,
  Int8,
  Int16,
  Int32,
  Int64,
  Uint8,
  Uint16,
  Uint32,
  Uint64,
  Float,
  Double,
  IntPtr,
}

/// Represents a primitive native type, such as float.
class NativeType extends Type {
  static const _primitives = <SupportedNativeType, NativeType>{
    SupportedNativeType.Void: NativeType._('Void', 'void'),
    SupportedNativeType.Char: NativeType._('Uint8', 'int'),
    SupportedNativeType.Int8: NativeType._('Int8', 'int'),
    SupportedNativeType.Int16: NativeType._('Int16', 'int'),
    SupportedNativeType.Int32: NativeType._('Int32', 'int'),
    SupportedNativeType.Int64: NativeType._('Int64', 'int'),
    SupportedNativeType.Uint8: NativeType._('Uint8', 'int'),
    SupportedNativeType.Uint16: NativeType._('Uint16', 'int'),
    SupportedNativeType.Uint32: NativeType._('Uint32', 'int'),
    SupportedNativeType.Uint64: NativeType._('Uint64', 'int'),
    SupportedNativeType.Float: NativeType._('Float', 'double'),
    SupportedNativeType.Double: NativeType._('Double', 'double'),
    SupportedNativeType.IntPtr: NativeType._('IntPtr', 'int'),
  };

  final String _cType;
  final String _dartType;

  const NativeType._(this._cType, this._dartType);

  factory NativeType(SupportedNativeType type) => _primitives[type]!;

  @override
  String getCType(Writer w) => '${w.ffiLibraryPrefix}.$_cType';

  @override
  String getDartType(Writer w) => _dartType;

  @override
  String toString() => _cType;
}

class BooleanType extends NativeType {
  // Booleans are treated as uint8.
  const BooleanType._() : super._('Uint8', 'int');
  static const _boolean = BooleanType._();
  factory BooleanType() => _boolean;

  @override
  String toString() => 'bool';
}
