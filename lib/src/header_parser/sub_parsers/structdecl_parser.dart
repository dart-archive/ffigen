// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.structdecl_parser');

/// Holds temporary information regarding [struc] while parsing.
class _ParsedStruc {
  Struc? struc;
  bool unimplementedMemberType = false;
  bool flexibleArrayMember = false;
  bool arrayMember = false;
  bool bitFieldMember = false;
  bool dartHandleMember = false;
  bool incompleteStructMember = false;

  bool get isInComplete =>
      unimplementedMemberType ||
      flexibleArrayMember ||
      (arrayMember && !config.arrayWorkaround) ||
      bitFieldMember ||
      (dartHandleMember && config.useDartHandle) ||
      incompleteStructMember;

  _ParsedStruc();
}

final _stack = Stack<_ParsedStruc>();

/// Parses a struct declaration.
Struc? parseStructDeclaration(
  clang_types.CXCursor cursor, {

  /// Optionally provide name (useful in case struct is inside a typedef).
  String? name,

  /// Option to ignore struct filter (Useful in case of extracting structs
  /// when they are passed/returned by an included function.)
  bool ignoreFilter = false,

  /// To track if the struct was used by reference(i.e struct*). (Used to only
  /// generate these as opaque if `struct-dependencies` was set to opaque).
  bool pointerReference = false,

  /// If the struct name should be updated, if it was already seen.
  bool updateName = true,
}) {
  _stack.push(_ParsedStruc());

  // Parse the cursor definition instead, if this is a forward declaration.
  if (isForwardDeclaration(cursor)) {
    cursor = clang.clang_getCursorDefinition(cursor);
  }

  final structUsr = cursor.usr();
  final structName = name ?? cursor.spelling();

  if (structName.isEmpty) {
    if (ignoreFilter) {
      // This struct is defined inside some other struct and hence must be generated.
      _stack.top.struc = Struc(
        name: incrementalNamer.name('unnamedStruct'),
        usr: structUsr,
        dartDoc: getCursorDocComment(cursor),
      );
      _setStructMembers(cursor);
    } else {
      _logger.finest('unnamed structure or typedef structure declaration');
    }
  } else if ((ignoreFilter || shouldIncludeStruct(structUsr, structName)) &&
      (!bindingsIndex.isSeenStruct(structUsr))) {
    _logger.fine(
        '++++ Adding Structure: structName: $structName, ${cursor.completeStringRepr()}');
    _stack.top.struc = Struc(
      usr: structUsr,
      originalName: structName,
      name: config.structDecl.renameUsingConfig(structName),
      dartDoc: getCursorDocComment(cursor),
    );
    // Adding to seen here to stop recursion if a struct has itself as a
    // member, members are updated later.
    bindingsIndex.addStructToSeen(structUsr, _stack.top.struc!);
  }

  if (bindingsIndex.isSeenStruct(structUsr)) {
    _stack.top.struc = bindingsIndex.getSeenStruct(structUsr);

    final skipDependencies = _stack.top.struc!.parsedDependencies ||
        (config.structDependencies == StructDependencies.opaque &&
            pointerReference &&
            ignoreFilter);

    if (!skipDependencies) {
      // Prevents infinite recursion if struct has a pointer to itself.
      _stack.top.struc!.parsedDependencies = true;
      _setStructMembers(cursor);
    } else if (!_stack.top.struc!.parsedDependencies) {
      _logger.fine('Skipped dependencies.');
    }

    if (updateName) {
      // If struct is seen, update it's name.
      _stack.top.struc!.name = config.structDecl.renameUsingConfig(structName);
    }
  }

  return _stack.pop().struc;
}

void _setStructMembers(clang_types.CXCursor cursor) {
  _stack.top.arrayMember = false;
  _stack.top.unimplementedMemberType = false;

  final resultCode = clang.clang_visitChildren(
    cursor,
    Pointer.fromFunction(_structMembersVisitor,
        clang_types.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  if (_stack.top.arrayMember && !config.arrayWorkaround) {
    _logger.fine(
        '---- Removed Struct members, reason: struct has array members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from: ${_stack.top.struc!.name}(${_stack.top.struc!.originalName}), Array members not supported');
  } else if (_stack.top.unimplementedMemberType) {
    _logger.fine(
        '---- Removed Struct members, reason: member with unimplementedtype ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc!.name}(${_stack.top.struc!.originalName}), struct member has an unsupported type.');
  } else if (_stack.top.flexibleArrayMember) {
    _logger.fine(
        '---- Removed Struct members, reason: incomplete array member ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc!.name}(${_stack.top.struc!.originalName}), Flexible array members not supported.');
  } else if (_stack.top.bitFieldMember) {
    _logger.fine(
        '---- Removed Struct members, reason: bitfield members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc!.name}(${_stack.top.struc!.originalName}), Bit Field members not supported.');
  } else if (_stack.top.dartHandleMember && config.useDartHandle) {
    _logger.fine(
        '---- Removed Struct members, reason: Dart_Handle member. ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc!.name}(${_stack.top.struc!.originalName}), Dart_Handle member not supported.');
  } else if (_stack.top.incompleteStructMember) {
    _logger.fine(
        '---- Removed Struct members, reason: Incomplete Nested Struct member. ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from ${_stack.top.struc!.name}(${_stack.top.struc!.originalName}), Incomplete Nested Struct member not supported.');
  }

  // Clear all struct members if struct is incomplete.
  if (_stack.top.isInComplete) {
    _stack.top.struc!.members.clear();
  }

  // C allow empty structs, but it's undefined behaviour at runtine. So we need
  // to mark a struct incomplete if it has no members.
  _stack.top.struc!.isInComplete =
      _stack.top.isInComplete || _stack.top.struc!.members.isEmpty;
}

/// Visitor for the struct cursor [CXCursorKind.CXCursor_StructDecl].
///
/// Child visitor invoked on struct cursor.
int _structMembersVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  try {
    if (cursor.kind == clang_types.CXCursorKind.CXCursor_FieldDecl) {
      _logger.finer('===== member: ${cursor.completeStringRepr()}');

      final mt = cursor.type().toCodeGenType();
      if (mt.broadType == BroadType.ConstantArray) {
        _stack.top.arrayMember = true;
      }
      if (mt.broadType == BroadType.IncompleteArray) {
        // TODO(68): Structs with flexible Array Members are not supported.
        _stack.top.flexibleArrayMember = true;
      }
      if (clang.clang_getFieldDeclBitWidth(cursor) != -1) {
        // TODO(84): Struct with bitfields are not suppoorted.
        _stack.top.bitFieldMember = true;
      }
      if (mt.broadType == BroadType.Handle) {
        _stack.top.dartHandleMember = true;
      }
      if (mt.isIncompleteStruct) {
        _stack.top.incompleteStructMember = true;
      }
      if (mt.getBaseType().broadType == BroadType.Unimplemented) {
        _stack.top.unimplementedMemberType = true;
      }

      _stack.top.struc!.members.add(
        Member(
          dartDoc: getCursorDocComment(
            cursor,
            nesting.length + commentPrefix.length,
          ),
          originalName: cursor.spelling(),
          name: config.structDecl.renameMemberUsingConfig(
            _stack.top.struc!.originalName,
            cursor.spelling(),
          ),
          type: mt,
        ),
      );
    }
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
