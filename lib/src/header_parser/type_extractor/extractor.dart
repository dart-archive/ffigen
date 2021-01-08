// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../sub_parsers/structdecl_parser.dart';
import '../translation_unit_parser.dart';
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.extractor');
const _padding = '  ';

/// Converts cxtype to a typestring code_generator can accept.
Type getCodeGenType(clang_types.CXType cxtype, {String? parentName}) {
  _logger.fine('${_padding}getCodeGenType ${cxtype.completeStringRepr()}');
  final kind = cxtype.kind;

  switch (kind) {
    case clang_types.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType(cxtype);
      final s = getCodeGenType(pt, parentName: parentName);

      // Replace Pointer<_Dart_Handle> with Handle.
      if (config.useDartHandle &&
          s.broadType == BroadType.Struct &&
          s.struc!.usr == strings.dartHandleUsr) {
        return Type.handle();
      }
      return Type.pointer(s);
    case clang_types.CXTypeKind.CXType_Typedef:
      final spelling = cxtype.spelling();
      if (config.typedefNativeTypeMappings.containsKey(spelling)) {
        _logger.fine('  Type Mapped from typedef-map');
        return Type.nativeType(config.typedefNativeTypeMappings[spelling]);
      }
      // Get name from supported typedef name if config allows.
      if (config.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return Type.nativeType(suportedTypedefToSuportedNativeType[spelling]);
        }
      }

      // This is important or we get stuck in infinite recursion.
      final ct = clang.clang_getTypedefDeclUnderlyingType(
          clang.clang_getTypeDeclaration(cxtype));

      final s = getCodeGenType(ct, parentName: parentName ?? cxtype.spelling());
      return s;
    case clang_types.CXTypeKind.CXType_Elaborated:
      final et = clang.clang_Type_getNamedType(cxtype);
      final s = getCodeGenType(et, parentName: parentName);
      return s;
    case clang_types.CXTypeKind.CXType_Record:
      return _extractfromRecord(cxtype, parentName);
    case clang_types.CXTypeKind.CXType_Enum:
      return Type.nativeType(
        enumNativeType,
      );
    case clang_types.CXTypeKind.CXType_FunctionProto:
      // Primarily used for function pointers.
      return _extractFromFunctionProto(cxtype, parentName);
    case clang_types.CXTypeKind.CXType_FunctionNoProto:
      // Primarily used for function types with zero arguments.
      return _extractFromFunctionProto(cxtype, parentName);
    case clang_types.CXTypeKind
        .CXType_ConstantArray: // Primarily used for constant array in struct members.
      return Type.constantArray(
        clang.clang_getNumElements(cxtype),
        clang.clang_getArrayElementType(cxtype).toCodeGenType(),
      );
    case clang_types.CXTypeKind
        .CXType_IncompleteArray: // Primarily used for incomplete array in function parameters.
      return Type.incompleteArray(
        clang.clang_getArrayElementType(cxtype).toCodeGenType(),
      );
    case clang_types.CXTypeKind.CXType_Bool:
      return Type.boolean();
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

Type _extractfromRecord(clang_types.CXType cxtype, String? parentName) {
  Type type;

  final cursor = clang.clang_getTypeDeclaration(cxtype);
  _logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  switch (clang.clang_getCursorKind(cursor)) {
    case clang_types.CXCursorKind.CXCursor_StructDecl:
      final structUsr = cursor.usr();

      // Name of typedef (parentName) is used if available.
      final structName = parentName ?? cursor.spelling();

      // Also add a struct binding, if its unseen.
      // TODO(23): Check if we should auto add struct.
      if (bindingsIndex.isSeenStruct(structUsr)) {
        type = Type.struct(bindingsIndex.getSeenStruct(structUsr));
      } else {
        final struc = parseStructDeclaration(cursor,
            name: structName, ignoreFilter: true);
        type = Type.struct(struc);

        // Add to bindings if it's not Dart_Handle.
        if (!(config.useDartHandle && structUsr == strings.dartHandleUsr)) {
          addToBindings(struc);
        }
      }

      break;
    default:
      _logger.fine(
          'typedeclarationCursorVisitor: _extractfromRecord: Not Implemented, ${cursor.completeStringRepr()}');
      return Type.unimplemented(
          'Type: ${cxtype.kindSpelling()} not implemented');
  }
  return type;
}

// Used for function pointer arguments.
Type _extractFromFunctionProto(clang_types.CXType cxtype, String? parentName) {
  var name = parentName;

  // An empty name means the function prototype was declared in-place, instead
  // of using a typedef.
  name = name ?? '';
  final _parameters = <Parameter>[];
  final totalArgs = clang.clang_getNumArgTypes(cxtype);
  for (var i = 0; i < totalArgs; i++) {
    final t = clang.clang_getArgType(cxtype, i);
    final pt = t.toCodeGenType();

    if (pt.isIncompleteStruct) {
      return Type.unimplemented(
          'Incomplete Struct by value in function parameter.');
    } else if (pt.getBaseType().broadType == BroadType.Unimplemented) {
      return Type.unimplemented('Function parameter has an unsupported type.');
    }

    _parameters.add(
      Parameter(name: '', type: pt),
    );
  }

  Typedef? typedefC;
  if (bindingsIndex.isSeenFunctionTypedef(name)) {
    typedefC = bindingsIndex.getSeenFunctionTypedef(name);
  } else {
    typedefC = Typedef(
      name: name.isNotEmpty ? name : incrementalNamer.name('_typedefC'),
      typedefType: TypedefType.C,
      parameters: _parameters,
      returnType: clang.clang_getResultType(cxtype).toCodeGenType(),
    );
    // Add to seen, if name isn't empty.
    if (name.isNotEmpty) {
      bindingsIndex.addFunctionTypedefToSeen(name, typedefC);
    }
  }

  return Type.nativeFunc(typedefC);
}
