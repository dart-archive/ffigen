/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

class CXCodeCompleteResults extends ffi.Struct {}

class CXCompletionResult extends ffi.Struct {}

class CXCursor extends ffi.Struct {}

class CXCursorAndRangeVisitor extends ffi.Struct {}

class CXCursorSetImpl extends ffi.Struct {}

class CXFileUniqueID extends ffi.Struct {}

class CXIdxAttrInfo extends ffi.Struct {}

class CXIdxBaseClassInfo extends ffi.Struct {}

class CXIdxCXXClassDeclInfo extends ffi.Struct {}

class CXIdxContainerInfo extends ffi.Struct {}

class CXIdxDeclInfo extends ffi.Struct {}

class CXIdxEntityInfo extends ffi.Struct {}

class CXIdxEntityRefInfo extends ffi.Struct {}

class CXIdxIBOutletCollectionAttrInfo extends ffi.Struct {}

class CXIdxImportedASTFileInfo extends ffi.Struct {}

class CXIdxIncludedFileInfo extends ffi.Struct {}

class CXIdxLoc extends ffi.Struct {}

class CXIdxObjCCategoryDeclInfo extends ffi.Struct {}

class CXIdxObjCContainerDeclInfo extends ffi.Struct {}

class CXIdxObjCInterfaceDeclInfo extends ffi.Struct {}

class CXIdxObjCPropertyDeclInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefListInfo extends ffi.Struct {}

class CXModuleMapDescriptorImpl extends ffi.Struct {}

class CXPlatformAvailability extends ffi.Struct {}

class CXSourceLocation extends ffi.Struct {}

class CXSourceRange extends ffi.Struct {}

class CXSourceRangeList extends ffi.Struct {}

class CXString extends ffi.Struct {}

class CXStringSet extends ffi.Struct {}

class CXTUResourceUsage extends ffi.Struct {}

class CXTUResourceUsageEntry extends ffi.Struct {}

class CXTargetInfoImpl extends ffi.Struct {}

class CXToken extends ffi.Struct {}

class CXTranslationUnitImpl extends ffi.Struct {}

class CXType extends ffi.Struct {}

class CXUnsavedFile extends ffi.Struct {}

class CXVersion extends ffi.Struct {}

class CXVirtualFileOverlayImpl extends ffi.Struct {}

ffi.Pointer<CXCursor> clang_Cursor_getArgument_wrap(
  ffi.Pointer<CXCursor> cursor,
  int i,
) {
  return _clang_Cursor_getArgument_wrap(
    cursor,
    i,
  );
}

final _dart_clang_Cursor_getArgument_wrap _clang_Cursor_getArgument_wrap =
    _dylib.lookupFunction<_c_clang_Cursor_getArgument_wrap,
        _dart_clang_Cursor_getArgument_wrap>('clang_Cursor_getArgument_wrap');

typedef _c_clang_Cursor_getArgument_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXCursor> cursor,
  ffi.Uint32 i,
);

typedef _dart_clang_Cursor_getArgument_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXCursor> cursor,
  int i,
);

int clang_Cursor_getNumArguments_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_Cursor_getNumArguments_wrap(
    cursor,
  );
}

final _dart_clang_Cursor_getNumArguments_wrap
    _clang_Cursor_getNumArguments_wrap = _dylib.lookupFunction<
            _c_clang_Cursor_getNumArguments_wrap,
            _dart_clang_Cursor_getNumArguments_wrap>(
        'clang_Cursor_getNumArguments_wrap');

typedef _c_clang_Cursor_getNumArguments_wrap = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_Cursor_getNumArguments_wrap = int Function(
  ffi.Pointer<CXCursor> cursor,
);

ffi.Pointer<CXType> clang_Type_getNamedType_wrap(
  ffi.Pointer<CXType> elaboratedType,
) {
  return _clang_Type_getNamedType_wrap(
    elaboratedType,
  );
}

final _dart_clang_Type_getNamedType_wrap _clang_Type_getNamedType_wrap =
    _dylib.lookupFunction<_c_clang_Type_getNamedType_wrap,
        _dart_clang_Type_getNamedType_wrap>('clang_Type_getNamedType_wrap');

typedef _c_clang_Type_getNamedType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> elaboratedType,
);

typedef _dart_clang_Type_getNamedType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> elaboratedType,
);

void clang_disposeString_wrap(
  ffi.Pointer<CXString> string,
) {
  return _clang_disposeString_wrap(
    string,
  );
}

final _dart_clang_disposeString_wrap _clang_disposeString_wrap =
    _dylib.lookupFunction<_c_clang_disposeString_wrap,
        _dart_clang_disposeString_wrap>('clang_disposeString_wrap');

typedef _c_clang_disposeString_wrap = ffi.Void Function(
  ffi.Pointer<CXString> string,
);

typedef _dart_clang_disposeString_wrap = void Function(
  ffi.Pointer<CXString> string,
);

ffi.Pointer<CXString> clang_formatDiagnostic_wrap(
  ffi.Pointer<ffi.Void> diag,
  int opts,
) {
  return _clang_formatDiagnostic_wrap(
    diag,
    opts,
  );
}

final _dart_clang_formatDiagnostic_wrap _clang_formatDiagnostic_wrap =
    _dylib.lookupFunction<_c_clang_formatDiagnostic_wrap,
        _dart_clang_formatDiagnostic_wrap>('clang_formatDiagnostic_wrap');

typedef _c_clang_formatDiagnostic_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> diag,
  ffi.Int32 opts,
);

typedef _dart_clang_formatDiagnostic_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> diag,
  int opts,
);

ffi.Pointer<ffi2.Utf8> clang_getCString_wrap(
  ffi.Pointer<CXString> string,
) {
  return _clang_getCString_wrap(
    string,
  );
}

final _dart_clang_getCString_wrap _clang_getCString_wrap = _dylib
    .lookupFunction<_c_clang_getCString_wrap, _dart_clang_getCString_wrap>(
        'clang_getCString_wrap');

typedef _c_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> string,
);

typedef _dart_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> string,
);

ffi.Pointer<CXType> clang_getCanonicalType_wrap(
  ffi.Pointer<CXType> typerefType,
) {
  return _clang_getCanonicalType_wrap(
    typerefType,
  );
}

final _dart_clang_getCanonicalType_wrap _clang_getCanonicalType_wrap =
    _dylib.lookupFunction<_c_clang_getCanonicalType_wrap,
        _dart_clang_getCanonicalType_wrap>('clang_getCanonicalType_wrap');

typedef _c_clang_getCanonicalType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> typerefType,
);

typedef _dart_clang_getCanonicalType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> typerefType,
);

ffi.Pointer<CXString> clang_getCursorKindSpelling_wrap(
  int kind,
) {
  return _clang_getCursorKindSpelling_wrap(
    kind,
  );
}

final _dart_clang_getCursorKindSpelling_wrap _clang_getCursorKindSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getCursorKindSpelling_wrap,
            _dart_clang_getCursorKindSpelling_wrap>(
        'clang_getCursorKindSpelling_wrap');

typedef _c_clang_getCursorKindSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Int32 kind,
);

typedef _dart_clang_getCursorKindSpelling_wrap = ffi.Pointer<CXString> Function(
  int kind,
);

int clang_getCursorKind_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorKind_wrap(
    cursor,
  );
}

final _dart_clang_getCursorKind_wrap _clang_getCursorKind_wrap =
    _dylib.lookupFunction<_c_clang_getCursorKind_wrap,
        _dart_clang_getCursorKind_wrap>('clang_getCursorKind_wrap');

typedef _c_clang_getCursorKind_wrap = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorKind_wrap = int Function(
  ffi.Pointer<CXCursor> cursor,
);

ffi.Pointer<CXString> clang_getCursorSpelling_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorSpelling_wrap(
    cursor,
  );
}

final _dart_clang_getCursorSpelling_wrap _clang_getCursorSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getCursorSpelling_wrap,
        _dart_clang_getCursorSpelling_wrap>('clang_getCursorSpelling_wrap');

typedef _c_clang_getCursorSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXCursor> cursor,
);

ffi.Pointer<CXType> clang_getCursorType_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorType_wrap(
    cursor,
  );
}

final _dart_clang_getCursorType_wrap _clang_getCursorType_wrap =
    _dylib.lookupFunction<_c_clang_getCursorType_wrap,
        _dart_clang_getCursorType_wrap>('clang_getCursorType_wrap');

typedef _c_clang_getCursorType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXCursor> cursor,
);

ffi.Pointer<CXType> clang_getPointeeType_wrap(
  ffi.Pointer<CXType> pointerType,
) {
  return _clang_getPointeeType_wrap(
    pointerType,
  );
}

final _dart_clang_getPointeeType_wrap _clang_getPointeeType_wrap =
    _dylib.lookupFunction<_c_clang_getPointeeType_wrap,
        _dart_clang_getPointeeType_wrap>('clang_getPointeeType_wrap');

typedef _c_clang_getPointeeType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> pointerType,
);

typedef _dart_clang_getPointeeType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> pointerType,
);

ffi.Pointer<CXType> clang_getResultType_wrap(
  ffi.Pointer<CXType> functionType,
) {
  return _clang_getResultType_wrap(
    functionType,
  );
}

final _dart_clang_getResultType_wrap _clang_getResultType_wrap =
    _dylib.lookupFunction<_c_clang_getResultType_wrap,
        _dart_clang_getResultType_wrap>('clang_getResultType_wrap');

typedef _c_clang_getResultType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> functionType,
);

typedef _dart_clang_getResultType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> functionType,
);

ffi.Pointer<CXCursor> clang_getTranslationUnitCursor_wrap(
  ffi.Pointer<CXTranslationUnitImpl> tu,
) {
  return _clang_getTranslationUnitCursor_wrap(
    tu,
  );
}

final _dart_clang_getTranslationUnitCursor_wrap
    _clang_getTranslationUnitCursor_wrap = _dylib.lookupFunction<
            _c_clang_getTranslationUnitCursor_wrap,
            _dart_clang_getTranslationUnitCursor_wrap>(
        'clang_getTranslationUnitCursor_wrap');

typedef _c_clang_getTranslationUnitCursor_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
);

typedef _dart_clang_getTranslationUnitCursor_wrap = ffi.Pointer<CXCursor>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
);

ffi.Pointer<CXCursor> clang_getTypeDeclaration_wrap(
  ffi.Pointer<CXType> cxtype,
) {
  return _clang_getTypeDeclaration_wrap(
    cxtype,
  );
}

final _dart_clang_getTypeDeclaration_wrap _clang_getTypeDeclaration_wrap =
    _dylib.lookupFunction<_c_clang_getTypeDeclaration_wrap,
        _dart_clang_getTypeDeclaration_wrap>('clang_getTypeDeclaration_wrap');

typedef _c_clang_getTypeDeclaration_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXType> cxtype,
);

typedef _dart_clang_getTypeDeclaration_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXType> cxtype,
);

ffi.Pointer<CXString> clang_getTypeKindSpelling_wrap(
  int typeKind,
) {
  return _clang_getTypeKindSpelling_wrap(
    typeKind,
  );
}

final _dart_clang_getTypeKindSpelling_wrap _clang_getTypeKindSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getTypeKindSpelling_wrap,
        _dart_clang_getTypeKindSpelling_wrap>('clang_getTypeKindSpelling_wrap');

typedef _c_clang_getTypeKindSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Int32 typeKind,
);

typedef _dart_clang_getTypeKindSpelling_wrap = ffi.Pointer<CXString> Function(
  int typeKind,
);

ffi.Pointer<CXString> clang_getTypeSpelling_wrap(
  ffi.Pointer<CXType> type,
) {
  return _clang_getTypeSpelling_wrap(
    type,
  );
}

final _dart_clang_getTypeSpelling_wrap _clang_getTypeSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getTypeSpelling_wrap,
        _dart_clang_getTypeSpelling_wrap>('clang_getTypeSpelling_wrap');

typedef _c_clang_getTypeSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXType> type,
);

typedef _dart_clang_getTypeSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXType> type,
);

ffi.Pointer<CXType> clang_getTypedefDeclUnderlyingType_wrap(
  ffi.Pointer<CXCursor> cxcursor,
) {
  return _clang_getTypedefDeclUnderlyingType_wrap(
    cxcursor,
  );
}

final _dart_clang_getTypedefDeclUnderlyingType_wrap
    _clang_getTypedefDeclUnderlyingType_wrap = _dylib.lookupFunction<
            _c_clang_getTypedefDeclUnderlyingType_wrap,
            _dart_clang_getTypedefDeclUnderlyingType_wrap>(
        'clang_getTypedefDeclUnderlyingType_wrap');

typedef _c_clang_getTypedefDeclUnderlyingType_wrap = ffi.Pointer<CXType>
    Function(
  ffi.Pointer<CXCursor> cxcursor,
);

typedef _dart_clang_getTypedefDeclUnderlyingType_wrap = ffi.Pointer<CXType>
    Function(
  ffi.Pointer<CXCursor> cxcursor,
);
