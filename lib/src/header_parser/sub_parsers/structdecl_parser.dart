// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

var _logger = Logger('header_parser:structdecl_parser.dart');

/// Temporarily holds a struc before its returned by [parseStructDeclaration].
Struc _struc;

/// Parses a struct declaration.
Struc parseStructDeclaration(
  Pointer<clang_types.CXCursor> cursor, {

  /// Optionally provide name (useful in case struct is inside a typedef).
  String name,

  /// Option to ignore struct filter (Useful in case of extracting structs
  /// when they are passed/returned by an included function.)
  bool ignoreFilter = false,
}) {
  _struc = null;
  final structName = name ?? cursor.spelling();

  if (structName == '') {
    _logger.finest('unnamed structure or typedef structure declaration');
    return null;
  } else if ((ignoreFilter || shouldIncludeStruct(structName)) &&
      (!isSeenStruc(structName))) {
    _logger.fine(
        '++++ Adding Structure: structName: ${structName}, ${cursor.completeStringRepr()}');

    _struc = Struc(
      name: config.structDecl.getPrefixedName(structName),
      dartDoc: getCursorDocComment(cursor),
    );
    // Adding to seen here to stop recursion if a struct has itself as a
    // member, members are updated later.
    addStrucToSeen(structName, _struc);
    _struc.members = _getMembers(cursor, structName);
  }

  return _struc;
}

List<Member> _members;
List<Member> _getMembers(Pointer<clang_types.CXCursor> cursor, String structName) {
  _members = [];
  arrayMember = false;
  nestedStructMember = false;
  unimplementedMemberType = false;

  final resultCode = clang.clang_visitChildren_wrap(
      cursor,
      Pointer.fromFunction(
          _structMembersVisitor, clang_types.CXChildVisitResult.CXChildVisit_Break),
      nullptr);

  visitChildrenResultChecker(resultCode);

  // Returning null to exclude the struct members as it has a struct by value field.
  if (arrayMember && !config.arrayWorkaround) {
    _logger.fine(
        '---- Removed Struct members, reason: struct has array members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from: $structName, Array members not supported');
    return [];
  } else if (nestedStructMember) {
    _logger.fine(
        '---- Removed Struct members, reason: struct has struct members ${cursor.completeStringRepr()}');
    _logger.warning(
        "Removed All Struct Members from '$structName', Nested Structures not supported.");
    return [];
  } else if (unimplementedMemberType) {
    _logger.fine(
        '---- Removed Struct members, reason: member with unimplementedtype ${cursor.completeStringRepr()}');
    _logger.warning(
        "Removed All Struct Members from '$structName', struct member has an unsupported type.");
    return [];
  }

  return _members;
}

bool nestedStructMember = false;
bool unimplementedMemberType = false;
bool arrayMember = false;

/// Visitor for the struct cursor [CXCursorKind.CXCursor_StructDecl].
///
/// Child visitor invoked on struct cursor.
int _structMembersVisitor(Pointer<clang_types.CXCursor> cursor,
    Pointer<clang_types.CXCursor> parent, Pointer<Void> clientData) {
  try {
    if (cursor.kind() == clang_types.CXCursorKind.CXCursor_FieldDecl) {
      _logger.finer('===== member: ${cursor.completeStringRepr()}');

      final mt = cursor.type().toCodeGenTypeAndDispose();

      //TODO(4): Remove these when support for Structs by value arrives.
      if (mt.broadType == BroadType.Struct) {
        // Setting this flag will exclude adding members for this struct's
        // bindings.
        nestedStructMember = true;
      } else if (mt.broadType == BroadType.ConstantArray) {
        arrayMember = true;
        if (mt.child.broadType == BroadType.Struct) {
          // Setting this flag will exclude adding members for this struct's
          // bindings.
          nestedStructMember = true;
        }
      }

      if (mt.getBaseType().broadType == BroadType.Unimplemented) {
        unimplementedMemberType = true;
      }

      _members.add(
        Member(
          dartDoc: getCursorDocComment(
            cursor,
            nesting.length + commentPrefix.length,
          ),
          name: cursor.spelling(),
          type: mt,
        ),
      );
    }
    cursor.dispose();
    parent.dispose();
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
