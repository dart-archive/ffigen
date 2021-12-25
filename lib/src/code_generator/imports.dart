// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Represents a library import which will be written as an import in the
/// generated file.
class LibraryImport {
  final String name;
  final String importPath;
  late String prefix;

  LibraryImport(this.name, this.importPath) {
    prefix = name;
  }

  @override
  bool operator ==(other) {
    return other is LibraryImport && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// Represents an imported type.
class ImportedType {
  final LibraryImport libraryImport;
  final String cType;
  final String dartType;

  ImportedType(this.libraryImport, this.cType, this.dartType);
}

final ffiImport = LibraryImport('ffi', 'dart:ffi');
final ffiPkgImport = LibraryImport('pkg_ffi', 'package:ffi/ffi.dart');
