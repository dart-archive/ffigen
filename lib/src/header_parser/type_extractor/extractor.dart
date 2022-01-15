// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/sub_parsers/typedefdecl_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../sub_parsers/compounddecl_parser.dart';
import '../sub_parsers/enumdecl_parser.dart';
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.extractor');
const _padding = '  ';

/// Converts cxtype to a typestring code_generator can accept.
Type getCodeGenType(
  clang_types.CXType cxtype, {

  /// Passed on if a value was marked as a pointer before this one.
  bool pointerReference = false,
}) {
  _logger.fine('${_padding}getCodeGenType ${cxtype.completeStringRepr()}');
  final kind = cxtype.kind;

  switch (kind) {
    case clang_types.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType(cxtype);
      final s = getCodeGenType(pt, pointerReference: true);

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
      if (config.typedefTypeMappings.containsKey(spelling)) {
        _logger.fine('  Type $spelling mapped from type-map');
        return Type.importedType(config.typedefTypeMappings[spelling]!);
      }
      // Get name from supported typedef name if config allows.
      if (config.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return Type.nativeType(
              suportedTypedefToSuportedNativeType[spelling]!);
        } else if (supportedTypedefToImportedType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return Type.importedType(supportedTypedefToImportedType[spelling]!);
        }
      }

      // This is important or we get stuck in infinite recursion.
      final cursor = clang.clang_getTypeDeclaration(cxtype);
      final typedefUsr = cursor.usr();

      if (bindingsIndex.isSeenTypealias(typedefUsr)) {
        return Type.typealias(bindingsIndex.getSeenTypealias(typedefUsr)!);
      } else {
        final typealias =
            parseTypedefDeclaration(cursor, pointerReference: pointerReference);

        if (typealias != null) {
          return Type.typealias(typealias);
        } else {
          // Use underlying type if typealias couldn't be created or if
          // the user excluded this typedef.
          final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
          return getCodeGenType(ct, pointerReference: pointerReference);
        }
      }
    case clang_types.CXTypeKind.CXType_Elaborated:
      final et = clang.clang_Type_getNamedType(cxtype);
      final s = getCodeGenType(et, pointerReference: pointerReference);
      return s;
    case clang_types.CXTypeKind.CXType_Record:
      return _extractfromRecord(cxtype, pointerReference);
    case clang_types.CXTypeKind.CXType_Enum:
      final cursor = clang.clang_getTypeDeclaration(cxtype);
      final usr = cursor.usr();

      if (bindingsIndex.isSeenEnumClass(usr)) {
        return Type.enumClass(bindingsIndex.getSeenEnumClass(usr)!);
      } else {
        final enumClass = parseEnumDeclaration(
          cursor,
          ignoreFilter: true,
        );
        if (enumClass == null) {
          // Handle anonymous enum declarations within another declaration.
          return Type.nativeType(Type.enumNativeType);
        } else {
          return Type.enumClass(enumClass);
        }
      }
    case clang_types.CXTypeKind.CXType_FunctionProto:
      // Primarily used for function pointers.
      return _extractFromFunctionProto(cxtype);
    case clang_types.CXTypeKind.CXType_FunctionNoProto:
      // Primarily used for function types with zero arguments.
      return _extractFromFunctionProto(cxtype);
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
      var typeSpellKey =
          clang.clang_getTypeSpelling(cxtype).toStringAndDispose();
      if (typeSpellKey.startsWith('const ')) {
        typeSpellKey = typeSpellKey.replaceFirst('const ', '');
      }
      if (config.nativeTypeMappings.containsKey(typeSpellKey)) {
        _logger.fine('  Type $typeSpellKey mapped from type-map.');
        return Type.importedType(config.nativeTypeMappings[typeSpellKey]!);
      } else if (cxTypeKindToImportedTypes.containsKey(typeSpellKey)) {
        return Type.importedType(cxTypeKindToImportedTypes[typeSpellKey]!);
      } else {
        _logger.fine(
            'typedeclarationCursorVisitor: getCodeGenType: Type Not Implemented, ${cxtype.completeStringRepr()}');
        return Type.unimplemented(
            'Type: ${cxtype.kindSpelling()} not implemented');
      }
  }
}

Type _extractfromRecord(clang_types.CXType cxtype, bool pointerReference) {
  Type type;

  final cursor = clang.clang_getTypeDeclaration(cxtype);
  _logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  final cursorKind = clang.clang_getCursorKind(cursor);
  if (cursorKind == clang_types.CXCursorKind.CXCursor_StructDecl ||
      cursorKind == clang_types.CXCursorKind.CXCursor_UnionDecl) {
    final declUsr = cursor.usr();
    final declSpelling = cursor.spelling();

    // Set includer functions according to compoundType.
    final bool Function(String) isSeenDecl;
    final Compound? Function(String) getSeenDecl;
    final CompoundType compoundType;
    final Map<String, ImportedType> compoundTypeMappings;

    switch (cursorKind) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        isSeenDecl = bindingsIndex.isSeenStruct;
        getSeenDecl = bindingsIndex.getSeenStruct;
        compoundType = CompoundType.struct;
        compoundTypeMappings = config.structTypeMappings;
        break;
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
        isSeenDecl = bindingsIndex.isSeenUnion;
        getSeenDecl = bindingsIndex.getSeenUnion;
        compoundType = CompoundType.union;
        compoundTypeMappings = config.unionTypeMappings;
        break;
      default:
        throw Exception('Unhandled compound type cursorkind.');
    }

    // Also add a struct binding, if its unseen.
    // TODO(23): Check if we should auto add compound declarations.
    if (compoundTypeMappings.containsKey(declSpelling)) {
      _logger.fine('  Type Mapped from type-map');
      return Type.importedType(compoundTypeMappings[declSpelling]!);
    } else if (isSeenDecl(declUsr)) {
      type = Type.compound(getSeenDecl(declUsr)!);

      // This will parse the dependencies if needed.
      parseCompoundDeclaration(
        cursor,
        compoundType,
        ignoreFilter: true,
        pointerReference: pointerReference,
      );
    } else {
      final struc = parseCompoundDeclaration(
        cursor,
        compoundType,
        ignoreFilter: true,
        pointerReference: pointerReference,
      );
      type = Type.compound(struc!);
    }
  } else {
    _logger.fine(
        'typedeclarationCursorVisitor: _extractfromRecord: Not Implemented, ${cursor.completeStringRepr()}');
    return Type.unimplemented('Type: ${cxtype.kindSpelling()} not implemented');
  }

  return type;
}

// Used for function pointer arguments.
Type _extractFromFunctionProto(clang_types.CXType cxtype) {
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

  return Type.nativeFunc(NativeFunc.fromFunctionType(FunctionType(
    parameters: _parameters,
    returnType: clang.clang_getResultType(cxtype).toCodeGenType(),
  )));
}
