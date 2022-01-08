// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

final unsignedCharType = ImportedType(ffiImport, 'Uint8', 'int');
final charType = ImportedType(ffiImport, 'Int8', 'int');
final unsignedShortType = ImportedType(ffiImport, 'Uint16', 'int');
final shortType = ImportedType(ffiImport, 'Int16', 'int');
final unsignedIntType = ImportedType(ffiImport, 'Uint32', 'int');
final intType = ImportedType(ffiImport, 'Int32', 'int');
final unsignedLongType = ImportedType(ffiImport, 'Uint64', 'int');
final longType = ImportedType(ffiImport, 'Int64', 'int');
final unsignedLongLongType = ImportedType(ffiImport, 'Uint64', 'int');
final longLongType = ImportedType(ffiImport, 'Int64', 'int');

final floatType = ImportedType(ffiImport, 'Float', 'double');
final doubleType = ImportedType(ffiImport, 'Double', 'double');
