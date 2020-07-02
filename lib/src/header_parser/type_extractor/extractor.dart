// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../data.dart';
import '../includer.dart';
import '../sub_parsers/structdecl_parser.dart';
import '../translation_unit_parser.dart';
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';

var _logger = Logger('parser:extractor');
const _padding = '  ';

/// Converts cxtype to a typestring code_generator can accept.
Type getCodeGenType(Pointer<clang.CXType> cxtype, {String parentName}) {
  _logger.fine('${_padding}getCodeGenType ${cxtype.completeStringRepr()}');
  final kind = cxtype.kind();

  switch (kind) {
    case clang.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType_wrap(cxtype);
      final s = getCodeGenType(pt, parentName: parentName);
      pt.dispose();
      return Type.pointer(s);
    case clang.CXTypeKind.CXType_Typedef:
      // Get name from typedef name if config allows.
      if (config.useSupportedTypedefs) {
        final spelling = cxtype.spelling();
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return Type.nativeType(suportedTypedefToSuportedNativeType[spelling]);
        }
      }

      // This is important or we get stuck in infinite recursion.
      final ct = clang.clang_getCanonicalType_wrap(cxtype);

      final s = getCodeGenType(ct, parentName: parentName ?? cxtype.spelling());
      ct.dispose();
      return s;
    case clang.CXTypeKind.CXType_Elaborated:
      final et = clang.clang_Type_getNamedType_wrap(cxtype);
      final s = getCodeGenType(et, parentName: parentName);
      et.dispose();
      return s;
    case clang.CXTypeKind.CXType_Record:
      return _extractfromRecord(cxtype);
    case clang.CXTypeKind.CXType_Enum:
      return Type.nativeType(
        enumNativeType,
      );
    case clang.CXTypeKind
        .CXType_FunctionProto: // Primarily used for function pointers.
      return _extractFromFunctionProto(cxtype, parentName);
    case clang.CXTypeKind
        .CXType_ConstantArray: // Primarily used for constant array in struct members.
      return Type.constantArray(
        clang.clang_getNumElements_wrap(cxtype),
        clang.clang_getArrayElementType_wrap(cxtype).toCodeGenTypeAndDispose(),
      );
    case clang.CXTypeKind
        .CXType_IncompleteArray: // Primarily used for incomplete array in function parameters.
      return Type.incompleteArray(
        clang.clang_getArrayElementType_wrap(cxtype).toCodeGenTypeAndDispose(),
      );
    default:
      if (cxTypeKindToSupportedNativeTypes.containsKey(kind)) {
        return Type.nativeType(
          cxTypeKindToSupportedNativeTypes[kind],
        );
      } else {
        _logger.fine(
            'typedeclarationCursorVisitor: getCodeGenType: Type Not Implemented, ${cxtype.completeStringRepr()}');
        return Type.unimplemented(
            'Type: ${cxtype.kindSpelling()} not implemented');
      }
  }
}

Type _extractfromRecord(Pointer<clang.CXType> cxtype) {
  Type type;

  final cursor = clang.clang_getTypeDeclaration_wrap(cxtype);
  _logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_StructDecl:
      final cxtype = cursor.type();
      var structName = cursor.spelling();
      if (structName == '') {
        // Incase of anonymous structs defined inside a typedef.
        structName = cxtype.spelling();
      }

      type = Type.struct(structName);

      // Also add a struct binding, if its unseen.
      if (isUnseenStruct(structName, addToSeen: true)) {
        addToBindings(
            parseStructDeclaration(cursor, name: structName, doInclude: true));
      }

      cxtype.dispose();
      break;
    default:
      _logger.fine(
          'typedeclarationCursorVisitor: _extractfromRecord: Not Implemented, ${cursor.completeStringRepr()}');
      return Type.unimplemented(
          'Type: ${cxtype.kindSpelling()} not implemented');
  }
  cursor.dispose();
  return type;
}

// Used for function pointer arguments.
Type _extractFromFunctionProto(
    Pointer<clang.CXType> cxtype, String parentName) {
  var name = parentName;

  // Set a name for typedefc incase it was null or empty.
  if (name == null || name == '') {
    name = _getNextUniqueString('_typedefC_noname');
  }

  if (isUnseenTypedefC(name, addToSeen: true)) {
    final typedefC = TypedefC(
      name: name,
      returnType:
          clang.clang_getResultType_wrap(cxtype).toCodeGenTypeAndDispose(),
    );
    final totalArgs = clang.clang_getNumArgTypes_wrap(cxtype);
    for (var i = 0; i < totalArgs; i++) {
      final t = clang.clang_getArgType_wrap(cxtype, i);
      typedefC.parameters.add(
        Parameter(name: '', type: t.toCodeGenTypeAndDispose()),
      );
    }
    addToBindings(typedefC);
  }
  return Type.nativeFunc(name);
}

/// Generate a unique string for naming in [TypedefC].
String _getNextUniqueString(String prefix) {
  int i = _uniqueStringCounters[prefix] ?? 0;
  i++;
  _uniqueStringCounters[prefix] = i;
  return '${prefix}_$i';
}

Map<String, int> _uniqueStringCounters = {};
