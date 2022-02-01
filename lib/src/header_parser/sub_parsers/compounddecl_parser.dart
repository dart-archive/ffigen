// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';

import '../../strings.dart' as strings;
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.compounddecl_parser');

/// Holds temporary information regarding [compound] while parsing.
class _ParsedCompound {
  Compound? compound;
  bool unimplementedMemberType = false;
  bool flexibleArrayMember = false;
  bool bitFieldMember = false;
  bool dartHandleMember = false;
  bool incompleteCompoundMember = false;

  bool get isInComplete =>
      unimplementedMemberType ||
      flexibleArrayMember ||
      bitFieldMember ||
      (dartHandleMember && config.useDartHandle) ||
      incompleteCompoundMember;

  // A struct without any attribute is definitely not packed. #pragma pack(...)
  // also adds an attribute, but it's unexposed and cannot be travesed.
  bool hasAttr = false;
  // A struct which as a __packed__ attribute is definitely packed.
  bool hasPackedAttr = false;
  // Stores the maximum alignment from all the children.
  int maxChildAlignment = 0;
  // Alignment of this struct.
  int allignment = 0;

  bool get _isPacked {
    if (!hasAttr || isInComplete) return false;
    if (hasPackedAttr) return true;

    return maxChildAlignment > allignment;
  }

  /// Returns pack value of a struct depending on config, returns null for no
  /// packing.
  int? get packValue {
    if (compound!.isStruct && _isPacked) {
      if (strings.packingValuesMap.containsKey(allignment)) {
        return allignment;
      } else {
        _logger.warning(
            'Unsupported pack value "$allignment" for Struct "${compound!.name}".');
        return null;
      }
    } else {
      return null;
    }
  }

  _ParsedCompound();
}

final _stack = Stack<_ParsedCompound>();

/// Parses a compound declaration.
Compound? parseCompoundDeclaration(
  clang_types.CXCursor cursor,
  CompoundType compoundType, {

  /// Option to ignore declaration filter (Useful in case of extracting
  /// declarations when they are passed/returned by an included function.)
  bool ignoreFilter = false,

  /// To track if the declaration was used by reference(i.e T*). (Used to only
  /// generate these as opaque if `dependency-only` was set to opaque).
  bool pointerReference = false,
}) {
  _stack.push(_ParsedCompound());

  // Set includer functions according to compoundType.
  final bool Function(String, String) shouldIncludeDecl;
  final bool Function(String) isSeenDecl;
  final Compound? Function(String) getSeenDecl;
  final void Function(String, Compound) addDeclToSeen;
  final Declaration configDecl;
  final String className;
  switch (compoundType) {
    case CompoundType.struct:
      shouldIncludeDecl = shouldIncludeStruct;
      isSeenDecl = bindingsIndex.isSeenStruct;
      getSeenDecl = bindingsIndex.getSeenStruct;
      addDeclToSeen = bindingsIndex.addStructToSeen;
      configDecl = config.structDecl;
      className = 'Struct';
      break;
    case CompoundType.union:
      shouldIncludeDecl = shouldIncludeUnion;
      isSeenDecl = bindingsIndex.isSeenUnion;
      getSeenDecl = bindingsIndex.getSeenUnion;
      addDeclToSeen = bindingsIndex.addUnionToSeen;
      configDecl = config.unionDecl;
      className = 'Union';
      break;
  }

  // Parse the cursor definition instead, if this is a forward declaration.
  if (isForwardDeclaration(cursor)) {
    cursor = clang.clang_getCursorDefinition(cursor);
  }
  final declUsr = cursor.usr();
  final String declName;

  // Only set name using USR if the type is not Anonymous (A struct is anonymous
  // if it has no name, is not inside any typedef and declared inline inside
  // another declaration).
  if (clang.clang_Cursor_isAnonymous(cursor) == 0) {
    // This gives the significant name, i.e name of the struct if defined or
    // name of the first typedef declaration that refers to it.
    declName = declUsr.split('@').last;
  } else {
    // Empty names are treated as inline declarations.
    declName = '';
  }

  if (declName.isEmpty) {
    if (ignoreFilter) {
      // This declaration is defined inside some other declaration and hence
      // must be generated.
      _stack.top.compound = Compound.fromType(
        type: compoundType,
        name: incrementalNamer.name('Unnamed$className'),
        usr: declUsr,
        dartDoc: getCursorDocComment(cursor),
      );
      _setMembers(cursor, className);
    } else {
      _logger.finest('unnamed $className declaration');
    }
  } else if ((ignoreFilter || shouldIncludeDecl(declUsr, declName)) &&
      (!isSeenDecl(declUsr))) {
    _logger.fine(
        '++++ Adding $className: Name: $declName, ${cursor.completeStringRepr()}');
    _stack.top.compound = Compound.fromType(
      type: compoundType,
      usr: declUsr,
      originalName: declName,
      name: configDecl.renameUsingConfig(declName),
      dartDoc: getCursorDocComment(cursor),
    );
    // Adding to seen here to stop recursion if a declaration has itself as a
    // member, members are updated later.
    addDeclToSeen(declUsr, _stack.top.compound!);
  }

  if (isSeenDecl(declUsr)) {
    _stack.top.compound = getSeenDecl(declUsr);

    // Skip dependencies if already seen OR user has specified `dependency-only`
    // as opaque AND this is a pointer reference AND the declaration was not
    // included according to config (ignoreFilter).
    final skipDependencies = _stack.top.compound!.parsedDependencies ||
        (pointerReference &&
            ignoreFilter &&
            ((compoundType == CompoundType.struct &&
                    config.structDependencies == CompoundDependencies.opaque) ||
                (compoundType == CompoundType.union &&
                    config.unionDependencies == CompoundDependencies.opaque)));

    if (!skipDependencies) {
      // Prevents infinite recursion if struct has a pointer to itself.
      _stack.top.compound!.parsedDependencies = true;
      _setMembers(cursor, className);
    } else if (!_stack.top.compound!.parsedDependencies) {
      _logger.fine('Skipped dependencies.');
    }
  }

  return _stack.pop().compound;
}

void _setMembers(clang_types.CXCursor cursor, String className) {
  _stack.top.hasAttr = clang.clang_Cursor_hasAttrs(cursor) != 0;
  _stack.top.allignment = cursor.type().alignment();

  final resultCode = clang.clang_visitChildren(
    cursor,
    Pointer.fromFunction(_compoundMembersVisitor, exceptional_visitor_return),
    nullptr,
  );

  _logger.finest(
      'Opaque: ${_stack.top.isInComplete}, HasAttr: ${_stack.top.hasAttr}, AlignValue: ${_stack.top.allignment}, MaxChildAlignValue: ${_stack.top.maxChildAlignment}, PackValue: ${_stack.top.packValue}.');
  _stack.top.compound!.pack = _stack.top.packValue;

  visitChildrenResultChecker(resultCode);

  if (_stack.top.unimplementedMemberType) {
    _logger.fine(
        '---- Removed $className members, reason: member with unimplementedtype ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All $className Members from ${_stack.top.compound!.name}(${_stack.top.compound!.originalName}), struct member has an unsupported type.');
  } else if (_stack.top.flexibleArrayMember) {
    _logger.fine(
        '---- Removed $className members, reason: incomplete array member ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All $className Members from ${_stack.top.compound!.name}(${_stack.top.compound!.originalName}), Flexible array members not supported.');
  } else if (_stack.top.bitFieldMember) {
    _logger.fine(
        '---- Removed $className members, reason: bitfield members ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All $className Members from ${_stack.top.compound!.name}(${_stack.top.compound!.originalName}), Bit Field members not supported.');
  } else if (_stack.top.dartHandleMember && config.useDartHandle) {
    _logger.fine(
        '---- Removed $className members, reason: Dart_Handle member. ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All $className Members from ${_stack.top.compound!.name}(${_stack.top.compound!.originalName}), Dart_Handle member not supported.');
  } else if (_stack.top.incompleteCompoundMember) {
    _logger.fine(
        '---- Removed $className members, reason: Incomplete Nested Struct member. ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All $className Members from ${_stack.top.compound!.name}(${_stack.top.compound!.originalName}), Incomplete Nested Struct member not supported.');
  }

  // Clear all members if declaration is incomplete.
  if (_stack.top.isInComplete) {
    _stack.top.compound!.members.clear();
  }

  // C allows empty structs/union, but it's undefined behaviour at runtine.
  // So we need to mark a declaration incomplete if it has no members.
  _stack.top.compound!.isInComplete =
      _stack.top.isInComplete || _stack.top.compound!.members.isEmpty;
}

/// Visitor for the struct/union cursor [CXCursorKind.CXCursor_StructDecl]/
/// [CXCursorKind.CXCursor_UnionDecl].
///
/// Child visitor invoked on struct/union cursor.
int _compoundMembersVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  try {
    if (cursor.kind == clang_types.CXCursorKind.CXCursor_FieldDecl) {
      _logger.finer('===== member: ${cursor.completeStringRepr()}');

      // Set maxChildAlignValue.
      final align = cursor.type().alignment();
      if (align > _stack.top.maxChildAlignment) {
        _stack.top.maxChildAlignment = align;
      }

      final mt = cursor.type().toCodeGenType();
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
      if (mt.isIncompleteCompound) {
        _stack.top.incompleteCompoundMember = true;
      }
      if (mt.getBaseType().broadType == BroadType.Unimplemented) {
        _stack.top.unimplementedMemberType = true;
      }

      _stack.top.compound!.members.add(
        Member(
          dartDoc: getCursorDocComment(
            cursor,
            nesting.length + commentPrefix.length,
          ),
          originalName: cursor.spelling(),
          name: config.structDecl.renameMemberUsingConfig(
            _stack.top.compound!.originalName,
            cursor.spelling(),
          ),
          type: mt,
        ),
      );
    } else if (cursor.kind == clang_types.CXCursorKind.CXCursor_PackedAttr) {
      _stack.top.hasPackedAttr = true;
    }
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
