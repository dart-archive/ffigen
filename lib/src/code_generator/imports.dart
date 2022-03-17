// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'struc.dart';

/// A library import which will be written as an import in the generated file.
class LibraryImport {
  final String name;
  final String importPath;
  String prefix;

  LibraryImport(this.name, this.importPath) : prefix = name;

  @override
  bool operator ==(other) {
    return other is LibraryImport && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// An imported type which will be used in the generated code.
class ImportedType {
  final LibraryImport libraryImport;
  final String cType;
  final String dartType;

  ImportedType(this.libraryImport, this.cType, this.dartType);
}

final ffiImport = LibraryImport('ffi', 'dart:ffi');
final ffiPkgImport = LibraryImport('pkg_ffi', 'package:ffi/ffi.dart');

final voidType = ImportedType(ffiImport, 'Void', 'void');

final unsignedCharType = ImportedType(ffiPkgImport, 'UnsignedChar', 'int');
final signedCharType = ImportedType(ffiPkgImport, 'SignedChar', 'int');
final charType = ImportedType(ffiPkgImport, 'Char', 'int');
final unsignedShortType = ImportedType(ffiPkgImport, 'UnsignedShort', 'int');
final shortType = ImportedType(ffiPkgImport, 'Short', 'int');
final unsignedIntType = ImportedType(ffiPkgImport, 'UnsignedInt', 'int');
final intType = ImportedType(ffiPkgImport, 'Int', 'int');
final unsignedLongType = ImportedType(ffiPkgImport, 'UnsignedLong', 'int');
final longType = ImportedType(ffiPkgImport, 'Long', 'int');
final unsignedLongLongType =
    ImportedType(ffiPkgImport, 'UnsignedLongLong', 'int');
final longLongType = ImportedType(ffiPkgImport, 'LongLong', 'int');

final floatType = ImportedType(ffiImport, 'Float', 'double');
final doubleType = ImportedType(ffiImport, 'Double', 'double');

final sizeType = ImportedType(ffiPkgImport, 'Size', 'int');
final wCharType = ImportedType(ffiPkgImport, 'WChar', 'int');

final objCObjectType = Struc(name: 'ObjCObject');
final objCSelType = Struc(name: 'ObjCSel');
