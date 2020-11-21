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

final _logger = Logger('ffigen.header_parser.structdecl_parser');

/// Holds temporary information regarding [struc] while parsing.
class _ParsedStruc {
  Struc struc;
  bool nestedStructMember = false;
  bool unimplementedMemberType = false;
  bool flexibleArrayMember = false;
  bool arrayMember = false;
  bool bitFieldMember = false;
  bool dartHandleMember = false;
  _ParsedStruc();
}

final _stack = Stack<_ParsedStruc>();

/// Parses a struct declaration.
Struc parseStructDeclaration(
  Pointer<clang_types.CXCursor> cursor, {

  /// Optionally provide name (useful in case struct is inside a typedef).
  String name,

  /// Option to ignore struct filter (Useful in case of extracting structs
  /// when they are passed/returned by an included function.)
  bool ignoreFilter = false,
}) {
  _stack.push(_ParsedStruc());

  final structUsr = cursor.usr();
  final structName = name ?? cursor.spelling();

  if (structName.isEmpty) {
    _logger.finest('unnamed structure or typedef structure declaration');
  } else if ((ignoreFilter || shouldIncludeStruct(structUsr, structName)) &&
      (!bindingsIndex.isSeenStruct(structUsr))) {
    _logger.fine(
        '++++ Adding Structure: structName: ${structName}, ${cursor.completeStringRepr()}');
    _stack.top.struc = Struc(
      usr: structUsr,
      originalName: structName,
      name: config.structDecl.renameUsingConfig(structName),
      dartDoc: getCursorDocComment(cursor),
    );
    // Adding to seen here to stop recursion if a struct has itself as a
    // member, members are updated later.
    bindingsIndex.addStructToSeen(structUsr, _stack.top.struc);
    _setStructMembers(cursor);
  }

  if (bindingsIndex.isSeenStruct(structUsr)) {
    _stack.top.struc = bindingsIndex.getSeenStruct(structUsr);

    // If struct is seen, update it's name.
    _stack.top.struc.name = config.structDecl.renameUsingConfig(structName);
  }
  return _stack.pop().struc;
}

void _setStructMembers(Pointer<clang_types.CXCursor> cursor) {
  _stack.top.arrayMember = false;
  _stack.top.nestedStructMember = false;
  _stack.top.unimplementedMemberType = false;

  final resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(_structMembersVisitor,
        clang_types.CXChildVisitResult.CXChildVisit_Break),
    uid,
  );

  visitChildrenResultChecker(resultCode);

  // Returning null to exclude the struct members as it has a struct by value field.
  if (_stack.top.arrayMember && !config.arrayWorkaround) {
    _logger.fine(
        '---- Removed Struct members, reason: struct has array members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from: ${_stack.top.struc.name}(${_stack.top.struc.originalName}), Array members not supported');
    return _stack.top.struc.members.clear();
  } else if (_stack.top.nestedStructMember) {
    _logger.fine(
        '---- Removed Struct members, reason: struct has struct members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc.name}(${_stack.top.struc.originalName}), Nested Structures not supported.');
    return _stack.top.struc.members.clear();
  } else if (_stack.top.unimplementedMemberType) {
    _logger.fine(
        '---- Removed Struct members, reason: member with unimplementedtype ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc.name}(${_stack.top.struc.originalName}), struct member has an unsupported type.');
    return _stack.top.struc.members.clear();
  } else if (_stack.top.flexibleArrayMember) {
    _logger.fine(
        '---- Removed Struct members, reason: incomplete array member ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc.name}(${_stack.top.struc.originalName}), Flexible array members not supported.');
    return _stack.top.struc.members.clear();
  } else if (_stack.top.bitFieldMember) {
    _logger.fine(
        '---- Removed Struct members, reason: bitfield members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc.name}(${_stack.top.struc.originalName}), Bit Field members not supported.');
    return _stack.top.struc.members.clear();
  } else if (_stack.top.dartHandleMember) {
    _logger.fine(
        '---- Removed Struct members, reason: Dart_Handle member. ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc.name}(${_stack.top.struc.originalName}), Dart_Handle member not supported.');
    return _stack.top.struc.members.clear();
  }
}

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
        _stack.top.nestedStructMember = true;
      } else if (mt.broadType == BroadType.ConstantArray) {
        _stack.top.arrayMember = true;
        if (mt.child.broadType == BroadType.Struct) {
          // Setting this flag will exclude adding members for this struct's
          // bindings.
          _stack.top.nestedStructMember = true;
        }
      } else if (mt.broadType == BroadType.IncompleteArray) {
        // TODO(68): Structs with flexible Array Members are not supported.
        _stack.top.flexibleArrayMember = true;
      } else if (clang.clang_getFieldDeclBitWidth_wrap(cursor) != -1) {
        // TODO(84): Struct with bitfields are not suppoorted.
        _stack.top.bitFieldMember = true;
      } else if (mt.broadType == BroadType.Handle) {
        _stack.top.dartHandleMember = true;
      }

      if (mt.getBaseType().broadType == BroadType.Unimplemented) {
        _stack.top.unimplementedMemberType = true;
      }

      _stack.top.struc.members.add(
        Member(
          dartDoc: getCursorDocComment(
            cursor,
            nesting.length + commentPrefix.length,
          ),
          originalName: cursor.spelling(),
          name: config.structDecl.renameMemberUsingConfig(
            _stack.top.struc.originalName,
            cursor.spelling(),
          ),
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
