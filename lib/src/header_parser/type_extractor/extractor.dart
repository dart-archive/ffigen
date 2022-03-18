// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/sub_parsers/typedefdecl_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';

import '../../config_provider/config_types.dart';
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

  /// Option to ignore declaration filter (Useful in case of extracting
  /// declarations when they are passed/returned by an included function.)
  bool ignoreFilter = true,

  /// Passed on if a value was marked as a pointer before this one.
  bool pointerReference = false,
}) {
  _logger.fine('${_padding}getCodeGenType ${cxtype.completeStringRepr()}');

  // Special case: Elaborated types just refer to another type.
  if (cxtype.kind == clang_types.CXTypeKind.CXType_Elaborated) {
    return getCodeGenType(clang.clang_Type_getNamedType(cxtype),
        ignoreFilter: ignoreFilter, pointerReference: pointerReference);
  }

  // Objective C types skip the cache, and are conditional on the language flag.
  if (config.language == Language.objc) {
    switch (cxtype.kind) {
      case clang_types.CXTypeKind.CXType_ObjCObjectPointer:
      case clang_types.CXTypeKind.CXType_BlockPointer:
      case clang_types.CXTypeKind.CXType_ObjCId:
        return Type.pointer(Type.struct(objCObjectType));
      case clang_types.CXTypeKind.CXType_ObjCSel:
        return Type.pointer(Type.struct(objCSelType));
      case clang_types.CXTypeKind.CXType_ObjCClass:
        return Type.struct(objCObjectType);
    }
  }

  // If the type has a declaration cursor, then use the BindingsIndex to break
  // any potential cycles, and dedupe the Type.
  final cursor = clang.clang_getTypeDeclaration(cxtype);
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_NoDeclFound) {
    final usr = cursor.usr();
    var type = bindingsIndex.getSeenType(usr);
    if (type == null) {
      final result =
          _createTypeFromCursor(cxtype, cursor, ignoreFilter, pointerReference);
      type = result.type;
      if (type == null) {
        return Type.unimplemented(
            'Type: ${cxtype.kindSpelling()} not implemented');
      }
      if (result.addToCache) {
        bindingsIndex.addTypeToSeen(usr, type);
      }
    }
    _fillFromCursorIfNeeded(type, cursor, ignoreFilter, pointerReference);
    return type;
  }

  // If the type doesn't have a declaration cursor, then it's a basic type such
  // as int, or a simple derived type like a pointer, so doesn't need to be
  // cached.
  switch (cxtype.kind) {
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

class _CreateTypeFromCursorResult {
  final Type? type;

  // Flag that controls whether the type is added to the cache. It should not
  // be added to the cache if it's just a fallback implementation, such as the
  // int that is returned when an enum is excluded by the config. Later we might
  // need to build the full enum type (eg if it's part of an included struct),
  // and if we put the fallback int in the cache then the full enum will never
  // be created.
  final bool addToCache;

  _CreateTypeFromCursorResult(this.type, {this.addToCache = true});
}

_CreateTypeFromCursorResult _createTypeFromCursor(clang_types.CXType cxtype,
    clang_types.CXCursor cursor, bool ignoreFilter, bool pointerReference) {
  switch (cxtype.kind) {
    case clang_types.CXTypeKind.CXType_Typedef:
      final spelling = clang.clang_getTypedefName(cxtype).toStringAndDispose();
      if (config.typedefTypeMappings.containsKey(spelling)) {
        _logger.fine('  Type $spelling mapped from type-map');
        return _CreateTypeFromCursorResult(
            Type.importedType(config.typedefTypeMappings[spelling]!));
      }
      // Get name from supported typedef name if config allows.
      if (config.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return _CreateTypeFromCursorResult(
              Type.nativeType(suportedTypedefToSuportedNativeType[spelling]!));
        } else if (supportedTypedefToImportedType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return _CreateTypeFromCursorResult(
              Type.importedType(supportedTypedefToImportedType[spelling]!));
        }
      }

      final typealias =
          parseTypedefDeclaration(cursor, pointerReference: pointerReference);

      if (typealias != null) {
        return _CreateTypeFromCursorResult(Type.typealias(typealias));
      } else {
        // Use underlying type if typealias couldn't be created or if the user
        // excluded this typedef.
        final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
        return _CreateTypeFromCursorResult(
            getCodeGenType(ct, pointerReference: pointerReference),
            addToCache: false);
      }
    case clang_types.CXTypeKind.CXType_Record:
      return _CreateTypeFromCursorResult(
          _extractfromRecord(cxtype, cursor, ignoreFilter, pointerReference));
    case clang_types.CXTypeKind.CXType_Enum:
      final enumClass = parseEnumDeclaration(
        cursor,
        ignoreFilter: ignoreFilter,
      );
      if (enumClass == null) {
        // Handle anonymous enum declarations within another declaration.
        return _CreateTypeFromCursorResult(Type.nativeType(Type.enumNativeType),
            addToCache: false);
      } else {
        return _CreateTypeFromCursorResult(Type.enumClass(enumClass));
      }
    default:
      throw UnimplementedError(
          'Unknown cursor kind: ${cursor.completeStringRepr()}');
  }
}

void _fillFromCursorIfNeeded(Type? type, clang_types.CXCursor cursor,
    bool ignoreFilter, bool pointerReference) {
  if (type == null) return;
  if (type.compound != null) {
    fillCompoundMembersIfNeeded(type.compound!, cursor,
        ignoreFilter: ignoreFilter, pointerReference: pointerReference);
  }
}

Type? _extractfromRecord(clang_types.CXType cxtype, clang_types.CXCursor cursor,
    bool ignoreFilter, bool pointerReference) {
  _logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  final cursorKind = clang.clang_getCursorKind(cursor);
  if (cursorKind == clang_types.CXCursorKind.CXCursor_StructDecl ||
      cursorKind == clang_types.CXCursorKind.CXCursor_UnionDecl) {
    final declSpelling = cursor.spelling();

    // Set includer functions according to compoundType.
    final CompoundType compoundType;
    final Map<String, ImportedType> compoundTypeMappings;

    switch (cursorKind) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        compoundType = CompoundType.struct;
        compoundTypeMappings = config.structTypeMappings;
        break;
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
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
    } else {
      final struct = parseCompoundDeclaration(
        cursor,
        compoundType,
        ignoreFilter: ignoreFilter,
        pointerReference: pointerReference,
      );
      if (struct == null) return null;
      return Type.compound(struct);
    }
  }
  _logger.fine(
      'typedeclarationCursorVisitor: _extractfromRecord: Not Implemented, ${cursor.completeStringRepr()}');
  return Type.unimplemented('Type: ${cxtype.kindSpelling()} not implemented');
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
