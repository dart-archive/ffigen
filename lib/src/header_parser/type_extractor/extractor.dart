// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../sub_parsers/compounddecl_parser.dart';
import '../translation_unit_parser.dart';
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.extractor');
const _padding = '  ';

/// Converts cxtype to a typestring code_generator can accept.
Type getCodeGenType(
  clang_types.CXType cxtype, {
  String? parentName,

  /// Passed on if a value was marked as a pointer before this one.
  bool pointerReference = false,
}) {
  _logger.fine('${_padding}getCodeGenType ${cxtype.completeStringRepr()}');
  final kind = cxtype.kind;

  switch (kind) {
    case clang_types.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType(cxtype);
      final s =
          getCodeGenType(pt, parentName: parentName, pointerReference: true);

      // Replace Pointer<_Dart_Handle> with Handle.
      if (config.useDartHandle &&
          s.broadType == BroadType.Compound &&
          s.compound!.compoundType == CompoundType.struct &&
          s.compound!.usr == strings.dartHandleUsr) {
        return Type.handle();
      }
      return Type.pointer(s);
    case clang_types.CXTypeKind.CXType_Typedef:
      final spelling = clang.clang_getTypedefName(cxtype).toStringAndDispose();
      if (config.typedefNativeTypeMappings.containsKey(spelling)) {
        _logger.fine('  Type Mapped from typedef-map');
        return Type.nativeType(config.typedefNativeTypeMappings[spelling]!);
      }
      // Get name from supported typedef name if config allows.
      if (config.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return Type.nativeType(
              suportedTypedefToSuportedNativeType[spelling]!);
        }
      }

      // This is important or we get stuck in infinite recursion.
      final ct = clang.clang_getTypedefDeclUnderlyingType(
          clang.clang_getTypeDeclaration(cxtype));

      final s = getCodeGenType(ct,
          parentName: parentName ?? spelling,
          pointerReference: pointerReference);
      return s;
    case clang_types.CXTypeKind.CXType_Elaborated:
      final et = clang.clang_Type_getNamedType(cxtype);
      final s = getCodeGenType(et,
          parentName: parentName, pointerReference: pointerReference);
      return s;
    case clang_types.CXTypeKind.CXType_Record:
      return _extractfromRecord(cxtype, parentName, pointerReference);
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
          cxTypeKindToSupportedNativeTypes[kind]!,
        );
      } else {
        _logger.fine(
            'typedeclarationCursorVisitor: getCodeGenType: Type Not Implemented, ${cxtype.completeStringRepr()}');
        return Type.unimplemented(
            'Type: ${cxtype.kindSpelling()} not implemented');
      }
  }
}

Type _extractfromRecord(
    clang_types.CXType cxtype, String? parentName, bool pointerReference) {
  Type type;

  final cursor = clang.clang_getTypeDeclaration(cxtype);
  _logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  final cursorKind = clang.clang_getCursorKind(cursor);
  if (cursorKind == clang_types.CXCursorKind.CXCursor_StructDecl ||
      cursorKind == clang_types.CXCursorKind.CXCursor_UnionDecl) {
    final declUsr = cursor.usr();

    // Name of typedef (parentName) is used if available.
    final declName = parentName ?? cursor.spelling();

    // Set includer functions according to compoundType.
    final bool Function(String) isSeenDecl;
    final Compound? Function(String) getSeenDecl;
    final CompoundType compoundType;

    switch (cursorKind) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        isSeenDecl = bindingsIndex.isSeenStruct;
        getSeenDecl = bindingsIndex.getSeenStruct;
        compoundType = CompoundType.struct;
        break;
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
        isSeenDecl = bindingsIndex.isSeenUnion;
        getSeenDecl = bindingsIndex.getSeenUnion;
        compoundType = CompoundType.union;
        break;
      default:
        throw Exception('Unhandled compound type cursorkind.');
    }

    // Also add a struct binding, if its unseen.
    // TODO(23): Check if we should auto add compound declarations.
    if (isSeenDecl(declUsr)) {
      type = Type.compound(getSeenDecl(declUsr)!);

      // This will parse the dependencies if needed.
      parseCompoundDeclaration(
        cursor,
        compoundType,
        name: declName,
        ignoreFilter: true,
        pointerReference: pointerReference,
        updateName: false,
      );
    } else {
      final struc = parseCompoundDeclaration(
        cursor,
        compoundType,
        name: declName,
        ignoreFilter: true,
        pointerReference: pointerReference,
      );
      type = Type.compound(struc!);

      // Add to bindings if it's not Dart_Handle and is unseen.
      if (!(config.useDartHandle && declUsr == strings.dartHandleUsr)) {
        addToBindings(struc);
      }
    }
  } else {
    _logger.fine(
        'typedeclarationCursorVisitor: _extractfromRecord: Not Implemented, ${cursor.completeStringRepr()}');
    return Type.unimplemented('Type: ${cxtype.kindSpelling()} not implemented');
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

    if (pt.isIncompleteCompound) {
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

  return Type.nativeFunc(typedefC!);
}
