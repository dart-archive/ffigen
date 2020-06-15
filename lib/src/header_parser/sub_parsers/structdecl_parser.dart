import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../includer.dart';
import '../utils.dart';

var _logger = Logger('parser:structdecl_parser');

/// Temporarily holds a struc before its returned by [parseStructDeclaration]
Struc _struc;

/// Parses a struct declaration
Struc parseStructDeclaration(
  Pointer<clang.CXCursor> cursor, {

  /// Optionally provide name (useful in case struct is inside a typedef)
  String name,

  /// to override shouldInclude methods
  /// (useful in case of extracting structs
  /// when they are passed/returned by an included function)
  /// you should check if binding is not already included
  /// before setting this to true
  bool doInclude = false,
}) {
  _struc = null;
  var structName = name ?? cursor.spelling();

  if (structName == '') {
    _logger.finest('unnamed or typedef structure declaration:');
  } else if (doInclude || shouldIncludeStruct(structName)) {
    _logger.fine(
        '++++ Adding Structure: name:${structName} ${cursor.completeStringRepr()}');

    var members = _getMembers(cursor, structName);
    _struc = Struc(
      dartDoc: clang
          .clang_Cursor_getBriefCommentText_wrap(cursor)
          .toStringAndDispose(),
      name: structName,
      members: members,
    );
  }

  return _struc;
}

List<Member> _members;
List<Member> _getMembers(Pointer<clang.CXCursor> cursor, String structName) {
  _members = [];
  isStructByValue = false;

  var resultCode = clang.clang_visitChildren_wrap(
      cursor,
      Pointer.fromFunction(
          _structMembersVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
      nullptr);

  visitChildrenResultChecker(resultCode);

  // returning null to exclude the struct members as it has a struct by value field
  if (isStructByValue) {
    _logger.fine(
        '---- Removed Struct members, reason: struct by value members: ${cursor.completeStringRepr()}');
    _logger.warning(
        'Removed All Struct Members from: $structName, Nested Structures not supported');
    return null;
  }

  return _members;
}

bool isStructByValue = false;

/// Visitor for the struct cursor [CXCursorKind.CXCursor_StructDecl]
///
/// child visitor invoked on struct cursor
int _structMembersVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    if (cursor.kind() == clang.CXCursorKind.CXCursor_FieldDecl) {
      _logger.finer('===== member: ${cursor.completeStringRepr()}');

      var mt = cursor.type().toCodeGenTypeAndDispose();

      //TODO: remove these when support for Structs by value arrive
      if (mt.broadType == BroadType.Struct) {
        isStructByValue =
            true; // setting this flag will exclude adding members for this struct's bindings
      } else if (mt.broadType == BroadType.ConstantArray) {
        if (mt.elementType.broadType == BroadType.Struct) {
          isStructByValue =
              true; // setting this flag will exclude adding members for this struct's bindings
        }
      }

      _members.add(
        Member(
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
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}
